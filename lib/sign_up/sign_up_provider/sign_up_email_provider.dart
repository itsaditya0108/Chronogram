import 'package:chronogram/service/api_service.dart';
import 'package:flutter/material.dart';

class SignUpEmailProvider extends ChangeNotifier {

  TextEditingController emailController = TextEditingController();
  String? emailError;
  bool isEmailValid = false;

  SignUpEmailProvider() {
    emailController.addListener(validateEmail);
  }

  bool validateEmail() {
    String input = emailController.text.trim();

    // secure gmail regex
    final emailRegex = RegExp(
      r'^[a-z0-9](?!.*\.\.)[a-z0-9._%+-]{2,}@[g][m][a][i][l]\.[c][o][m]$'
    );

    if (input.isEmpty) {
      emailError = "Email is required";
      isEmailValid = false;
    }

    /// No spaces allowed
    else if (input.contains(" ")) {
      emailError = "Spaces not allowed";
      isEmailValid = false;
    }

    /// Capital letters not allowed
    else if (RegExp(r'[A-Z]').hasMatch(input)) {
      emailError = "Capital letters not allowed";
      isEmailValid = false;
    }

    /// Dot at start
    else if (input.startsWith(".")) {
      emailError = "Dot cannot be at beginning";
      isEmailValid = false;
    }

    /// Dot before @
    else if (input.contains(".@")) {
      emailError = "Dot not allowed before @";
      isEmailValid = false;
    }

    /// Double dot
    else if (input.contains("..")) {
      emailError = "Double dots not allowed";
      isEmailValid = false;
    }

    /// Must end with gmail
    else if (!input.endsWith("@gmail.com")) {
      emailError = "Email must end with @gmail.com";
      isEmailValid = false;
    }

    /// Final regex validation
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

  Future<bool> linkEmailApi(BuildContext context) async {
    if (!validateEmail()) return false;

    String email = emailController.text.trim();

    bool success = await ApiService.sendEmailOtp(
      email: email,
    );

    if (success) {
      print("EMAIL OTP SENT SUCCESS");
      return true;
    } else {
      print("EMAIL OTP FAILED");
      return false;
    }
  }
}
