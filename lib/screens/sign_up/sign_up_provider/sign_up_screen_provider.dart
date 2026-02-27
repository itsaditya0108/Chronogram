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
void clearMobile() {
  mobileController.clear();
  mobileError = null;
  isMobileValid = false;
  notifyListeners();
}
  Future<String> sendOtp(String mobile) async {
    mobileError = null;
    notifyListeners();
    final result = await ApiService.sendOtp(mobile);
    /// ❌ OTHER ERROR
    if (result["status"] != "success") {
      showErrorTemporarily(result['error']);
      return "error";
    }
    return "success";
  }

  //auto-hide logic add karo for user already exists error after 3 seconds
  void showErrorTemporarily(String message) {
    mobileError = message;
    notifyListeners();
    Future.delayed(const Duration(seconds: 7), () {
      mobileError = null;
      notifyListeners();
    });
  }
}
