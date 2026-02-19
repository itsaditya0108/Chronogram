import 'package:flutter/material.dart';

class LoginMobileScreenProvider extends ChangeNotifier {

  TextEditingController mobileController = TextEditingController();

  String? mobileError;
  bool isMobileValid = false;

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
    } 
    else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      mobileError = "Only digits allowed";
    } 
    else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      mobileError = "Please enter a valid mobile number";
    } 
    else {
      mobileError = null;
    }

    notifyListeners();
    return mobileError == null;
  }

  @override
  void dispose() {
    mobileController.dispose();
    super.dispose();
  }
}
