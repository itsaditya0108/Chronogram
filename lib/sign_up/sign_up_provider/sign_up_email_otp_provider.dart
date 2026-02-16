import 'package:flutter/material.dart';

class SignUpEmailOtpProvider extends ChangeNotifier {
  
  TextEditingController emailOtpController = TextEditingController();
  String? emailOtpError;
  bool isEmailOtpValid = false;
  // constructor
  SignUpEmailOtpProvider(){
   emailOtpController.addListener(checkEmailOtpFill); // 👈 listener
  }
  // realtime check for button enable
  void checkEmailOtpFill(){
    String value = emailOtpController.text.trim();
    final emailOtpRegex = RegExp(r'^\d{6}$');
    isEmailOtpValid = emailOtpRegex.hasMatch(value);
    notifyListeners();
  }
  
  // final validation
  bool validEmailOtp() {
    String value = emailOtpController.text.trim();
    if (value.isEmpty) {
     emailOtpError = 'Please enter OTP';
    } 
    else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      emailOtpError = 'OTP must be digits only';
    } 
    else if (value.length != 6) {
      emailOtpError = 'OTP must be 6 digits';
    } 
    else {
      emailOtpError = null;
    }
    notifyListeners();
    return emailOtpError == null;
  }
  
}
