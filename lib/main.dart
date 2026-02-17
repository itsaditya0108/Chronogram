import 'package:chronogram/home_screen/home_screen.dart';
import 'package:chronogram/login/login_provider/login_screen_provider.dart';
import 'package:chronogram/login/login_screen/login_screen.dart';
import 'package:chronogram/sign_up/sign_up_provider/sign_up_email_otp_provider.dart';
import 'package:chronogram/sign_up/sign_up_provider/sign_up_email_provider.dart';
import 'package:chronogram/sign_up/sign_up_provider/sign_up_mobile_otp_provider.dart' hide SignUpEmailOtpProvider;
import 'package:chronogram/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:chronogram/sign_up/sign_up_screen/sign_up_email_otp.dart';
import 'package:chronogram/sign_up/sign_up_screen/sign_up_screen.dart';
import 'package:chronogram/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignUpScreenProvider()),//
        ChangeNotifierProvider(create: (_) => SignUpEmailProvider()),//
        ChangeNotifierProvider(create: (_) => SignUpMobileOtpProvider()),//
        ChangeNotifierProvider(create: (_) => SignUpEmailOtpProvider()),//
        ChangeNotifierProvider(create: (_) => LoginScreenProvider()),//
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
        home: // LoginScreen()
            SignUpScreen(),
          // HomeScreen(),
      ),
    );
  }
}
