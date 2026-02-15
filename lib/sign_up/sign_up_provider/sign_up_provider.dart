import 'package:flutter/material.dart';

class SignUpScreenProvider extends ChangeNotifier {
  TextEditingController mobileController = TextEditingController();
  String? mobileError;
  TextEditingController otpController = TextEditingController();
  String? otpError;
TextEditingController emailController = TextEditingController();
String? emailError;

  bool validateMobile() {
  String value = mobileController.text.trim();
  if (value.isEmpty) {
    mobileError = "Mobile number is required";
  } 
  else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
    mobileError = "Only digits allowed";
  }
  else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
    // 6,7,8,9 se start aur total 10 digit
    mobileError = "Please enter a valid mobile number";
  }
  else {
    mobileError = null;
  }

  notifyListeners();
  return mobileError == null;
}


  bool validateOtp() {
  String value = otpController.text.trim();

  if (value.isEmpty) {
    otpError = 'Please enter OTP';
  } 
  else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {   // fix here
    otpError = 'OTP must be digits only';
  } 
  else if (value.length != 6) {
    otpError = 'OTP must be 6 digits';
  } 
  else {
    otpError = null;
  }

  notifyListeners();
  return otpError == null;
}


bool validateEmail() {
  String input = emailController.text.trim();

  final emailRegex = RegExp(r'^[a-z0-9]+@gmail\.com$');

  if (input.isEmpty) {
    emailError = "Email is required";
  }
  else if (RegExp(r'[A-Z]').hasMatch(input)) {
    emailError = "Capital letters not allowed";
  }
  else if (!emailRegex.hasMatch(input)) {
    emailError = "Enter valid gmail (example: abcd123@gmail.com)";
  }
  else if (!input.endsWith("@gmail.com")) {
    emailError = "Email must end with @gmail.com";
  }
  else {
    emailError = null;
  }

  notifyListeners();
  return emailError == null;
}



}
