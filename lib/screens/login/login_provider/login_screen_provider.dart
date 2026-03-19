import 'dart:async';
import 'package:chronogram/app_helper/token_saver_helper/token_saver_helper.dart';
import 'package:chronogram/service/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginMobileScreenProvider extends ChangeNotifier {
  TextEditingController mobileController = TextEditingController();

DateTime? lastOtpSentTime;
String? lastOtpMobile;
static const int otpCooldown = 300; // 5 min
int get otpCooldownValue => otpCooldown; // Instance getter for providers

  String? mobileError;
  bool isMobileValid = false;
  bool isLoading = false;
  String? successMessage;
  
  String? verificationId;
  int? resendToken;

  String? autoRetrievedSmsCode;
  void Function(String)? onAutoRetrievedSmsCode;

  LoginMobileScreenProvider() {
    mobileController.addListener(checkMobileValid);
  }

  // ================= REAL-TIME MOBILE VALIDATION =================
  void checkMobileValid() {
    String value = mobileController.text.trim();
    // Indian industrial mobile regex (6-9 start + 10 digits)
    final mobileRegex = RegExp(r'^[6-9]\d{9}$');
    isMobileValid = mobileRegex.hasMatch(value);
    notifyListeners();
  }

  // ================= BUTTON CLICK VALIDATION =================
  bool validateMobile() {
    String value = mobileController.text.trim();

    if (value.isEmpty) {
      mobileError = "Mobile number is required";
    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      mobileError = "Only digits allowed";
    } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      mobileError = "Please enter a valid mobile number";
    } else {
      mobileError = null;
    }

    notifyListeners();
    return mobileError == null;
  }
////////
  void setError(String message) {
  mobileError = message;
  notifyListeners();

  Future.delayed(const Duration(seconds: 4), () {
    mobileError = null;
    notifyListeners();
  });
}

bool isCooldownActive(String mobile) {
  if (lastOtpSentTime == null) return false;
  if (lastOtpMobile != mobile) return false;
  final diff = DateTime.now().difference(lastOtpSentTime!).inSeconds;
  return diff < otpCooldown;
}

int remainingSeconds() {
  if (lastOtpSentTime == null) return 0;
  final diff = DateTime.now().difference(lastOtpSentTime!).inSeconds;
  return otpCooldown - diff;
}

////Api Method (Re-enabled Firebase Auth)
Future<bool> sendLoginOtp(String mobile, BuildContext context, VoidCallback onCodeSent) async {
  mobileError = null;
  isLoading = true;
  notifyListeners();
  
  try {
    // Step 1: Validate that the user exists in the database (skipSms = true so no backend SMS is sent)
    final backendResult = await ApiService.sendLoginOtp(mobile, skipSms: true);
    final statusCode = backendResult['statusCode'];

    // User not registered → stop here, show error
    if (statusCode == 404 || backendResult['status'] != 'success') {
      mobileError = backendResult['error'] ?? backendResult['message'] ?? "User not found. Please register.";
      isLoading = false;
      notifyListeners();
      return false;
    }

    // Step 2: User exists → now send OTP via Firebase
    Completer<bool> completer = Completer<bool>();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91$mobile",
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        if (credential.smsCode != null) {
          autoRetrievedSmsCode = credential.smsCode;
          if (onAutoRetrievedSmsCode != null) {
            onAutoRetrievedSmsCode!(credential.smsCode!);
          }
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        isLoading = false;
        mobileError = e.message ?? "Verification Failed";
        notifyListeners();
        if (!completer.isCompleted) completer.complete(false);
      },
      codeSent: (String verId, int? resendTokenId) {
        verificationId = verId;
        resendToken = resendTokenId;
        lastOtpSentTime = DateTime.now();
        lastOtpMobile = mobile;
        isLoading = false;
        notifyListeners();
        onCodeSent();
        if (!completer.isCompleted) completer.complete(true);
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
      forceResendingToken: resendToken,
    );

    return await completer.future;
  } catch (e) {
    isLoading = false;
    mobileError = "Failed to send OTP";
    notifyListeners();
    return false;
  }
}


  @override
  void dispose() {
    mobileController.dispose();
    super.dispose();
  }
  void showErrorTemporarily(String message) {
    mobileError = message;
    notifyListeners();
    Future.delayed(const Duration(seconds: 7), () {
      mobileError = null;
      notifyListeners();
    });
  }

  void clearState() {
    mobileController.clear();
    lastOtpSentTime = null;
    mobileError = null;
    isMobileValid = false;
    successMessage = null;
    verificationId = null;
    resendToken = null;
    autoRetrievedSmsCode = null;
    onAutoRetrievedSmsCode = null;
    notifyListeners();
  }
}
