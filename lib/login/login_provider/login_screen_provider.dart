// import 'package:flutter/material.dart';

// class LoginScreenProvider extends ChangeNotifier {

//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   /// Dynamic Fields List
//   List<Map<String, dynamic>> get loginScreenList => [
    
//         {
//           'title': 'Email',
//           'controller': emailController,
//           'icon': const Icon(Icons.email_outlined),
//         },
//         {
//           'title': 'Password',
//           'controller': passwordController,
//           'icon': const Icon(Icons.lock_outline),
//         },
//       ];

//   // ==============================
//   // 🔥 COMPANY LEVEL VALIDATOR
//   // ==============================
//   String? loginValidator(String field, String? value) {
//   if (value == null || value.trim().isEmpty) {
//     return "Please enter $field";
//   }

//   final input = value.trim();

//   // ================= EMAIL VALIDATION =================
//   if (field == "Email") {

//     // only small letters + number + @gmail.com
//     final emailRegex = RegExp(
//       r'^[a-z0-9]+[a-z0-9]*@gmail\.com$',
//     );

//     if (RegExp(r'[A-Z]').hasMatch(input)) {
//       return "Capital letters not allowed";
//     }

//     if (!emailRegex.hasMatch(input)) {
//       return "Enter valid gmail (example: abcd123@gmail.com)";
//     }

//     if (!input.endsWith("@gmail.com")) {
//       return "Email must end with @gmail.com";
//     }

//   }

//   // ================= PASSWORD VALIDATION =================
//   if (field == "Password") {

//     if (input.length > 25) {
//       return "Password max 25 characters only";
//     }

//     final passwordRegex = RegExp(
//       r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[@#\$&*])(?=.*[0-9])[A-Za-z0-9@#\$&*]{5,25}$',
//     );

//     if (!passwordRegex.hasMatch(input)) {
//       return "Password like Abcd#123 required";
//     }
//   }

//   return null;
// }

//   // ================= EMAIL VALIDATOR =================
//   String? _emailValidator(String email) {

//     final emailRegex = RegExp(
//       r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$",
//     );

//     if (!emailRegex.hasMatch(email)) {
//       return "Please enter a valid email address";
//     }

//     return null;
//   }

//   // ================= PASSWORD VALIDATOR =================
//   String? _passwordValidator(String password) {

//     if (password.length < 8) {
//       return "Password must be at least 8 characters";
//     }

//     if (!RegExp(r'[A-Z]').hasMatch(password)) {
//       return "Include at least 1 uppercase letter";
//     }

//     if (!RegExp(r'[a-z]').hasMatch(password)) {
//       return "Include at least 1 lowercase letter";
//     }

//     if (!RegExp(r'[0-9]').hasMatch(password)) {
//       return "Include at least 1 number";
//     }

//     if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
//       return "Include at least 1 special character";
//     }

//     return null;
//   }

//   // ================= GET LOGIN DATA =================
//   Map<String, String> getLoginData() {
//     return {
//       "email": emailController.text.trim(),
//       "password": passwordController.text.trim(),
//     };
//   }

//   // ================= CLEAR =================
//   void clearLogin() {
//     emailController.clear();
//     passwordController.clear();
//     notifyListeners();
//   }
// }
