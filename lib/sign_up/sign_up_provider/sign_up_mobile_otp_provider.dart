import 'package:flutter/material.dart';

class SignUpMobileOtpProvider extends ChangeNotifier {

  TextEditingController mobileOtpController = TextEditingController();
  String? mobileOtpError;
  bool isMobileOtpValid = false;
  // constructor
  SignUpMobileOtpProvider(){
    mobileOtpController.addListener(checkMobileOtpFill); // 👈 listener
  }
  // realtime check for button enable
  void checkMobileOtpFill(){
    String value = mobileOtpController.text.trim();
    final mobileOtpRegex = RegExp(r'^\d{6}$');
    isMobileOtpValid = mobileOtpRegex.hasMatch(value);
    notifyListeners();
  }
  // final validation
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
  
}
