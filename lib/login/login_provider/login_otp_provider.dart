import 'package:flutter/material.dart';

class LoginMobileOtpScreenProvider extends ChangeNotifier {

  TextEditingController mobileOtpController = TextEditingController();

  String? mobileOtpError;
  bool isMobileOtpValid = false;

  // constructor
  LoginMobileOtpScreenProvider(){
    mobileOtpController.addListener(checkMobileOtpFill);
  }

  // ================= REALTIME OTP VALIDATION =================
  void checkMobileOtpFill(){
    String value = mobileOtpController.text.trim();

    // 6 digit industrial OTP regex
    final mobileOtpRegex = RegExp(r'^\d{6}$');

    isMobileOtpValid = mobileOtpRegex.hasMatch(value);
    notifyListeners();
  }

  // ================= FINAL BUTTON VALIDATION =================
  bool validMobileOtp() {
    String value = mobileOtpController.text.trim();

    if (value.isEmpty) {
      mobileOtpError = 'Please enter OTP';
    } 
    else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      mobileOtpError = 'OTP must be digits only';
    } 
    else if (value.length != 6) {
      mobileOtpError = 'OTP must be 6 digits';
    } 
    else {
      mobileOtpError = null;
    }

    notifyListeners();
    return mobileOtpError == null;
  }

  @override
  void dispose() {
    mobileOtpController.dispose();
    super.dispose();
  }
}
