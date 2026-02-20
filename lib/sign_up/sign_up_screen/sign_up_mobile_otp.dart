import 'dart:math';
import 'package:chronogram/auth_progress_indicator/auth_progress_indicator.dart';
import 'package:chronogram/mobile_mask/mobile_mask.dart';
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
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     extendBodyBehindAppBar: true,
  //     appBar: AppBar(backgroundColor: Colors.transparent),
  //     body: SafeArea(
  //       top: false,
  //       bottom: false,
  //       child: Container(
  //         height: double.maxFinite,
  //         width: double.maxFinite,
  //         decoration: BoxDecoration(
  //           image: DecorationImage(
  //             image: AssetImage(ScreenImage.loginBg),
  //             fit: BoxFit.cover,
  //           ),
  //         ),
  //         child: SingleChildScrollView(
  //           child: SizedBox(
  //             height: MediaQuery.of(context).size.height,
  //             child: Padding(
  //               padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
  //               child: Column(
  //                 children: [
  //                   SizedBox(height: 300),
  //                   Center(
  //                     child: Form(
  //                       key: _formKey,

  //                       child: Column(
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: [
  //                           Text(
  //                             'Enter the OTP sent to your mobile number',
  //                             style: TextStyle(
  //                               color: Colors.black54,
  //                               fontSize: 15,
  //                             ),
  //                           ),
  //                           SizedBox(height: 15),
  //                           Consumer<SignUpMobileOtpProvider>(
  //                             builder: (context, provider, child) {
  //                               return Column(
  //                                 children: [
  //                                   Text(
  //                                     MobileMask().maskNumber(
  //                                       context
  //                                           .read<SignUpScreenProvider>()
  //                                           .mobileController
  //                                           .text,
  //                                     ),
  //                                   ),
  //                                   SizedBox(height: 20),
  //                                   OtpTextField(
  //                                     numberOfFields: 6,
  //                                     fieldWidth: 40,
  //                                     fieldHeight: 60,
  //                                     borderRadius: BorderRadius.circular(12),
  //                                     showFieldAsBox: true,
  //                                     filled: true,
  //                                     fillColor: Colors.white38,

  //                                     borderColor: Colors.grey.shade300,
  //                                     focusedBorderColor: const Color(
  //                                       0xFF1D61E7,
  //                                     ),

  //                                     enabledBorderColor: Colors.grey.shade300,
  //                                     cursorColor: const Color(0xFF1D61E7),
  //                                     margin: const EdgeInsets.symmetric(
  //                                       horizontal: 6,
  //                                     ),
  //                                     textStyle: const TextStyle(
  //                                       fontSize: 18,
  //                                       fontWeight: FontWeight.bold,
  //                                     ),
  //                                     keyboardType: TextInputType.number,

  //                                     //Only Digits Allowed
  //                                     inputFormatters: [
  //                                       FilteringTextInputFormatter.digitsOnly,
  //                                     ],
  //                                     // ❌ typing pe validation mat lagao
  //                                     onCodeChanged: (code) {
  //                                       provider.mobileOtpController.text =
  //                                           code;
  //                                       // provider.validMobileOtp();
  //                                     },

  //                                     // ✅ complete hone pe validation
  //                                     onSubmit: (verificationCode) {
  //                                       provider.mobileOtpController.text =
  //                                           verificationCode;

  //                                       provider.validMobileOtp();
  //                                     },
  //                                   ),

  //                                   SizedBox(height: 10),
  //                                   if (provider.mobileOtpError != null)
  //                                     Text(
  //                                       provider.mobileOtpError!,
  //                                       style: TextStyle(
  //                                         color: Colors.red,
  //                                         fontSize: 13,
  //                                       ),
  //                                     ),
  //                                 ],
  //                               ); // Mask Numbe Showe Here
  //                             },
  //                           ),
  //                           SizedBox(height: 30),
  //                           Align(
  //                               alignment: Alignment.centerRight,
  //                               child: InkWell(
  //                                 onTap: () {},
  //                                 child: Text(
  //                                   ' Resend OTP',
  //                                   style: TextStyle(
  //                                     color: Colors.blue,
  //                                     fontWeight: FontWeight.w500,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           SizedBox(height: 30),
  //                           Consumer<SignUpMobileOtpProvider>(
  //                             builder: (context, value, child) {
  //                               return AppButton(
  //                                 title: 'Continue',
  //                             //    onTap: value.isMobileOtpValid
  //                                   onTap: value.isMobileOtpValid
  //                                     ? // provider regex validation bool
  //                                       () async{
  //                                         bool success = await value.verifyMobileOtp(context);
  //                                         if (success) {
  //                                           Navigator.push(
  //                                             context,
  //                                             MaterialPageRoute(
  //                                               builder: (_) => SignUpEmailScreen()

  //                                             ),
  //                                           );
  //                                         }
  //                                       }
  //                                     : null,
  //                               );
  //                             },
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  //   @override
  //   Widget build(BuildContext context) {
  //     final mobile = context.read<SignUpScreenProvider>().mobileController.text;

  //     return Scaffold(
  //       backgroundColor: Colors.black,
  //       body: SafeArea(
  //         child: SingleChildScrollView(
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 25),
  //             child: Column(
  //               children: [
  //                 SizedBox(height: MediaQuery.of(context).size.height * 0.15),

  //                 /// 🔶 LOGO WITH GLOW
  //                 Container(
  //                   height: 90,
  //                   width: 90,
  //                   decoration: BoxDecoration(
  //                     color: const Color(0xff1C1C1E),
  //                     borderRadius: BorderRadius.circular(20),
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: Colors.orange.withOpacity(0.5),
  //                         blurRadius: 40,
  //                         spreadRadius: 5,
  //                       ),
  //                     ],
  //                   ),
  //                   child: Center(
  //                     child: Image.asset(ScreenImage.allLogoBr, height: 45),
  //                   ),
  //                 ),

  //                 const SizedBox(height: 35),

  //                 const Text(
  //                   "Verify OTP",
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 26,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),

  //                 const SizedBox(height: 10),

  //                 Text(
  //                   "OTP sent to +91 ${MobileMask().maskNumber(mobile)}",
  //                   style: const TextStyle(color: Colors.white60, fontSize: 15),
  //                 ),

  //                 const SizedBox(height: 25),

  //                 /// ✅ SIM DETECTED PILL
  //                 Container(
  //                   padding: const EdgeInsets.symmetric(
  //                     horizontal: 20,
  //                     vertical: 12,
  //                   ),
  //                   decoration: BoxDecoration(
  //                     color: const Color(0xff1C1C1E),
  //                     borderRadius: BorderRadius.circular(15),
  //                     border: Border.all(color: Colors.white12),
  //                   ),
  //                   child: Row(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: const [
  //                       Icon(Icons.check_circle, color: Colors.green, size: 20),
  //                       SizedBox(width: 8),
  //                       Text(
  //                         "SIM Detected",
  //                         style: TextStyle(
  //                           color: Colors.green,
  //                           fontWeight: FontWeight.w500,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),

  //                 const SizedBox(height: 35),

  //                 /// 🔢 OTP FIELD
  //                 Consumer<SignUpMobileOtpProvider>(
  //                   builder: (context, provider, child) {
  //                     return Column(
  //                       children: [
  //                         OtpTextField(
  //                           numberOfFields: 6,
  //                           fieldWidth: 45,
  //                           fieldHeight: 60,
  //                           borderRadius: BorderRadius.circular(14),
  //                           showFieldAsBox: true,
  //                           filled: true,
  //                           fillColor: const Color(0xff1C1C1E),
  //                           borderColor: Colors.white12,
  //                           focusedBorderColor: Colors.orange,
  //                           enabledBorderColor: Colors.white12,
  //                           cursorColor: Colors.orange,
  //                           margin: const EdgeInsets.symmetric(horizontal: 6),
  //                           textStyle: const TextStyle(
  //                             fontSize: 20,
  //                             fontWeight: FontWeight.bold,
  //                             color: Colors.white,
  //                           ),
  //                           keyboardType: TextInputType.number,
  //                           inputFormatters: [
  //                             FilteringTextInputFormatter.digitsOnly,
  //                           ],
  //                           onCodeChanged: (code) {
  //                             provider.mobileOtpController.text = code;
  //                           },
  //                           onSubmit: (verificationCode) {
  //                             provider.mobileOtpController.text =
  //                                 verificationCode;
  //                             provider.validMobileOtp();
  //                           },
  //                         ),

  //                         const SizedBox(height: 12),

  //                         if (provider.mobileOtpError != null)
  //                           Text(
  //                             provider.mobileOtpError!,
  //                             style: const TextStyle(
  //                               color: Colors.red,
  //                               fontSize: 13,
  //                             ),
  //                           ),
  //                       ],
  //                     );
  //                   },
  //                 ),

  //                 const SizedBox(height: 25),

  //                 /// ⏳ RESEND TEXT STYLE
  //                 RichText(
  //                   text: const TextSpan(
  //                     text: "Resend OTP in ",
  //                     style: TextStyle(color: Colors.white60),
  //                     children: [
  //                       TextSpan(
  //                         text: "58s",
  //                         style: TextStyle(
  //                           color: Colors.orange,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),

  //                 const SizedBox(height: 30),

  //                 /// 🔘 CONTINUE BUTTON
  //                 Consumer<SignUpMobileOtpProvider>(
  //                   builder: (context, value, child) {
  //                     return GestureDetector(
  //                       onTap: value.isMobileOtpValid
  //                           ? () async {
  //                               bool success = await value.verifyMobileOtp(
  //                                 context,
  //                               );
  //                               if (success) {
  //                                 Navigator.push(
  //                                   context,
  //                                   MaterialPageRoute(
  //                                     builder: (_) => SignUpEmailScreen(),
  //                                   ),
  //                                 );
  //                               }
  //                             }
  //                           : null,
  //                       child: Container(
  //                         height: 55,
  //                         width: double.infinity,
  //                         decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(15),
  //                           gradient: value.isMobileOtpValid
  //                               ? const LinearGradient(
  //                                   colors: [
  //                                     Color(0xffFF8C00),
  //                                     Color(0xffFF5E00),
  //                                   ],
  //                                 )
  //                               : LinearGradient(
  //                                   colors: [
  //                                     Colors.grey.shade800,
  //                                     Colors.grey.shade900,
  //                                   ],
  //                                 ),
  //                         ),
  //                         child: const Center(
  //                           child: Text(
  //                             "Continue",
  //                             style: TextStyle(
  //                               color: Colors.white,
  //                               fontSize: 16,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                 ),

  //                 SizedBox(height: 50),

  //                 /// 🔢 STEP PROGRESS TEXT (1/5)
  //                 Padding(
  //                   padding: const EdgeInsets.fromLTRB(18.0, 0, 18.0, 0),
  //                   child: TweenAnimationBuilder<double>(
  //                     tween: Tween(begin: 0, end: 1 / 5),
  //                     duration: const Duration(milliseconds: 500),
  //                     builder: (context, value, child) {
  //                       return Column(
  //                         children: [
  //                           /// 🔥 Progress Bar Section
  //                           SizedBox(
  //                             height: 28,
  //                             child: Stack(
  //                               alignment: Alignment.center,
  //                               children: [
  //                                 /// Background Bar
  //                                 Container(
  //                                   height: 6,
  //                                   decoration: BoxDecoration(
  //                                     borderRadius: BorderRadius.circular(50),
  //                                     color: Colors.white10,
  //                                   ),
  //                                 ),

  //                                 /// Animated Fill
  //                                 Align(
  //                                   alignment: Alignment.centerLeft,
  //                                   child: FractionallySizedBox(
  //                                     widthFactor: value,
  //                                     child: Container(
  //                                       height: 6,
  //                                       decoration: BoxDecoration(
  //                                         borderRadius: BorderRadius.circular(50),
  //                                         gradient: const LinearGradient(
  //                                           colors: [
  //                                             Color(0xffFF8C00),
  //                                             Color(0xffFF5E00),
  //                                           ],
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ),

  //                                 /// Step Text
  //                                 const Positioned(
  //                                   right: 8,
  //                                   child: Text(
  //                                     "2 / 5",
  //                                     style: TextStyle(
  //                                       color: Colors.white,
  //                                       fontSize: 11,
  //                                       fontWeight: FontWeight.w600,
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                           const SizedBox(height: 12),

  //                           /// ✨ Premium Message
  //                           const Text(
  //                             "Continue to complete your registration.",
  //                             textAlign: TextAlign.center,
  //                             style: TextStyle(
  //                               color: Colors.white70,
  //                               fontSize: 13,
  //                               fontWeight: FontWeight.w400,
  //                             ),
  //                           ),
  //                         ],
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final mobile = context.read<SignUpScreenProvider>().mobileController.text;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // const Spacer(),
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
                              color: Colors.orange.withOpacity(0.5),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(ScreenImage.allLogoBr, height: 45),
                        ),
                      ),

                      const SizedBox(height: 35),

                      const Text(
                        "Verify OTP",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "OTP sent to ${MobileMask().maskNumber(mobile)}",
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// SIM DETECTED
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xff1C1C1E),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "SIM Detected",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 35),

                      /// OTP FIELD
                      Consumer<SignUpMobileOtpProvider>(
                        builder: (context, provider, child) {
                          return Column(
                            children: [
                              // OtpTextField(
                              //   numberOfFields: 6,
                              //   fieldWidth: 45,
                              //   fieldHeight: 60,
                              //   borderRadius: BorderRadius.circular(14),
                              //   showFieldAsBox: true,
                              //   filled: true,
                              //   fillColor: const Color(0xff1C1C1E),
                              //   borderColor: Colors.white12,
                              //   focusedBorderColor: Colors.orange,
                              //   enabledBorderColor: Colors.white12,
                              //   cursorColor: Colors.orange,
                              //   margin: const EdgeInsets.symmetric(
                              //     horizontal: 6,
                              //   ),
                              //   textStyle: const TextStyle(
                              //     fontSize: 20,
                              //     fontWeight: FontWeight.bold,
                              //     color: Colors.white,
                              //   ),
                              //   keyboardType: TextInputType.number,
                              //   inputFormatters: [
                              //     FilteringTextInputFormatter.digitsOnly,
                              //   ],
                              //   onCodeChanged: (code) {
                              //     provider.mobileOtpController.text = code;
                              //   },
                              //   onSubmit: (verificationCode) {
                              //     provider.mobileOtpController.text =
                              //         verificationCode;
                              //     provider.validMobileOtp();
                              //   },
                              // ),
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
                                Text(
                                  provider.mobileOtpError!,
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

                      /// RESEND
                      /// RESEND TIMER
                      // Consumer<SignUpMobileOtpProvider>(
                      //   builder: (context, provider, child) {
                      //     return RichText(
                      //       text: TextSpan(
                      //         text: "Resend OTP in ",
                      //         style: const TextStyle(color: Colors.white60),
                      //         children: [
                      //           TextSpan(
                      //             text: provider.timerText,
                      //             style: const TextStyle(
                      //               color: Colors.orange,
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     );
                      //   },
                      // ),
                      Consumer<SignUpMobileOtpProvider>(
                        builder: (context, provider, child) {
                          if (provider.canResend) {
                            return GestureDetector(
                              onTap: provider.isResending
                                  ? null
                                  : () => provider.resendOtp(context),
                              child: Text(
                                provider.isResending
                                    ? "Sending..."
                                    : "Resend OTP",
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }

                          return RichText(
                            text: TextSpan(
                              text: "Resend OTP in ",
                              style: const TextStyle(color: Colors.white60),
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
                      const SizedBox(height: 30),

                      /// CONTINUE BUTTON
                      Consumer<SignUpMobileOtpProvider>(
                        builder: (context, value, child) {
                          return GestureDetector(
                            onTap: value.isMobileOtpValid
                                ? () async {
                                    bool success = await value.verifyMobileOtp(
                                      context,
                                    );
                                    if (success) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const SignUpEmailScreen(),
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
                                gradient: value.isMobileOtpValid
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
                              child: const Center(
                                child: Text(
                                  "Continue",
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

                      const SizedBox(height: 40),

                      /// PROGRESS BAR
                      _buildProgressBar(),

                      /// keyboard safe
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 🔥 PROGRESS BAR METHOD
  Widget _buildProgressBar() {
    return const AuthProgressIndicator(
      currentStep: 2,
      totalSteps: 5,
      message: "Verify OTP sent to your mobile",
    );
  }
}
