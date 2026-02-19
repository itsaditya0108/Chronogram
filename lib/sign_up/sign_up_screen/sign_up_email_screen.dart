import 'package:chronogram/buttons/buttons.dart';

import 'package:chronogram/login/login_helper/aseet_helper.dart';
import 'package:chronogram/login/login_provider/login_screen_provider.dart';
import 'package:chronogram/login/login_screen/login_screen.dart';
import 'package:chronogram/sign_up/sign_up_provider/sign_up_email_otp_provider.dart';
import 'package:chronogram/sign_up/sign_up_provider/sign_up_email_provider.dart';
import 'package:chronogram/sign_up/sign_up_screen/sign_up_email_otp.dart';
import 'package:chronogram/sign_up/sign_up_screen/sign_up_mobile_otp.dart';
import 'package:chronogram/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class SignUpEmailScreen extends StatefulWidget {
  const SignUpEmailScreen({super.key});
  @override
  State<SignUpEmailScreen> createState() => _SignUpEmailScreenState();
}

class _SignUpEmailScreenState extends State<SignUpEmailScreen> {
  SignUpEmailProvider get emailScreenProvider =>
      Provider.of<SignUpEmailProvider>(context, listen: false);
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
  //               padding: const EdgeInsets.fromLTRB(35, 150, 35, 0),
  //               child: Column(
  //                 children: [
  //                   Center(
  //                     child: Form(
  //                       key: _formKey,
  //                       child: Column(
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: [
  //                           Image.asset(ScreenImage.allLogoBr, height: 120),
  //                           SizedBox(height: 20),
  //                           Text(
  //                             'Chronogram',
  //                             style: TextStyle(
  //                               color: Colors.black,
  //                               fontSize: 30,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                           SizedBox(height: 15),
  //                           Text(
  //                             'Enter your email id for verification',
  //                             style: TextStyle(
  //                               color: Colors.black54,
  //                               fontSize: 15,
  //                             ),
  //                           ),
                      
  //                           SizedBox(height: 15),
  //                           Consumer<SignUpEmailProvider>(
  //                             builder: (context, value, child) {
  //                               return TextFormField(
  //                                 controller: value
  //                                     .emailController, // This is the importaint line
  //                                 keyboardType: TextInputType.emailAddress,

  //                                 style: const TextStyle(
  //                                   fontSize: 16,
  //                                   fontWeight: FontWeight.w500,
  //                                 ),
  //                                 decoration: InputDecoration(
  //                                   hintText: "Enter your email",
  //                                   errorText: value.emailError,

  //                                   /// 📱 icon
  //                                   prefixIcon: Container(
  //                                     child: const Icon(
  //                                       Icons.email,
  //                                       color: Colors.blueAccent,
  //                                     ),
  //                                   ),
  //                                   hintStyle: TextStyle(
  //                                     color: Colors.grey[500],
  //                                   ),
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
  //                                 onChanged: (value) {
  //                                   emailScreenProvider.validateEmail();
  //                                 },
  //                               );
  //                             },
  //                           ),
  //                           SizedBox(height: 30),
  //                           Consumer<SignUpEmailProvider>(
  //                             builder: (context, value, child) {
  //                               return AppButton(
  //                                 title: 'Continue',
  //                                 onTap: value.isEmailValid
  //                                     ? () async {
  //                                         bool success = await value
  //                                             .linkEmailApi(context);
  //                                         if (success) {
  //                                           Navigator.push(
  //                                             context,
  //                                             MaterialPageRoute(
  //                                               builder: (context) =>
  //                                                   ChangeNotifierProvider(
  //                                                     create: (_) =>
  //                                                         SignUpEmailOtpProvider(),
  //                                                     child:
  //                                                         SignUpEmailOtpScreen(
  //                                                           email: value
  //                                                               .emailController
  //                                                               .text,
  //                                                         ),
  //                                                   ),
  //                                             ),
  //                                           );
  //                                         } else {
  //                                           ScaffoldMessenger.of(
  //                                             context,
  //                                           ).showSnackBar(
  //                                             SnackBar(
  //                                               content: Text(
  //                                                 "Email link failed",
  //                                               ),
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

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: MediaQuery.of(context).size.height * 0.15),

              /// 🔶 LOGO WITH GLOW
              Center(
                child: Container(
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
              ),

              const SizedBox(height: 40),

              /// TITLE
              const Text(
                "Enter Your Email",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "We'll send a verification code",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 30),

              /// 📧 EMAIL FIELD
              Consumer<SignUpEmailProvider>(
                builder: (context, value, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff1C1C1E),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextFormField(
                      controller: value.emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (v) {
                        value.validateEmail();
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.mail_outline,
                          color: Colors.white54,
                        ),
                        hintText: "example@email.com",
                        hintStyle:
                            const TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                        errorText: value.emailError,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              /// 🔘 CONTINUE BUTTON
              Consumer<SignUpEmailProvider>(
                builder: (context, value, child) {
                  return GestureDetector(
                    onTap: value.isEmailValid
                        ? () async {
                            bool success =
                                await value.linkEmailApi(context);
                            if (success) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChangeNotifierProvider(
                                    create: (_) =>
                                        SignUpEmailOtpProvider(),
                                    child: SignUpEmailOtpScreen(
                                      email: value
                                          .emailController.text,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Email link failed"),
                                ),
                              );
                            }
                          }
                        : null,
                    child: Container(
                      height: 55,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(15),
                        gradient: value.isEmailValid
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
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              /// 🔥 STEP PROGRESS (3/5)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 3 / 5),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Step 3 of 5",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(50),
                          color: Colors.white10,
                        ),
                        child: Align(
                          alignment:
                              Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: value,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius
                                        .circular(50),
                                gradient:
                                    const LinearGradient(
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
                        "Almost done, stay with us ✨",
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
