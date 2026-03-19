import 'package:chronogram/app_helper/edit_login_mobile_dialog.dart';
import 'package:chronogram/app_helper/exit_user_dilog.dart';
import 'package:chronogram/screens/home_screen/home_screen.dart';
import 'package:chronogram/screens/login/login_provider/login_otp_provider.dart';
import 'package:chronogram/screens/login/login_provider/login_screen_provider.dart';
import 'package:chronogram/screens/login/login_screen/login_new_device_email_screen.dart';
import 'package:chronogram/app_helper/mask/email_mask/email_mask.dart';
import 'package:chronogram/app_helper/mobile_mask/mobile_mask.dart';
import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_screen.dart';
import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_email_screen.dart';
import 'package:chronogram/screens/login/login_helper/aseet_helper.dart';
import 'package:chronogram/buttons/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class LoginOtpScreen extends StatefulWidget {
  final String mobile;

  const LoginOtpScreen({super.key, required this.mobile});

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoginMobileOtpScreenProvider>().init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        showDialog(context: context, builder: (context) => ExitUser());
      },
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
                              SizedBox(height: MediaQuery.of(context).size.height * 0.18),

                              /// 🔶 LOGO
                              Image.asset(ScreenImage.allLogoBr, height: 70),

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
                              Row(
                                children: [
                                  Text(
                                    "OTP sent to ${MobileMask().maskNumber(widget.mobile)}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) =>
                                            EditLoginMobileDialog(),
                                      );
                                    },
                                    child: Text(
                                      'Change Number',
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 40),

                              /// 🔢 OTP FIELD
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  double totalWidth = constraints.maxWidth;
                                  double fieldWidth = (totalWidth - 24) / 6;

                                  if (fieldWidth > 55) fieldWidth = 55;
                                  if (fieldWidth < 34) fieldWidth = 34;

                                  return Pinput(
                                    length: 6,
                                    controller: provider.mobileOtpController,
                                    autofillHints: const [AutofillHints.oneTimeCode],
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    defaultPinTheme: PinTheme(
                                      width: fieldWidth,
                                      height: 60,
                                      textStyle: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff1C1C1E),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: Colors.white12),
                                      ),
                                    ),
                                    focusedPinTheme: PinTheme(
                                      width: fieldWidth,
                                      height: 60,
                                      textStyle: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff1C1C1E),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: Colors.orange),
                                      ),
                                    ),
                                    onCompleted: (code) {
                                      provider.validMobileOtp();
                                    },
                                    onChanged: (code) {
                                      if (code.length == 6) provider.validMobileOtp();
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
                                          if (provider.isIncomplete) {
                                            // INCOMPLETE USER → Go to SignUp Email Flow
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const SignUpEmailScreen(),
                                              ),
                                            );
                                          } else {
                                            // NEW DEVICE (401) → Go to Login New Device Email Flow
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    LoginNewDeviceEmailScreen(
                                                  mobile: widget.mobile,
                                                  maskedEmail:
                                                      provider.maskedEmail,
                                                  temporaryToken: provider
                                                      .temporaryToken,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          provider.isIncomplete 
                                              ? "Verify Email & Complete Registration" 
                                              : "Verify Email",
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              const SizedBox(height: 25),

                              // if (provider.mobileOtpError == null)
                              //   Consumer<LoginMobileOtpScreenProvider>(
                              //     builder: (context, provider, child) {
                              //       return RichText(
                              //         text: TextSpan(
                              //           text: "Resend OTP in ",
                              //           style: const TextStyle(
                              //             color: Colors.white60,
                              //           ),
                              //           children: [
                              //             TextSpan(
                              //               text: provider.timerText,
                              //               style: const TextStyle(
                              //                 color: Colors.orange,
                              //                 fontWeight: FontWeight.bold,
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //       );
                              //     },
                              //   ),
                              Consumer<LoginMobileOtpScreenProvider>(
                                builder: (context, provider, child) {
                                  /// 🔥 WHEN TIMER FINISH → SHOW RESEND BUTTON
                                  if (provider.canResend) {
                                    return GestureDetector(
                                      onTap: provider.isResending
                                          ? null
                                          : () => provider.resendLoginOtp(
                                              widget.mobile,
                                              context,
                                            ),
                                      child: Text(
                                        provider.isResending
                                            ? "Sending..."
                                            : "Resend OTP",
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    );
                                  }

                                  /// ⏱ TIMER RUNNING
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
                              AppButton(
                                title: "Login",
                                isLoading: provider.isLoading,
                                isEnabled: provider.isMobileOtpValid,
                                onTap: () async {
                                  await provider.verifyLoginOtp(
                                    context,
                                    widget.mobile,
                                  );
                                },
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
