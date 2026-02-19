import 'package:chronogram/home_screen/home_screen.dart';
import 'package:chronogram/login/login_provider/login_otp_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:provider/provider.dart';

class LoginOtpScreen extends StatelessWidget {
  const LoginOtpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginMobileOtpScreenProvider(),
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Consumer<LoginMobileOtpScreenProvider>(
            builder: (context, provider, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Column(
                            children: [
                              const Spacer(),

                              /// 🔶 LOGO
                              Container(
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                  color: const Color(0xff1C1C1E),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.4),
                                      blurRadius: 30,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.lock,
                                  color: Colors.orange,
                                  size: 40,
                                ),
                              ),

                              const SizedBox(height: 35),

                              const Text(
                                "Verify Login OTP",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                "Enter the 6-digit code sent to your mobile number",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 40),

                              /// 🔢 OTP FIELD
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
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
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
                                  provider.mobileOtpController.text = code;
                                },
                                onSubmit: (verificationCode) {
                                  provider.mobileOtpController.text =
                                      verificationCode;
                                },
                              ),

                              /// 🔴 ERROR TEXT
                              if (provider.mobileOtpError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    provider.mobileOtpError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 25),

                              const Text(
                                "Resend OTP in 58s",
                                style: TextStyle(color: Colors.white60),
                              ),

                              const SizedBox(height: 35),

                              /// 🔘 LOGIN BUTTON
                              InkWell(
                                onTap: provider.isMobileOtpValid
                                    ? () {
                                        if (provider.validMobileOtp()) {
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
                                child: Container(
                                  height: 55,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: provider.isMobileOtpValid
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xffFF8C00),
                                              Color(0xffFF5E00),
                                            ],
                                          )
                                        : null,
                                    color: provider.isMobileOtpValid
                                        ? null
                                        : Colors.grey.shade800,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),

                              const Text(
                                "Having trouble? Contact Support",
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),

                              SizedBox(
                                height: MediaQuery.of(
                                  context,
                                ).viewInsets.bottom,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
