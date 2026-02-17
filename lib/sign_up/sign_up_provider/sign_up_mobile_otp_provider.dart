import 'package:chronogram/service/api_service.dart';
import 'package:chronogram/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:chronogram/token_saver_helper/token_saver_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpMobileOtpProvider extends ChangeNotifier {

  TextEditingController mobileOtpController = TextEditingController();
  String? mobileOtpError;
  bool isMobileOtpValid = false;
  // constructor
  SignUpMobileOtpProvider(){
    mobileOtpController.addListener(checkMobileOtpFill); // 👈 listener
  }
  // realtime check for button enable
  void checkMobileOtpFill(){
    String value = mobileOtpController.text.trim();
    final mobileOtpRegex = RegExp(r'^\d{6}$');
    isMobileOtpValid = mobileOtpRegex.hasMatch(value);
    notifyListeners();
  }
  // final validation
  bool validMobileOtp() {
    String value = mobileOtpController.text.trim();
    if (value.isEmpty) {
      mobileOtpError = 'Please enter OTP';
    } 
    else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      mobileOtpError = 'OTP must be digits only';
    } 
    else if (value.length != 6) {
      mobileOtpError = 'OTP must be 6 digits';
    } 
    else {
      mobileOtpError = null;
    }
    notifyListeners();
    return mobileOtpError == null;
  }

    /// VERIFY OTP API HIT
  Future<bool> verifyMobileOtp(BuildContext context) async {

    if(!validMobileOtp()) return false;

   var isLoading = true;
    notifyListeners();

    String mobile = context
        .read<SignUpScreenProvider>()
        .mobileController
        .text;

    String otp = mobileOtpController.text.trim();

    final result = await ApiService.verifyOtp(
      mobile: mobile,
      otp: otp,
    );

    isLoading = false;
    notifyListeners();

    if(result != null){

      String token = result["accessToken"];
      await TokenHelper.saveToken(token);

      print("TOKEN SAVED: $token");

      return true;
    }
    else{
      mobileOtpError = "Invalid OTP";
      notifyListeners();
      return false;
    }
  }
  
}
