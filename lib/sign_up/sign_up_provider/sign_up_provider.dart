import 'package:flutter/material.dart';

class SignUpScreenProvider extends ChangeNotifier {
  TextEditingController mobileController = TextEditingController();
  String? mobileError;
  TextEditingController otpController = TextEditingController();
  String? otpError;

  bool validateMobile() {
    String value = mobileController.text.trim();
    if (value.isEmpty) {
      mobileError = "Mobile number is required";
    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      mobileError = "Only digits allowed";
    } else if (!RegExp(r'^6\d{0,9}$').hasMatch(value)) {
      // 6 se start aur max 10 digit
      mobileError = "Please enter a valid mobile number";
    } else if (value.length != 10) {
      mobileError = "Mobile number must be 10 digits";
    } else {
      mobileError = null;
    }
    notifyListeners();
    return mobileError == null;
  }

  bool validateOtp() {
    String value = otpController.text.trim();
    if (value.isEmpty) {
      otpError = 'Please enter OTP';
    } else if (!RegExp(r'^[0=9]+$').hasMatch(value)) {
      otpError = 'OTP must be ditits only';
    } else if (value.length != 6) {
      otpError = 'OTP must be 6 digits';
    } else {
      otpError = null;
    }
    notifyListeners();
    return otpError == null;
  }
}
