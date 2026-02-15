import 'package:chronogram/login/login_helper/aseet_helper.dart';
import 'package:chronogram/login/login_provider/login_screen_provider.dart';
import 'package:chronogram/login/login_screen/login_screen.dart';
import 'package:chronogram/sign_up/sign_up_screen/sign_up_email_otp.dart';
import 'package:chronogram/sign_up/sign_up_screen/sign_up_mobile_otp.dart';
import 'package:chronogram/sign_up/sign_up_provider/sign_up_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class SignUpEmailScreen extends StatefulWidget {
  const SignUpEmailScreen({super.key});
  @override
  State<SignUpEmailScreen> createState() => _SignUpEmailScreenState();
}

class _SignUpEmailScreenState extends State<SignUpEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(ScreenImage.loginBg),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(35, 150, 35, 0),
                child: Column(
                  children: [
                    Center(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(ScreenImage.allLogoBr, height: 120),
                            SizedBox(height: 20),
                            Text(
                              'Chronogram',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 15),
                            Text(
                              'Enter your email id for verification',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 15),
                            Consumer<SignUpScreenProvider>(
                              builder: (context, value, child) {
                                return TextFormField(
                                  controller: value
                                      .emailController, // This is the importaint line
                                  keyboardType: TextInputType.emailAddress,

                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Enter your email",
                                    errorText: value.emailError,

                                    /// 📱 icon
                                    prefixIcon: Container(
                                      child: const Icon(
                                        Icons.email,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xff1D61E7),
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white38,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                      horizontal: 10,
                                    ),
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: 30),
                            InkWell(
                              onTap: () {
                                final provider = context
                                    .read<SignUpScreenProvider>();
                                if (provider.validateEmail()) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SignUpEmailOtpScreen(),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Color(0XFF1D61E7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
