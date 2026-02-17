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
                padding: const EdgeInsets.fromLTRB(35, 150, 35, 0),
                child: Column(
                  children: [
                    Center(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(ScreenImage.allLogoBr, height: 120),
                            SizedBox(height: 20),
                            Text(
                              'Chronogram',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 15),
                            Text(
                              'Enter your email id for verification',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            ),
                            // Consumer<SignUpEmailProvider>(
                            //   builder: (context, value, child) {
                            //     return value.emailController.text.isEmpty
                            //         ? SizedBox()
                            //         : Text(
                            //             EmailMask.maskEmail(
                            //               value.emailController.text,
                            //             ),
                            //             style: TextStyle(
                            //               color: Colors.black54,
                            //               fontSize: 15,
                            //             ),
                            //           );
                            //   },
                            // ),
                            SizedBox(height: 15),
                            Consumer<SignUpEmailProvider>(
                              builder: (context, value, child) {
                                return TextFormField(
                                  controller: value
                                      .emailController, // This is the importaint line
                                  keyboardType: TextInputType.emailAddress,

                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Enter your email",
                                    errorText: value.emailError,

                                    /// 📱 icon
                                    prefixIcon: Container(
                                      child: const Icon(
                                        Icons.email,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xff1D61E7),
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white38,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                      horizontal: 10,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    emailScreenProvider.validateEmail();
                                  },
                                );
                              },
                            ),
                            SizedBox(height: 30),
                            Consumer<SignUpEmailProvider>(
                              builder: (context, value, child) {
                                return AppButton(
                                  title: 'Continue',
                                  onTap: value.isEmailValid
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  // ChangeNotifierProvider(
                                                  //   // create: (_) =>
                                                  //   //     SignUpEmailOtpProvider(), // Provider
                                                  //   // child: SignUpEmailOtpScreen(
                                                  //   //   email: context
                                                  //   //       .read<
                                                  //   //         SignUpEmailProvider
                                                  //   //       >()
                                                  //   //       .emailController
                                                  //   //       .text,
                                                  //   // ),
                                                  // ),
                                                  ChangeNotifierProvider.value(
                                                    value: context
                                                        .read<
                                                          SignUpEmailProvider
                                                        >(),
                                                    child:
                                                        SignUpEmailOtpScreen(email: value.emailController.text,),
                                                  ),
                                            ),
                                          );
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
