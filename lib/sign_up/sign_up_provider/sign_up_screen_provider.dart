import 'package:chronogram/service/api_service.dart';
import 'package:flutter/material.dart';

class SignUpScreenProvider extends ChangeNotifier {
  TextEditingController mobileController = TextEditingController();
  String? mobileError;
  bool isMobileValid = false;
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

  Future<bool> sendOtp(String mobile) async {
     bool success = await ApiService.sendOtp(mobile);
     return success;
  }


}
