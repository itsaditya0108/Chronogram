import 'package:chronogram/login/login_provider/login_screen_provider.dart';
import 'package:chronogram/login/login_screen/login_screen.dart';
import 'package:chronogram/sign_up/sign_up_provider/sign_up_provider.dart';
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
        ChangeNotifierProvider(create: (_)=>LoginScreenProvider()),
       ChangeNotifierProvider(create: (_)=>SignUpScreenProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          
          colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        ),
        home: LoginScreen()
             // SignUpScreen()
            
      ),
    );
  }
}