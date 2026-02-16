import 'dart:math';
import 'package:chronogram/mask/mobile_mask/mobile_mask.dart';
import 'package:chronogram/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:chronogram/buttons/buttons.dart';
import 'package:chronogram/login/login_helper/aseet_helper.dart';
import 'package:chronogram/login/login_provider/login_screen_provider.dart';
import 'package:chronogram/login/login_screen/login_screen.dart';
import 'package:chronogram/sign_up/sign_up_provider/sign_up_email_provider.dart';
import 'package:chronogram/sign_up/sign_up_provider/sign_up_mobile_otp_provider.dart';
import 'package:chronogram/sign_up/sign_up_screen/sign_up_email_screen.dart';
import 'package:chronogram/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class SignUpMobileOtpScreen extends StatefulWidget {
  const SignUpMobileOtpScreen({super.key});
  @override
  State<SignUpMobileOtpScreen> createState() => _SignUpMobileOtpScreenState();
}

class _SignUpMobileOtpScreenState extends State<SignUpMobileOtpScreen> {
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
                              'Enter the OTP sent to your mobile number',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 15),
                            Consumer<SignUpMobileOtpProvider>(
                              builder: (context, provider, child) {
                                return Column(
                                  children: [
                                    Text(
                                      MobileMask().maskNumber(
                                        context.read<SignUpScreenProvider>().mobileController.text
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    OtpTextField(
                                      numberOfFields: 6,
                                      fieldWidth: 50,
                                      fieldHeight: 60,
                                      borderRadius: BorderRadius.circular(12),
                                      showFieldAsBox: true,
                                      filled: true,
                                      fillColor: Colors.white38,
                                      borderColor: Colors.grey.shade300,
                                      focusedBorderColor: const Color(
                                        0xFF1D61E7,
                                      ),

                                      enabledBorderColor: Colors.grey.shade300,
                                      cursorColor: const Color(0xFF1D61E7),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      keyboardType: TextInputType.number,
                                      // ❌ typing pe validation mat lagao
                                      onCodeChanged: (code) {
                                        provider.mobileOtpController.text =
                                            code;
                                        // provider.validMobileOtp();
                                      },

                                      // ✅ complete hone pe validation
                                      onSubmit: (verificationCode) {
                                        provider.mobileOtpController.text =
                                            verificationCode;

                                        provider.validMobileOtp();
                                      },
                                    ),

                                    SizedBox(height: 10),
                                    if (provider.mobileOtpError != null)
                                      Text(
                                        provider.mobileOtpError!,
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
                            Consumer<SignUpMobileOtpProvider>(
                              builder: (context, value, child) {
                                return AppButton(
                                  title: 'Continue',
                                  onTap: value.isMobileOtpValid
                                      ? // provider regex validation bool
                                        () {
                                          if (value.validMobileOtp()) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChangeNotifierProvider(
                                                      create: (_) =>
                                                          SignUpEmailProvider(),
                                                      child:
                                                          SignUpEmailScreen(),
                                                    ),
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

 
}
