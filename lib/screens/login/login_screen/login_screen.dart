import 'package:chronogram/screens/login/login_provider/login_screen_provider.dart';
import 'package:chronogram/screens/login/login_screen/login_otp_screen.dart';
import 'package:chronogram/service/api_service.dart';
import 'package:chronogram/app_helper/ui_helper.dart';
import 'package:chronogram/screens/login/login_helper/aseet_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class LoginMobileScreen extends StatelessWidget {
  const LoginMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Consumer<LoginMobileScreenProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.18,
                      ),

                      /// 🔶 LOGO
                      Image.asset(ScreenImage.allLogoBr, height: 70),

                      const SizedBox(height: 35),

                      const Text(
                        "Login with Mobile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Enter your registered mobile number",
                        style: TextStyle(color: Colors.white60, fontSize: 15),
                      ),

                      const SizedBox(height: 35),

                      /// 📱 MOBILE FIELD
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xff1C1C1E),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: TextFormField(
                              controller: provider.mobileController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                prefixIcon: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text(
                                    "+91  ",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                hintText: "Enter mobile number",
                                hintStyle: TextStyle(color: Colors.white38),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ),

                          /// 🔴 ERROR BELOW TEXTFIELD
                          if (provider.mobileError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 5),
                              child: Center(
                                child: Text(
                                  provider.mobileError!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      /// 🔘 SEND OTP BUTTON
                      InkWell(
               
                        onTap: provider.isMobileValid
                            ? () async {
                                if (!provider.validateMobile()) return;

                                String mobile = provider.mobileController.text.trim();

                                if (provider.isCooldownActive(mobile)) {
                                  // Navigate directly without calling sendLoginOtp
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LoginOtpScreen(mobile: mobile),
                                    ),
                                  );
                                  return;
                                }

                                final result = await provider.sendLoginOtp(mobile);
                                if (!context.mounted) return;

                                if (result == 'success') {
                                  /// 🔥 SAVE TIME + MOBILE
                                  provider.lastOtpSentTime = DateTime.now();
                                  provider.lastOtpMobile = mobile;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LoginOtpScreen(mobile: mobile),
                                    ),
                                  );
                                } else {
                                  // Removed snackbar as per request
                                  // Error is already handled by provider.mobileError and shown below the field
                                }
                              }
                            : null,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 1.0, end: provider.isMobileValid ? 1.0 : 0.95),
                          duration: const Duration(milliseconds: 100),
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                height: 55,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: provider.isMobileValid
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xffFF8C00),
                                            Color(0xffFF5E00),
                                          ],
                                        )
                                      : null,
                                  color: provider.isMobileValid
                                      ? null
                                      : Colors.grey.shade800,
                                ),
                                child: const Center(
                                  child: Text(
                                    "Send OTP",
                                    style: TextStyle(
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
                      ),

                      const SizedBox(height: 25),

                      /// 🔁 SIGNUP LINK
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(color: Colors.white54),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 50),

                      const Text(
                        "Secure login powered by OTP verification.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white38, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
  }
}
