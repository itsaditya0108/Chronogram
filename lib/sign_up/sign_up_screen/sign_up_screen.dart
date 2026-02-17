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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(35, 0, 35, 0),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.26),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Image.asset(ScreenImage.allLogoBr, height: 80),
                          SizedBox(height: 20),
                          Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Continue with phone number verification',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 15),
                          Consumer<SignUpScreenProvider>(
                            builder: (context, value, child) {
                              return TextFormField(
                                controller:
                                    value.mobileController, //// Important
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(
                                    10,
                                  ), //This Line use for digits only
                                ],
                                onChanged: (value) {
                                  signUpScreenProvider.checkMobileValid();
                                },
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter mobile number",

                                  /// 📱 icon
                                  prefixIcon: Container(
                                    child: const Icon(
                                      Icons.phone,
                                      color: Color(0xff1D61E7),
                                    ),
                                  ),
                                  errorText:
                                      value.mobileError, ////Error Show here
                                  hintStyle: TextStyle(color: Colors.grey[500]),
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
                              );
                            },
                          ),
                          SizedBox(height: 30),
                          Consumer<SignUpScreenProvider>(
                            builder: (context, value, child) {
                              return AppButton(
                                title: 'Continue',
                                // onTap: value.isMobileValid
                                //     ? // provoder regex validation
                                //       ()async {
                                //         if (value.validateMobile()) {
                                //           String mobile = value.mobileController.text.trim();
                                //           bool success = await ApiService.sendOtp(mobile);
                                //           if(success){
                                //             print("OTP Sent Successfully");
                                //             Navigator.push(
                                //             context,
                                //             MaterialPageRoute(
                                //               builder: (context) =>
                                //                   ChangeNotifierProvider.value(
                                //                     value: context
                                //                         .read<
                                //                           SignUpScreenProvider
                                //                         >(),
                                //                     child:
                                //                         SignUpMobileOtpScreen(),
                                //                   ),
                                //             ),
                                //           );
                                //           }else{
                                //             ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("OTP send faild")) );
                                //           }
                                //         }
                                //       }
                                //     : null,
                                onTap: value.isMobileValid
                                    ? () async {
                                        if (value.validateMobile()) {
                                          String mobile =
                                              value.mobileController.text;

                                          bool success =
                                              await value.sendOtp(mobile);

                                          if (success) {
                                            print("OTP SENT SUCCESS");

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChangeNotifierProvider.value(
                                                      value: context
                                                          .read<
                                                            SignUpScreenProvider
                                                          >(),
                                                      child:
                                                          SignUpMobileOtpScreen(),
                                                    ),
                                              ),
                                            );
                                          } else {
                                            print("OTP FAIL");
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "OTP send failed",
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    : null,
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'You have an account?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
