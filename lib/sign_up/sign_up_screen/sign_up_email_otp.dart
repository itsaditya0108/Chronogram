import 'dart:math';
import 'package:chronogram/buttons/buttons.dart';

import 'package:chronogram/home_screen/home_screen.dart';
import 'package:chronogram/login/login_helper/aseet_helper.dart';
import 'package:chronogram/login/login_provider/login_screen_provider.dart';
import 'package:chronogram/login/login_screen/login_screen.dart';
import 'package:chronogram/mask/email_mask/email_mask.dart';
import 'package:chronogram/sign_up/sign_up_provider/sign_up_email_otp_provider.dart';
import 'package:chronogram/sign_up/sign_up_provider/sign_up_email_provider.dart';
import 'package:chronogram/sign_up/sign_up_screen/sign_up_email_screen.dart';
import 'package:chronogram/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class SignUpEmailOtpScreen extends StatefulWidget {
  const SignUpEmailOtpScreen({super.key, required this.email, });
 final String email; 
  @override
  State<SignUpEmailOtpScreen> createState() => _SignUpEmailOtpScreenState();
}

class _SignUpEmailOtpScreenState extends State<SignUpEmailOtpScreen> {
  List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent),
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
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  children: [
                    SizedBox(height: 300),
                    Center(
                      child: Form(
                        key: _formKey,

                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'We’ve sent a verification code to your email',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            ),
                           
                            SizedBox(height: 10),
                            Consumer<SignUpEmailOtpProvider>(
                              builder: (context, provider, child) {
                                return Column(
                                  children: [
                                     Text(EmailMask.maskEmail(widget.email)),
                                   
                                    SizedBox(height: 20),
                                    OtpTextField(
                                      numberOfFields: 6,
                                      fieldWidth: 50,
                                      fieldHeight: 60,
                                      borderRadius: BorderRadius.circular(12),
                                      showFieldAsBox: true,
                                      filled: true,
                                      fillColor: Colors.white38,

                                      // Sirf Number KeyBoard
                                      keyboardType: TextInputType.number,

                                      //Only Digits Allowed
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      // border colors
                                      borderColor: Colors.grey.shade300,
                                      focusedBorderColor: const Color(
                                        0xFF1D61E7,
                                      ),
                                      enabledBorderColor: Colors.grey.shade300,
                                      // cursor
                                      cursorColor: const Color(0xFF1D61E7),
                                      // spacing
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      // text style
                                      textStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      // typing time
                                      onCodeChanged: (code) {
                                        provider.emailOtpController.text = code;
                                        
                                      },
                                      onSubmit: (verificationCode) {
                                        provider.emailOtpController.text =
                                            verificationCode;
                                        provider.validEmailOtp();
                                      },
                                    ),
                                    SizedBox(height: 10),
                                    if (provider.emailOtpError != null)
                                      Text(
                                        provider.emailOtpError!,
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 13,
                                        ),
                                      ),
                                  ],
                                ); // Mask Numbe Showe Here
                              },
                            ),
                            SizedBox(height: 30),
                            Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: () {},
                                  child: Text(
                                    ' Resend OTP',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(height: 30),
                            Consumer<SignUpEmailOtpProvider>(
                              builder: (context, value, child) {
                                return AppButton(
                                  title: 'Continue',
                                  onTap:
                                      value
                                          .isEmailOtpValid // only bool check
                                      ? () {
                                          if (value.validEmailOtp()) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    HomeScreen(),
                                              ),
                                            );
                                          }
                                        }
                                      : null,
                                );
                              },
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

  // String maskEmail(String email) {
  //   if (email.isEmpty) return "";

  //   List parts = email.split("@");

  //   if (parts.length != 2) return email;

  //   String name = parts[0];
  //   String domain = parts[1];

  //   if (name.length <= 2) {
  //     return "$name****@$domain";
  //   }

  //   String firstTwo = name.substring(0, 2);
  //   return "$firstTwo****@$domain";
  // }
  
}
