import 'dart:async';
import 'package:chronogram/screens/home_screen/home_screen.dart';
import 'package:chronogram/screens/login/login_screen/login_new_device_email_screen.dart';
import 'package:chronogram/app_helper/mask/email_mask/email_mask.dart';
import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../service/api_service.dart';
import '../../../app_helper/token_saver_helper/token_saver_helper.dart';
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
  // String? maskedEmail; // for new device

  /// TIMER
  int seconds = 300;
  Timer? _timer;
  bool canResend = false;
  bool isResending = false;

  LoginMobileOtpScreenProvider() {
    mobileOtpController.addListener(checkMobileOtpFill);
    // startTimer() removed - will be called in init() with BuildContext
  }

  /// OTP realtime validation
  void checkMobileOtpFill() {
    String value = mobileOtpController.text.trim();
    isMobileOtpValid = RegExp(r'^\d{6}$').hasMatch(value);
    notifyListeners();
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
    mobileOtpError = null;
    notifyListeners();

    final result = await ApiService.verifyLoginOtp(
      mobile: mobile,
      otp: mobileOtpController.text.trim(),
    );

    isLoading = false;

    /// ✅ LOGIN SUCCESS
    if (result["status"] == "success") {
      await TokenHelper.saveToken(result["token"]);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
    /// 🔥 NEW DEVICE (401)
    else if (result["status"] == "untrusted") {
      maskedEmail = result["maskedEmail"];
      temporaryToken = result['temporaryToken'] ?? "";
      print('Temp Token From 401:c $temporaryToken');
      mobileOtpError = "New device detected. Verify email to continue";

      showVerifyEmailButton = true;
      notifyListeners();

    }
    /// 🔴 USER NOT REGISTERED
    else if (result["status"] == "not_found") {
      mobileOtpError = "Mobile number is not registered. Please register first";

      showRegisterButton = true;
      notifyListeners();
    }
    /// ❌ INVALID OTP
    else {
      mobileOtpError = result['error'] ?? result['message'] ?? "Invalid OTP";
      notifyListeners();
    }
  }

  void init(BuildContext context) {
    temporaryToken = "";
    maskedEmail = "";
    mobileOtpError;
    isMobileOtpValid = false;
    isLoading = false;

    showRegisterButton = false;
    showVerifyEmailButton = false;
    // String? maskedEmail; // for new device

    canResend = false;
    isResending = false;
    startTimer(context);
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

  /// 🔥 RESEND OTP
  Future<void> resendLoginOtp(String mobile, BuildContext context) async {
    if (isResending) return;

    isResending = true;
    notifyListeners();

    bool sent = await ApiService.resendLoginOtp(mobile: mobile);

    isResending = false;

    if (sent) {
      // Sync with LoginMobileScreenProvider cooldown
      final mainProvider = context.read<LoginMobileScreenProvider>();
      mainProvider.lastOtpSentTime = DateTime.now();
      mainProvider.lastOtpMobile = mobile;
      
      startTimer(context);
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
