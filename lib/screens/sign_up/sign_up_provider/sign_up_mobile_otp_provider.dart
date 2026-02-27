import 'dart:async';
import 'package:chronogram/service/api_service.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:chronogram/app_helper/token_saver_helper/token_saver_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpMobileOtpProvider extends ChangeNotifier {
  TextEditingController mobileOtpController = TextEditingController();
  String? mobileOtpError;
  bool isMobileOtpValid = false;

  /// 🔥 TIMER
  int seconds = 120;
  Timer? _timer;

  /// constructor
  SignUpMobileOtpProvider() {
    mobileOtpController.addListener(checkMobileOtpFill);
    // start when screen open
  }

  void init() {
    mobileOtpError = null;
    isMobileOtpValid = false;
    // String? maskedEmail; // for new device

    canResend = false;
    isResending = false;
    startTimer();
  }

  /// realtime check for button enable
  void checkMobileOtpFill() {
    String value = mobileOtpController.text.trim();
    final mobileOtpRegex = RegExp(r'^\d{6}$');
    isMobileOtpValid = mobileOtpRegex.hasMatch(value);
    notifyListeners();
  }

  /// 🔥 TIMER START
  void startTimer() {
    seconds = 120;
    canResend = false;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds > 0) {
        seconds--;
        notifyListeners();
      } else {
        timer.cancel();
        canResend = true; // 🔥 enable resend
        notifyListeners();
      }
    });
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

    String mobile = context.read<SignUpScreenProvider>().mobileController.text;

    String otp = mobileOtpController.text.trim();

    final result = await ApiService.verifyOtp(mobile: mobile, otp: otp);

    if (result?["accessToken"] != null) {
      String token = result?["accessToken"];
      await TokenHelper.saveRegistrationToken(token);

      print("TOKEN SAVED: $token");
      return true;
    } else {
      mobileOtpError = result?['error'];
      notifyListeners();
      return false;
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
    if (!canResend) return;

    String mobile = context.read<SignUpScreenProvider>().mobileController.text;

    isResending = true;
    notifyListeners();

    bool success = await ApiService.resendOtp(mobile: mobile);

    isResending = false;

    if (success) {
      startTimer(); // 🔥 timer restart
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    mobileOtpController.dispose();
    super.dispose();
  }
}
