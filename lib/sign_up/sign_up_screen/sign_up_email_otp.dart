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
import 'package:chronogram/sign_up/sign_up_screen/sign_up_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class SignUpEmailOtpScreen extends StatefulWidget {
  const SignUpEmailOtpScreen({super.key, required this.email});
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
    backgroundColor: Colors.black,
    body: SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              SizedBox(height: MediaQuery.of(context).size.height * 0.15),

              /// 🔶 LOGO
              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: const Color(0xff1C1C1E),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    ScreenImage.allLogoBr,
                    height: 45,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                "Verify Email",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "OTP sent to your email",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 8),

              /// masked email
              Text(
                EmailMask.maskEmail(widget.email),
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 30),

              /// OTP FIELD
              Consumer<SignUpEmailOtpProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [

                      OtpTextField(
                        numberOfFields: 6,
                        fieldWidth: 45,
                        fieldHeight: 60,
                        borderRadius: BorderRadius.circular(14),
                        showFieldAsBox: true,
                        filled: true,
                        fillColor: const Color(0xff1C1C1E),
                        borderColor: Colors.white12,
                        focusedBorderColor: Colors.orange,
                        enabledBorderColor: Colors.white12,
                        cursorColor: Colors.orange,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onCodeChanged: (code) {
                          provider.emailOtpController.text = code;
                        },
                        onSubmit: (verificationCode) {
                          provider.emailOtpController.text = verificationCode;
                          provider.validEmailOtp();
                        },
                      ),

                      const SizedBox(height: 12),

                      if (provider.emailOtpError != null)
                        Text(
                          provider.emailOtpError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 25),

              /// resend
              const Text.rich(
                TextSpan(
                  text: "Resend OTP in ",
                  style: TextStyle(color: Colors.white60),
                  children: [
                    TextSpan(
                      text: "58s",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              /// CONTINUE BUTTON
              Consumer<SignUpEmailOtpProvider>(
                builder: (context, value, child) {
                  return GestureDetector(
                    onTap: value.isLoading
                        ? null
                        : (value.isEmailOtpValid
                              ? () async {
                                  bool success =
                                      await value.verifyEmailOtpApi(
                                        widget.email,
                                      );

                                  if (success) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            SignUpProfileScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                }
                              : null),
                    child: Container(
                      height: 55,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: value.isEmailOtpValid
                            ? const LinearGradient(
                                colors: [
                                  Color(0xffFF8C00),
                                  Color(0xffFF5E00),
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.grey.shade800,
                                  Colors.grey.shade900,
                                ],
                              ),
                      ),
                      child: Center(
                        child: Text(
                          value.isLoading
                              ? "Please wait..."
                              : "Continue",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              /// STEP PROGRESS (4/5)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 4 / 5),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Step 4 of 5",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.white10,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: value,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xffFF8C00),
                                    Color(0xffFF5E00),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Securing your account 🔐",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    ),
  );
}

}
