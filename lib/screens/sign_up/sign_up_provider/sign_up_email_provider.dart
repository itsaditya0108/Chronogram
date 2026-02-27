import 'package:chronogram/app_helper/token_saver_helper/token_saver_helper.dart';
import 'package:chronogram/service/api_service.dart';
import 'package:flutter/material.dart';

class SignUpEmailProvider extends ChangeNotifier {
  TextEditingController emailController = TextEditingController();
  String? emailError;
  bool isEmailValid = false;

  SignUpEmailProvider() {
    emailController.addListener(() {
      if (emailController.text.isNotEmpty) {
        validateEmail();
      } else {
        emailError = null;
        isEmailValid = false;
        notifyListeners();
      }
    });
  }

 bool validateEmail() {
  String input = emailController.text.trim();

  final emailRegex = RegExp(
    r'^[a-zA-Z0-9](?!.*\.\.)[a-zA-Z0-9._%+-]{2,}@[gG][mM][aA][iI][lL]\.[cC][oO][mM]$'
  );

  if (input.isEmpty) {
    emailError = null;
    isEmailValid = false;
  }

  else if (input.contains(" ")) {
    emailError = "Spaces not allowed";
    isEmailValid = false;
  }

  else if (input.startsWith(".")) {
    emailError = "Dot cannot be at beginning";
    isEmailValid = false;
  }

  else if (input.contains(".@")) {
    emailError = "Dot not allowed before @";
    isEmailValid = false;
  }

  else if (input.contains("..")) {
    emailError = "Double dots not allowed";
    isEmailValid = false;
  }

  else if (!input.toLowerCase().endsWith("@gmail.com")) {
    emailError = "Email must end with @gmail.com";
    isEmailValid = false;
  }

  else if (!emailRegex.hasMatch(input)) {
    emailError = "Enter valid gmail (example: abcd123@gmail.com)";
    isEmailValid = false;
  }

  else {
    emailError = null;
    isEmailValid = true;
  }

  notifyListeners();
  return emailError == null;
}
  
Future<String> linkEmailApi() async {
  if (!validateEmail()) return "invalid";
  String email = emailController.text.trim();
  final result = await ApiService.sendEmailOtp(email: email);

  /// 🟢 SUCCESS
  if (result["accessToken"] != null) {
      final token = result['accessToken'];
      TokenHelper.saveRegistrationToken(token);
      return 'success';
  }
  emailError = result['message'];
  notifyListeners();
  return "message";
}
////// For Email Edit 
  void clearEmail() {
  emailController.clear();
  emailError = null;
  isEmailValid = false;
  notifyListeners();
}
}
