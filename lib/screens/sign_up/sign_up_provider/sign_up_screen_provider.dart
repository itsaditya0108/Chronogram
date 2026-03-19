import 'dart:async';

import 'package:chronogram/service/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreenProvider extends ChangeNotifier {
  TextEditingController mobileController = TextEditingController();
  String? mobileError;
  bool isMobileValid = false;
  bool isLoading = false;
  
  String? verificationId;
  int? resendToken;

  String? autoRetrievedSmsCode;
  void Function(String)? onAutoRetrievedSmsCode;

  DateTime? lastOtpSentTime;
  String? lastOtpMobile;
  static const int otpCooldown = 300; // 5 min
  int get otpCooldownValue => otpCooldown; // Instance getter for providers
  // Mobile Validation (realtime)
  void checkMobileValid() {
    String value = mobileController.text.trim();
    final mobileRegex = RegExp(r'^[6-9]\d{9}$');
    isMobileValid = mobileRegex.hasMatch(value);
    notifyListeners();
  }

  bool validateMobile() {
    String value = mobileController.text.trim();
    if (value.isEmpty) {
      mobileError = "Mobile number is required";
    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      mobileError = "Only digits allowed";
    } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      // 6,7,8,9 se start aur total 10 digit
      mobileError = "Please enter a valid mobile number";
    } else {
      mobileError = null;
    }
    notifyListeners();
    return mobileError == null;
  }

  void clearMobile() {
    mobileController.clear();
    mobileError = null;
    isMobileValid = false;
    notifyListeners();
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

  Future<bool> sendOtp(String mobile, BuildContext context, VoidCallback onCodeSent) async {
    mobileError = null;
    isLoading = true;
    notifyListeners();
    
    try {
      // Step 1: Validate that the user is NOT already registered (skipSms = true so no backend SMS is sent)
      final backendResult = await ApiService.sendOtp(mobile, skipSms: true);
      final statusCode = backendResult['statusCode'];

      // User already registered → stop here, show error
      if (statusCode == 409 || backendResult['status'] != 'success') {
        mobileError = backendResult['error'] ?? backendResult['message'] ?? "This number is already registered. Please login instead.";
        isLoading = false;
        notifyListeners();
        return false;
      }

      // Step 2: Number is free → now send OTP via Firebase
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

  //auto-hide logic add karo for user already exists error after 3 seconds
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
    lastOtpMobile = null;
    mobileError = null;
    isMobileValid = false;
    verificationId = null;
    resendToken = null;
    autoRetrievedSmsCode = null;
    onAutoRetrievedSmsCode = null;
    notifyListeners();
  }

  /// 🔁 RESEND OTP (Firebase Direct)
  Future<void> resendOtp(String mobile, BuildContext context, VoidCallback onCodeSent) async {
    mobileError = null;
    isLoading = true;
    notifyListeners();

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+91$mobile",
        timeout: const Duration(seconds: 60),
        forceResendingToken: resendToken,
        verificationCompleted: (PhoneAuthCredential credential) {
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
        },
        codeSent: (String verId, int? resendTokenId) {
          verificationId = verId;
          resendToken = resendTokenId;
          lastOtpSentTime = DateTime.now();
          lastOtpMobile = mobile;
          isLoading = false;
          notifyListeners();
          onCodeSent();
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
      );
    } catch (e) {
      isLoading = false;
      mobileError = "Failed to resend OTP";
      notifyListeners();
    }
  }
}
