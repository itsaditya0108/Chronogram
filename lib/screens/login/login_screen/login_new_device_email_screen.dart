import 'package:chronogram/app_helper/exit_user_dilog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chronogram/screens/login/login_helper/aseet_helper.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:provider/provider.dart';
import '../login_provider/login_new_device_email_provider.dart';

class LoginNewDeviceEmailScreen extends StatelessWidget {
  final String mobile;
  final String maskedEmail;
  final String temporaryToken;

  const LoginNewDeviceEmailScreen({
    super.key,
    required this.mobile,
    required this.maskedEmail,
    required this.temporaryToken,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          LoginNewDeviceEmailProvider(temporaryToken: temporaryToken),
      child: PopScope(
        canPop: false,
        onPopInvoked:(didPop) async{
          if(didPop)return;
          showDialog(context: context, builder:(context) => ExitUser());
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Consumer<LoginNewDeviceEmailProvider>(
              builder: (context, provider, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.18),

                      /// LOGO
                      Image.asset(ScreenImage.allLogoBr, height: 70),
        
                      const SizedBox(height: 35),
        
                      const Text(
                        "Verify New Device",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
        
                      const SizedBox(height: 10),
        
                      Text(
                        "OTP sent to $maskedEmail",
                        style: const TextStyle(color: Colors.white60),
                      ),
        
                      const SizedBox(height: 40),
        
                      /// OTP FIELD
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
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        
                        onSubmit: (code) {
                          provider.otpController.text = code;
                          provider.checkOtp();
                        },
                        onCodeChanged: (code) {
                          provider.otpController.text = code;
                        },
                      ),
        
                      const SizedBox(height: 12),
        
                      if (provider.error != null)
                        Text(
                          provider.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
        
                      const SizedBox(height: 25),
        
                      /// TIMER / RESEND
                      provider.canResend
                          ? GestureDetector(
                              onTap: provider.isResending
                                  ? null
                                  : () => provider.resendOtp(temporaryToken),
                              child: Text(
                                provider.isResending
                                    ? "Sending..."
                                    : "Resend OTP",
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : RichText(
                              text: TextSpan(
                                text: "Resend in ",
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 14,
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
                            ),
                     
                      const SizedBox(height: 35),
                      /// VERIFY BUTTON
                      GestureDetector(
                        onTap: provider.isOtpValid && !provider.isLoading
                            ? () => provider.verifyEmailOtp(context, mobile)
                            : null,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                              begin: 1.0,
                              end: provider.isOtpValid ? 1.0 : 0.95),
                          duration: const Duration(milliseconds: 100),
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                height: 55,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: provider.isOtpValid
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
                                          "Verify & Login",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
