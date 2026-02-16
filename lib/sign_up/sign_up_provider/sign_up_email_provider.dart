import 'package:flutter/material.dart';

class SignUpEmailProvider extends ChangeNotifier{

TextEditingController emailController = TextEditingController();
String? emailError;
bool isEmailValid = false;

SignUpEmailProvider(){
  emailController.addListener(validateEmail);
}

  bool validateEmail() {
    String input = emailController.text.trim();
    final emailRegex = RegExp(r'^[a-z0-9]+@gmail\.com$');
    if (input.isEmpty) {
      emailError = "Email is required";
      isEmailValid = false;
    } else if (RegExp(r'[A-Z]').hasMatch(input)) {
      emailError = "Capital letters not allowed";
      isEmailValid = false;
    } else if (!emailRegex.hasMatch(input)) {
      emailError = "Enter valid gmail (example: abcd123@gmail.com)";
      isEmailValid = false;
    } else if (!input.endsWith("@gmail.com")) {
      emailError = "Email must end with @gmail.com";
      isEmailValid = false;
    } else {
      emailError = null;
      isEmailValid = true; //Most Important
    }
    notifyListeners();
    return emailError == null;
  } 

}