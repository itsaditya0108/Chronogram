import 'package:flutter/material.dart';

class LoginScreenProvider extends ChangeNotifier {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  //// List For DynamicFiles

  List<Map<String, dynamic>> get loginScreenList => [
    {
      'title': 'Email',
      'controller': emailController,
      'icon': Icon(Icons.email),
    },
    {
      'title': 'Password',
      'controller': passwordController,
      'icon': Icon(Icons.lock),
    },
  ];

  ////LiginScreen Validator Function

  String? loginScreenValidator(String title, String? value) {
  if (value == null || value.trim().isEmpty) {
    return '$title is required';
  }

  final input = value.trim();

  /// EMAIL VALIDATION
  if (title == 'Email') {
    final emailRegex = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(input)) {
      return "Enter valid email";
    }
  }

  /// MOBILE VALIDATION (INDIA)
  if (title == 'Mobile') {
    final mobileRegex = RegExp(r'^[6-9]\d{9}$');

    if (!mobileRegex.hasMatch(input)) {
      return "Enter valid mobile number";
    }
  }

  /// PASSWORD VALIDATION
  if (title == 'Password') {
    if (input.length < 8) {
      return "Password must be at least 8 characters";
    }

    if (!RegExp(r'[A-Z]').hasMatch(input)) {
      return "Include at least 1 capital letter";
    }

    if (!RegExp(r'[0-9]').hasMatch(input)) {
      return "Include at least 1 number";
    }

    if (!RegExp(r'[!@#\$&*~]').hasMatch(input)) {
      return "Include at least 1 special character";
    }
  }

  return null;
}

}
