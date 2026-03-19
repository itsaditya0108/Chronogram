import 'dart:async';
import 'package:chronogram/service/api_service.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:chronogram/app_helper/token_saver_helper/token_saver_helper.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_profile_screen.dart';
import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpMobileOtpProvider extends ChangeNotifier {
  TextEditingController mobileOtpController = TextEditingController();
  String? mobileOtpError;
  bool isMobileOtpValid = false;
  bool isLoading = false;

  /// Populated after successful OTP verify — tells the screen which screen to go to next.
  /// Values: 'email' (go to email screen) | 'profile' (skip email, go to profile)
  String nextStep = 'email';

  /// 🔥 TIMER
  int seconds = 300;
  Timer? _timer;

  /// constructor
  SignUpMobileOtpProvider() {
    mobileOtpController.addListener(checkMobileOtpFill);
    // start when screen open
  }

  void _applySmsCode(String code, BuildContext context) async {
    if (mobileOtpController.text == code) return;
    mobileOtpController.text = code;

    if (validMobileOtp() && context.mounted) {
      bool success = await verifyMobileOtp(context);
      if (success && context.mounted) {
        if (nextStep == 'profile') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpProfileScreen()));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpEmailScreen()));
        }
      }
    }
  }

  void init(BuildContext context) {
    mobileOtpError = null;
    isMobileOtpValid = false;
    isLoading = false;
    isResending = false;

    // If a timer is already running with time still left, don't reset it.
    // This prevents the "Resend OTP" flicker when the screen rebuilds
    // or when the user opens/dismisses the Change Number dialog.
    final alreadyRunning = _timer != null && _timer!.isActive;
    if (alreadyRunning) return;

    // Seed seconds immediately so the UI shows correct time from frame 1
    // (avoids a 1-second "0 sec" flash before the first timer tick).
    if (context.mounted) {
      final remaining = context.read<SignUpScreenProvider>().remainingSeconds();
      seconds = remaining > 0 ? remaining : 0;
    }

    canResend = seconds <= 0;
    if (!canResend) {
      startTimer(context);
    }
    
    if (context.mounted) {
      final mainProvider = context.read<SignUpScreenProvider>();
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

  /// realtime check for button enable
  void checkMobileOtpFill() {
    String value = mobileOtpController.text.trim();
    final mobileOtpRegex = RegExp(r'^\d{6}$');
    isMobileOtpValid = mobileOtpRegex.hasMatch(value);
    notifyListeners();
  }

  /// 🔥 TIMER START
  void startTimer(BuildContext context) {
    canResend = false;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!context.mounted) {
        timer.cancel();
        return;
      }
      final provider = context.read<SignUpScreenProvider>();
      int remaining = provider.remainingSeconds();
      
      if (remaining > 0) {
        seconds = remaining;
        notifyListeners();
      } else {
        seconds = 0;
        canResend = true; // 🔥 enable resend
        timer.cancel();
        notifyListeners();
      }
    });
  }

  /// 🔥 STOP TIMER
  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }


  /// final validation
  bool validMobileOtp() {
    String value = mobileOtpController.text.trim();

    if (value.isEmpty) {
      mobileOtpError = 'Please enter OTP';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      mobileOtpError = 'OTP must be digits only';
    } else if (value.length != 6) {
      mobileOtpError = 'OTP must be 6 digits';
    } else {
      mobileOtpError = null;
    }

    notifyListeners();
    return mobileOtpError == null;
  }

  /// VERIFY OTP API HIT
  Future<bool> verifyMobileOtp(BuildContext context) async {
    if (!validMobileOtp()) return false;

    isLoading = true;
    notifyListeners();

    try {
      final signUpProvider = context.read<SignUpScreenProvider>();
      final verificationId = signUpProvider.verificationId;

      if (verificationId == null) {
        mobileOtpError = "Session expired. Please request a new OTP.";
        return false;
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

      if (result['status'] == 'success' || result['status'] == 'incomplete') {
        // 1. Save the token (this is the registrationToken for later steps)
        String? token = result['accessToken'] ?? result['token'] ?? result['registrationToken'] ?? result['reg_token'];
        if (token != null) {
          print("I/flutter: [REGISTRATION] SAVING TOKEN: $token");
          await TokenHelper.saveRegistrationToken(token);
        }

        // 2. Decide nextStep based on backend instruction (Step 22 in guide)
        // If the backend says "complete your profile", it means email is already done.
        // If we force an email step for such a user, the backend will return 400 "Invalid registration step".
        final rawMsg = (result['rawMessage'] ?? result['message'] ?? '').toString().toLowerCase();
        if (rawMsg.contains('profile') || rawMsg.contains('complete')) {
          nextStep = 'profile';
        } else {
          nextStep = 'email';
        }

        mobileOtpError = null;
        return true;
      }
 else if (result['status'] == 'not_found') {
        // Genuinely new user not in Firebase either — proceed to email
        nextStep = 'email';
        mobileOtpError = null;
        return true;
      } else {
        mobileOtpError = result['error'] ?? result['message'] ?? "Error verifying OTP";
        return false;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        mobileOtpError = "Incorrect OTP. Please check and try again.";
      } else {
        mobileOtpError = e.message ?? "Verification failed";
      }
      return false;
    } catch (e) {
       mobileOtpError = e.toString().replaceAll("Exception: ", "");
       return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String get timerText {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;

    if (minutes > 0) {
      if (remainingSeconds == 0) {
        return "$minutes min";
      }
      return "$minutes min $remainingSeconds sec";
    } else {
      return "$remainingSeconds sec";
    }
  }

  bool canResend = false;
  bool isResending = false;

  /// 🔁 RESEND OTP
  Future<void> resendOtp(BuildContext context) async {
    if (isResending) return;

    String mobile = context.read<SignUpScreenProvider>().mobileController.text;

    isResending = true;
    mobileOtpError = null;
    notifyListeners();

    try {
      final parent = context.read<SignUpScreenProvider>();

      await parent.resendOtp(
        mobile, 
        context, 
        () {
          startTimer(context);
        }
      );
    } catch (e) {
      mobileOtpError = "Failed to resend OTP";
    } finally {
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
