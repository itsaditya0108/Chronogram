import 'package:chronogram/service/api_service.dart';
import 'package:chronogram/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
Future<bool> linkEmailApi(BuildContext context) async {
  if (!validateEmail()) return false;

  String mobile = context
      .read<SignUpScreenProvider>()
      .mobileController
      .text;

  String email = emailController.text.trim();

  bool success = await ApiService.linkEmail(
    mobile: mobile,
    email: email,
  );

  if (success) {
    print("EMAIL LINK SUCCESS");
    return true;
  } else {
    print("EMAIL LINK FAIL");
    return false;
  }
}

}