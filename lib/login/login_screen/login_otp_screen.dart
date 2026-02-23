import 'package:chronogram/home_screen/home_screen.dart';
import 'package:chronogram/login/login_provider/login_otp_provider.dart';
import 'package:chronogram/login/login_screen/login_new_device_email_screen.dart';
import 'package:chronogram/mask/email_mask/email_mask.dart';
import 'package:chronogram/mobile_mask/mobile_mask.dart';
import 'package:chronogram/sign_up/sign_up_screen/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:provider/provider.dart';

class LoginOtpScreen extends StatelessWidget {
  final String mobile;

  const LoginOtpScreen({super.key, required this.mobile});

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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.10,
                            ),

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

                            /// masked mobile
                            Text(
                              "OTP sent to ${MobileMask().maskNumber(mobile)}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 40),

                            /// 🔢 OTP FIELD
                            LayoutBuilder(
                              builder: (context, constraints) {
                                double totalWidth = constraints.maxWidth;
                                double fieldWidth = (totalWidth - 24) / 6;

                                if (fieldWidth > 55) fieldWidth = 55;
                                if (fieldWidth < 34) fieldWidth = 34;

                                return OtpTextField(
                                  numberOfFields: 6,
                                  fieldWidth: fieldWidth,
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
                                    horizontal: 2,
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
                                    provider.validMobileOtp();
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            if (provider.mobileOtpError != null)
                              Column(
                                children: [
                                  Text(
                                    provider.mobileOtpError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 6),

                                  /// 🔥 USER NOT REGISTERED → REGISTER BUTTON
                                  if (provider.showRegisterButton)
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const SignUpScreen(), // signup screen
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "Register Now",
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                  /// 🔥 NEW DEVICE → VERIFY EMAIL BUTTON
                                  if (provider.showVerifyEmailButton)
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                LoginNewDeviceEmailScreen(
                                                  mobile: mobile,
                                                  maskedEmail:
                                                      provider.maskedEmail,
                                                  temporaryToken: provider.temporaryToken, //
                                                ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "Verify Email",
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            const SizedBox(height: 25),

                            if (provider.mobileOtpError == null)
                              Consumer<LoginMobileOtpScreenProvider>(
                                builder: (context, provider, child) {
                                  return RichText(
                                    text: TextSpan(
                                      text: "Resend OTP in ",
                                      style: const TextStyle(
                                        color: Colors.white60,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: provider.timerText,
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            const SizedBox(height: 35),

                            /// 🔘 LOGIN BUTTON
                            GestureDetector(
                              onTap: provider.isMobileOtpValid
                                  ? () {
                                      provider.verifyLoginOtp(context, mobile);
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
                                      : LinearGradient(
                                          colors: [
                                            Colors.grey.shade800,
                                            Colors.grey.shade900,
                                          ],
                                        ),
                                ),
                                child: Center(
                                  child: provider.isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
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
                              height: MediaQuery.of(context).viewInsets.bottom,
                            ),
                          ],
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
