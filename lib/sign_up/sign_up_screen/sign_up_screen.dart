import 'package:chronogram/buttons/buttons.dart';
import 'package:chronogram/login/login_helper/aseet_helper.dart';
import 'package:chronogram/login/login_provider/login_screen_provider.dart';
import 'package:chronogram/login/login_screen/login_screen.dart';
import 'package:chronogram/service/api_service.dart';
import 'package:chronogram/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:chronogram/sign_up/sign_up_screen/sign_up_mobile_otp.dart';
import 'package:chronogram/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  SignUpScreenProvider get signUpScreenProvider =>
      Provider.of<SignUpScreenProvider>(
        context,
        listen: false,
      ); //// This Line use for provider
  final _formKey = GlobalKey<FormState>();
  //   @override
  //   Widget build(BuildContext context) {
  //     return Scaffold(
  //       body: SafeArea(
  //         top: false,
  //         bottom: false,
  //         child: Container(
  //           height: double.maxFinite,
  //           width: double.maxFinite,
  //           decoration: BoxDecoration(
  //             image: DecorationImage(
  //               image: AssetImage(ScreenImage.loginBg),
  //               fit: BoxFit.cover,
  //             ),
  //           ),
  //           child: SingleChildScrollView(
  //             child: SizedBox(
  //               child: Padding(
  //                 padding: const EdgeInsets.fromLTRB(35, 0, 35, 0),
  //                 child: Column(
  //                   children: [
  //                     SizedBox(height: MediaQuery.of(context).size.height * 0.26),
  //                     Form(
  //                       key: _formKey,
  //                       child: Column(
  //                         children: [
  //                           Image.asset(ScreenImage.allLogoBr, height: 80),
  //                           SizedBox(height: 20),
  //                           Text(
  //                             'Sign Up',
  //                             style: TextStyle(
  //                               color: Colors.black,
  //                               fontSize: 35,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                           SizedBox(height: 15),
  //                           Text(
  //                             'Continue with phone number verification',
  //                             style: TextStyle(
  //                               color: Colors.black54,
  //                               fontSize: 18,
  //                             ),
  //                           ),
  //                           SizedBox(height: 15),
  //                           Consumer<SignUpScreenProvider>(
  //                             builder: (context, value, child) {
  //                               return TextFormField(
  //                                 controller:
  //                                     value.mobileController, //// Important
  //                                 keyboardType: TextInputType.phone,
  //                                 inputFormatters: [
  //                                   FilteringTextInputFormatter.digitsOnly,
  //                                   LengthLimitingTextInputFormatter(
  //                                     10,
  //                                   ), //This Line use for digits only
  //                                 ],
  //                                 onChanged: (value) {
  //                                   signUpScreenProvider.checkMobileValid();
  //                                 },
  //                                 style: const TextStyle(
  //                                   fontSize: 16,
  //                                   fontWeight: FontWeight.w500,
  //                                 ),
  //                                 decoration: InputDecoration(
  //                                   hintText: "Enter mobile number",

  //                                   /// 📱 icon
  //                                   prefixIcon: Container(
  //                                     child: const Icon(
  //                                       Icons.phone,
  //                                       color: Color(0xff1D61E7),
  //                                     ),
  //                                   ),
  //                                   errorText:
  //                                       value.mobileError, ////Error Show here
  //                                   hintStyle: TextStyle(color: Colors.grey[500]),
  //                                   border: OutlineInputBorder(
  //                                     borderRadius: BorderRadius.circular(10),
  //                                     borderSide: BorderSide.none,
  //                                   ),
  //                                   focusedBorder: OutlineInputBorder(
  //                                     borderRadius: BorderRadius.circular(12),
  //                                     borderSide: const BorderSide(
  //                                       color: Color(0xff1D61E7),
  //                                       width: 2,
  //                                     ),
  //                                   ),
  //                                   filled: true,
  //                                   fillColor: Colors.white38,
  //                                   contentPadding: const EdgeInsets.symmetric(
  //                                     vertical: 18,
  //                                     horizontal: 10,
  //                                   ),
  //                                 ),
  //                               );
  //                             },
  //                           ),
  //                           SizedBox(height: 30),
  //                           Consumer<SignUpScreenProvider>(
  //                             builder: (context, value, child) {
  //                               return AppButton(
  //                                 title: 'Continue',

  //                                 onTap: value.isMobileValid
  //                                     ? () async {
  //                                         if (value.validateMobile()) {
  //                                           String mobile =
  //                                               value.mobileController.text;
  //                                           bool success =
  //                                               await value.sendOtp(mobile);
  //                                           if (success) {
  //                                             print("OTP SENT SUCCESS");

  //                                             Navigator.push(
  //                                               context,
  //                                               MaterialPageRoute(
  //                                                 builder: (context) =>
  //                                                     ChangeNotifierProvider.value(
  //                                                       value: context
  //                                                           .read<
  //                                                             SignUpScreenProvider
  //                                                           >(),
  //                                                       child:
  //                                                           SignUpMobileOtpScreen(),
  //                                                     ),
  //                                               ),
  //                                             );
  //                                           } else {
  //                                             print("OTP FAIL");
  //                                             ScaffoldMessenger.of(
  //                                               context,
  //                                             ).showSnackBar(
  //                                               SnackBar(
  //                                                 content: Text(
  //                                                   "OTP send failed",
  //                                                 ),
  //                                               ),
  //                                             );
  //                                           }
  //                                         }
  //                                       }
  //                                     : null,
  //                               );
  //                             },
  //                           ),
  //                           SizedBox(height: 20),
  //                           Center(
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Text(
  //                                   'You have an account?',
  //                                   style: TextStyle(
  //                                     fontSize: 16,
  //                                     fontWeight: FontWeight.w500,
  //                                     color: Colors.black54,
  //                                   ),
  //                                 ),
  //                                 SizedBox(width: 8),
  //                                 InkWell(
  //                                   onTap: () {
  //                                     Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                         builder: (context) => LoginScreen(),
  //                                       ),
  //                                     );
  //                                   },
  //                                   child: Text(
  //                                     'Login',
  //                                     style: TextStyle(
  //                                       fontSize: 16,
  //                                       fontWeight: FontWeight.bold,
  //                                       color: Colors.black,
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.18),

                /// 🔶 LOGO WITH GLOW
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

                /// 🔤 TITLE
                const Text(
                  "Enter Mobile Number",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "We'll send you a verification code",
                  style: TextStyle(color: Colors.white60, fontSize: 15),
                ),

                const SizedBox(height: 35),

                /// 📱 MOBILE FIELD
                Consumer<SignUpScreenProvider>(
                  builder: (context, value, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xff1C1C1E),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextFormField(
                        controller: value.mobileController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        onChanged: (v) {
                          value.checkMobileValid();
                        },

                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: const Padding(
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
                          hintStyle: const TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                          errorText: value.mobileError,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),

                /// 🔘 CONTINUE BUTTON
                Consumer<SignUpScreenProvider>(
                  builder: (context, value, child) {
                    return GestureDetector(
                      onTap: value.isMobileValid
                          ? () async {
                              if (value.validateMobile()) {
                                String mobile = value.mobileController.text;
                                bool success = await value.sendOtp(mobile);
                                if (success) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChangeNotifierProvider.value(
                                            value: context
                                                .read<SignUpScreenProvider>(),
                                            child: SignUpMobileOtpScreen(),
                                          ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("OTP send failed"),
                                    ),
                                  );
                                }
                              }
                            }
                          : null,
                      child: Container(
                        height: 55,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: value.isMobileValid
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

                /// ✨ POSITIVE PROGRESS MESSAGE
                const SizedBox(height: 25),

                /// 🔁 LOGIN TEXT
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginMobileScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50), /////
                /// 🔥 PREMIUM STEP PROGRESS
                Padding(
                  padding: const EdgeInsets.fromLTRB(18.0, 0, 18.0, 0),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1 / 5),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return Column(
                        children: [
                          /// 🔥 Progress Bar Section
                          SizedBox(
                            height: 28,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                /// Background Bar
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.white10,
                                  ),
                                ),

                                /// Animated Fill
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: value,
                                    child: Container(
                                      height: 6,
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

                                /// Step Text
                                const Positioned(
                                  right: 8,
                                  child: Text(
                                    "1 / 5",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          /// ✨ Premium Message
                          const Text(
                            "Continue to complete your registration.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
