import 'package:chronogram/screens/home_screen/home_screen.dart';
import 'package:chronogram/screens/login/login_provider/login_otp_provider.dart';
import 'package:chronogram/screens/login/login_provider/login_screen_provider.dart';
import 'package:chronogram/screens/login/login_screen/login_screen.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_email_otp_provider.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_email_provider.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_mobile_otp_provider.dart'
    hide SignUpEmailOtpProvider;
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_email_otp.dart';
import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_mobile_otp.dart';
import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_profile_screen.dart';
import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_screen.dart';
import 'package:chronogram/screens/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignUpScreenProvider()), //
        ChangeNotifierProvider(create: (_) => SignUpEmailProvider()), //
        ChangeNotifierProvider(create: (_) => SignUpMobileOtpProvider()), //
        ChangeNotifierProvider(create: (_) => SignUpEmailOtpProvider()), //
        ChangeNotifierProvider(create: (_) => LoginMobileScreenProvider()), //
        ChangeNotifierProvider(
          create: (_) => LoginMobileOtpScreenProvider(),
        ), //
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
        navigatorKey: navigatorKey,
        home: SignUpScreen(),
        // HomeScreen(),
        //  LoginMobileScreen()
        //  SignUpProfileScreen()
      ),
    );
  }
}
