// import 'package:flutter/material.dart';

// class SignUpEmailOtpProvider extends ChangeNotifier {
  
//   TextEditingController emailOtpController = TextEditingController();
//   String? emailOtpError;
//   bool isEmailOtpValid = false;
//   // constructor
//   SignUpEmailOtpProvider(){
//    emailOtpController.addListener(checkEmailOtpFill); // 👈 listener
//   }
//   // realtime check for button enable
//   void checkEmailOtpFill(){
//     String value = emailOtpController.text.trim();
//     final emailOtpRegex = RegExp(r'^\d{6}$');
//     isEmailOtpValid = emailOtpRegex.hasMatch(value);
//     notifyListeners();
//   }
  
//   // final validation
//   bool validEmailOtp() {
//     String value = emailOtpController.text.trim();
//     if (value.isEmpty) {
//      emailOtpError = 'Please enter OTP';
//     } 
//     else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//       emailOtpError = 'OTP must be digits only';
//     } 
//     else if (value.length != 6) {
//       emailOtpError = 'OTP must be 6 digits';
//     } 
//     else {
//       emailOtpError = null;
//     }
//     notifyListeners();
//     return emailOtpError == null;
//   }
  
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../service/api_service.dart';
import '../../token_saver_helper/token_saver_helper.dart';

class SignUpEmailOtpProvider extends ChangeNotifier {

  TextEditingController emailOtpController = TextEditingController();
  String? emailOtpError;
  bool isEmailOtpValid = false;
  bool isLoading = false;

  SignUpEmailOtpProvider(){
    emailOtpController.addListener(checkEmailOtpFill);
  }

  void checkEmailOtpFill(){
    String value = emailOtpController.text.trim();
    isEmailOtpValid = RegExp(r'^\d{6}$').hasMatch(value);
    notifyListeners();
  }

  bool validEmailOtp() {
    String value = emailOtpController.text.trim();

    if (value.isEmpty) {
      emailOtpError = 'Enter OTP';
    } else if (value.length != 6) {
      emailOtpError = 'OTP must be 6 digit';
    } else {
      emailOtpError = null;
    }

    notifyListeners();
    return emailOtpError == null;
  }

  /// FINAL VERIFY EMAIL OTP
  Future<bool> verifyEmailOtpApi(String email) async {

    if(!validEmailOtp()) return false;

    isLoading = true;
    notifyListeners();

    String otp = emailOtpController.text.trim();
    String? regToken = await TokenHelper.getRegistrationToken();

    final result = await ApiService.verifyEmailOtp(
      email: email,
      otp: otp,
      registrationToken: regToken ?? "",
    );

    isLoading = false;
    notifyListeners();

    if(result != null){

      String accessToken = result["accessToken"];
      await TokenHelper.saveToken(accessToken);

      print("FINAL LOGIN SUCCESS");
      return true;
    }
    else{
      emailOtpError = "Invalid OTP";
      notifyListeners();
      return false;
    }
  }
}
