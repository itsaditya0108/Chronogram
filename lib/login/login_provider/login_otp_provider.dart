import 'dart:async';
import 'package:flutter/material.dart';
import '../../service/api_service.dart';
import '../../token_saver_helper/token_saver_helper.dart';

class LoginMobileOtpScreenProvider extends ChangeNotifier {

  TextEditingController mobileOtpController = TextEditingController();

  String? mobileOtpError;
  bool isMobileOtpValid = false;
  bool isLoading = false;

  /// TIMER
  int seconds = 120;
  Timer? _timer;
  bool canResend = false;
  bool isResending = false;

  LoginMobileOtpScreenProvider(){
    mobileOtpController.addListener(checkMobileOtpFill);
    startTimer();
  }

  /// OTP realtime validation
  void checkMobileOtpFill(){
    String value = mobileOtpController.text.trim();
    isMobileOtpValid = RegExp(r'^\d{6}$').hasMatch(value);
    notifyListeners();
  }

  bool validMobileOtp() {
    String value = mobileOtpController.text.trim();

    if (value.isEmpty) {
      mobileOtpError = 'Enter OTP';
    } 
    else if (value.length != 6) {
      mobileOtpError = 'OTP must be 6 digit';
    } 
    else {
      mobileOtpError = null;
    }

    notifyListeners();
    return mobileOtpError == null;
  }

  /// 🔥 VERIFY LOGIN OTP
  Future<bool> verifyLoginOtp(String mobile) async {

    if(!validMobileOtp()) return false;

    isLoading = true;
    notifyListeners();

    String otp = mobileOtpController.text.trim();

    final result = await ApiService.verifyLoginOtp(
      mobile: mobile,
      otp: otp,
    );

    isLoading = false;
    notifyListeners();

    if(result != null){

      String token = result["accessToken"];
      await TokenHelper.saveToken(token);

      print("LOGIN SUCCESS TOKEN: $token");

      return true;
    } else {
      mobileOtpError = "Invalid OTP";
      notifyListeners();
      return false;
    }
  }

  /// TIMER START
  void startTimer(){
    seconds = 120;
    canResend = false;

    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer){
      if(seconds > 0){
        seconds--;
        notifyListeners();
      } else {
        canResend = true;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  /// TIMER TEXT
  String get timerText {
    int minutes = seconds ~/ 60;
    int sec = seconds % 60;

    if(minutes > 0){
      if(sec == 0) return "$minutes min";
      return "$minutes min $sec sec";
    } else {
      return "$sec sec";
    }
  }

  /// 🔥 RESEND OTP
  Future<void> resendOtp(String mobile) async {

    if(isResending) return;

    isResending = true;
    notifyListeners();

    bool sent = await ApiService.resendOtp(mobile: mobile);

    isResending = false;

    if(sent){
      startTimer();
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