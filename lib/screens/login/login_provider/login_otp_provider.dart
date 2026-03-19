import 'dart:async';
import 'package:chronogram/screens/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../service/api_service.dart';
import '../../../app_helper/token_saver_helper/token_saver_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen_provider.dart';

class LoginMobileOtpScreenProvider extends ChangeNotifier {
  TextEditingController mobileOtpController = TextEditingController();
  // EmailMask maskedEmail = EmailMask();
  String temporaryToken = "";
  String maskedEmail = "";
  String? mobileOtpError;
  bool isMobileOtpValid = false;
  bool isLoading = false;

  bool showRegisterButton = false;
  bool showVerifyEmailButton = false;
  bool isIncomplete = false;
  // String? maskedEmail; // for new device

  /// TIMER
  int seconds = 300;
  Timer? _timer;

  bool canResend = false;
  bool isResending = false;

  LoginMobileOtpScreenProvider() {
    mobileOtpController.addListener(checkMobileOtpFill);
  }

  /// OTP realtime validation
  void checkMobileOtpFill() {
    String value = mobileOtpController.text.trim();
    isMobileOtpValid = RegExp(r'^\d{6}$').hasMatch(value);
    notifyListeners();
  }

  void _applySmsCode(String code, BuildContext context) {
    if (mobileOtpController.text == code) return; 
    mobileOtpController.text = code;

    if (validMobileOtp() && context.mounted) {
      final mobileProvider = context.read<LoginMobileScreenProvider>();
      verifyLoginOtp(context, mobileProvider.mobileController.text);
    }
  }

  bool validMobileOtp() {
    String value = mobileOtpController.text.trim();

    if (value.isEmpty) {
      mobileOtpError = 'Enter OTP';
    } else if (value.length != 6) {
      mobileOtpError = 'OTP must be 6 digit';
    } else {
      mobileOtpError = null;
    }

    notifyListeners();
    return mobileOtpError == null;
  }

  Future<void> verifyLoginOtp(BuildContext context, String mobile) async {
    if (!validMobileOtp()) return;
    isLoading = true;
    showRegisterButton = false;
    showVerifyEmailButton = false;
    isIncomplete = false;
    mobileOtpError = null;
    notifyListeners();

    try {
      final loginProvider = context.read<LoginMobileScreenProvider>();
      final verificationId = loginProvider.verificationId;
      
      if (verificationId == null) {
        mobileOtpError = "Session expired. Please request a new OTP.";
        isLoading = false;
        notifyListeners();
        return;
      }

      // 1. Verify OTP with Firebase
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: mobileOtpController.text.trim(),
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      // 2. Extract Firebase ID Token
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw Exception("Failed to retrieve ID token from Firebase");
      }

      // 3. Call Backend API
      final result = await ApiService.firebaseLogin(idToken);

      /// ✅ LOGIN SUCCESS (Complete User)
      if (result["status"] == "success") {
        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
            settings: const RouteSettings(name: "HomeScreen"),
          ),
          (route) => false,
        );
      }

      /// 🕒 NEW/INCOMPLETE USER (Needs Email/Profile)
      else if (result["status"] == "incomplete") {
        isIncomplete = true;
        mobileOtpError = "Registration incomplete. Please verify your email to continue.";
        showVerifyEmailButton = true;
      }

      /// 🔥 NEW DEVICE (401)
      else if (result["status"] == "untrusted") {
        maskedEmail = result["maskedEmail"] ?? "";
        temporaryToken = result['temporaryToken'] ?? "";
        print('Temp Token From 401:c $temporaryToken');
        mobileOtpError = "New device detected. Verify email to continue";
        showVerifyEmailButton = true;
      }

      /// 🔴 USER NOT REGISTERED
      else if (result["status"] == "not_found") {
        mobileOtpError = "Mobile number is not registered. Please register first";
        showRegisterButton = true;
      }

      /// ❌ OTHER ERRORS
      else {
        mobileOtpError = result['error'] ?? result['message'] ?? "Login failed. Please try again.";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        mobileOtpError = "Incorrect OTP. Please check and try again.";
      } else {
        mobileOtpError = e.message ?? "Verification failed";
      }
    } catch (e) {
      mobileOtpError = e.toString().replaceAll("Exception: ", "");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void init(BuildContext context) {
    mobileOtpError = null;
    isMobileOtpValid = false;
    isLoading = false;
    showRegisterButton = false;
    showVerifyEmailButton = false;
    isResending = false;

    // Check if timer is already running to avoid reset flicker
    final alreadyRunning = _timer != null && _timer!.isActive;
    if (alreadyRunning) return;

    // Seed seconds from the main login provider
    if (context.mounted) {
      final remaining = context.read<LoginMobileScreenProvider>().remainingSeconds();
      seconds = remaining > 0 ? remaining : 0;
    }

    canResend = seconds <= 0;
    if (!canResend) {
      startTimer(context);
    }
    
    if (context.mounted) {
      final mainProvider = context.read<LoginMobileScreenProvider>();
      if (mainProvider.autoRetrievedSmsCode != null) {
        _applySmsCode(mainProvider.autoRetrievedSmsCode!, context);
      } else {
        mainProvider.onAutoRetrievedSmsCode = (code) {
          if (context.mounted) _applySmsCode(code, context);
        };
      }
    }
    
    notifyListeners();
  }

  /// 🔥 STOP TIMER
  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }


  /// TIMER START
  void startTimer(BuildContext context) {
    canResend = false;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!context.mounted) {
        timer.cancel();
        return;
      }
      final provider = context.read<LoginMobileScreenProvider>();
      int remaining = provider.remainingSeconds();

      if (remaining > 0) {
        seconds = remaining;
        notifyListeners();
      } else {
        canResend = true;
        seconds = 0;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  /// TIMER TEXT
  String get timerText {
    int minutes = seconds ~/ 60;
    int sec = seconds % 60;

    if (minutes > 0) {
      if (sec == 0) return "$minutes min";
      return "$minutes min $sec sec";
    } else {
      return "$sec sec";
    }
  }

  /// 🔁 RESEND OTP (Firebase Direct)
  Future<void> resendLoginOtp(String mobile, BuildContext context) async {
    if (isResending) return;

    isResending = true;
    mobileOtpError = null;
    notifyListeners();

    try {
      final mainProvider = context.read<LoginMobileScreenProvider>();
      
      // We directly re-invoke Firebase with the forceResendingToken.
      // This ensures we get a fresh OTP from Firebase without bothering the backend or MySQL.
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+91$mobile",
        timeout: const Duration(seconds: 60),
        forceResendingToken: mainProvider.resendToken,
        verificationCompleted: (PhoneAuthCredential credential) {
          if (credential.smsCode != null && context.mounted) {
            _applySmsCode(credential.smsCode!, context);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          mobileOtpError = e.message ?? "Verification Failed";
          isResending = false;
          notifyListeners();
        },
        codeSent: (String verId, int? resendTokenId) {
          mainProvider.verificationId = verId;
          mainProvider.resendToken = resendTokenId;
          mainProvider.lastOtpSentTime = DateTime.now();
          mainProvider.lastOtpMobile = mobile;
          
          startTimer(context);
          isResending = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verId) {
          mainProvider.verificationId = verId;
        },
      );
    } catch (e) {
      mobileOtpError = "Failed to resend OTP";
      isResending = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    mobileOtpController.dispose();
    super.dispose();
  }
}
