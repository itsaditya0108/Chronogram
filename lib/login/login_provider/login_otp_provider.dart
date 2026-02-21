import 'dart:async';
import 'package:chronogram/home_screen/home_screen.dart';
import 'package:chronogram/login/login_screen/login_email.dart';
import 'package:chronogram/sign_up/sign_up_screen/sign_up_screen.dart';
import 'package:flutter/material.dart';
import '../../service/api_service.dart';
import '../../token_saver_helper/token_saver_helper.dart';

class LoginMobileOtpScreenProvider extends ChangeNotifier {
  TextEditingController mobileOtpController = TextEditingController();

  String? mobileOtpError;
  bool isMobileOtpValid = false;
  bool isLoading = false;

bool showRegisterButton = false;
bool showVerifyEmailButton = false;
String? maskedEmail; // for new device

  /// TIMER
  int seconds = 120;
  Timer? _timer;
  bool canResend = false;
  bool isResending = false;

  LoginMobileOtpScreenProvider() {
    mobileOtpController.addListener(checkMobileOtpFill);
    startTimer();
  }

  /// OTP realtime validation
  void checkMobileOtpFill() {
    String value = mobileOtpController.text.trim();
    isMobileOtpValid = RegExp(r'^\d{6}$').hasMatch(value);
    notifyListeners();
  }

  bool validMobileOtp() {
    String value = mobileOtpController.text.trim();

    if (value.isEmpty) {
      mobileOtpError = 'Enter OTP';
    } else if (value.length != 6) {
      mobileOtpError = 'OTP must be 6 digit';
    } else {
      mobileOtpError = null;
    }

    notifyListeners();
    return mobileOtpError == null;
  }

  /// 🔥 VERIFY LOGIN OTP
  // Future<bool> verifyLoginOtp(String mobile) async {
  //   if (!validMobileOtp()) return false;

  //   isLoading = true;
  //   notifyListeners();

  //   String otp = mobileOtpController.text.trim();

  //   final result = await ApiService.verifyLoginOtp(mobile: mobile, otp: otp);

  //   isLoading = false;
  //   notifyListeners();

  //   if (result != null) {
  //     String token = result["accessToken"];
  //     await TokenHelper.saveToken(token);

  //     print("LOGIN SUCCESS TOKEN: $token");

  //     return true;
  //   } else {
  //     mobileOtpError = "Invalid OTP";
  //     notifyListeners();
  //     return false;
  //   }
  // }

//   Future<void> verifyLoginOtp(BuildContext context, String mobile) async {
//   if(!validMobileOtp()) return;

//   String otp = mobileOtpController.text.trim();
//   final result = await ApiService.verifyLoginOtp(
//     mobile: mobile,
//     otp: otp,
//   );

//   /// ================= SUCCESS LOGIN =================
  
//   if(result["status"] == "success"){
//     String token = result["token"];
//     await TokenHelper.saveToken(token);
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const HomeScreen()),
//       (route) => false,
//     );
//   }

//   /// ================= USER NOT REGISTERED =================
  
//   else if(result["status"] == "not_registered"){
//     mobileOtpError = "User not found. Please register";
//     notifyListeners();
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Account not found"),
//         content: const Text("Please register first"),
//         actions: [
//           TextButton(
//             onPressed: (){
//               Navigator.pop(context);
//               Navigator.push(context,
//                 MaterialPageRoute(builder: (_) => const SignUpScreen()));
//             },
//             child: const Text("Register"),
//           )
//         ],
//       ),
//     );
//   }

//   /// ================= UNTRUSTED DEVICE =================
//   else if(result["status"] == "untrusted"){
//     String email = result["maskedEmail"];

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("New Device Login"),
//         content: Text("Verify email $email to continue"),
//         actions: [
//           TextButton(
//             onPressed: (){
//               Navigator.pop(context);
//             },
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: (){
//               Navigator.pop(context);
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => EmailScreen(
//                     mobile: mobile,
//                     maskedEmail: email,
//                   ),
//                 ),
//               );
//             },
//             child: const Text("Verify Email"),
//           )
//         ],
//       ),
//     );
//   }

//   /// ================= INVALID OTP =================
//   else{
//     mobileOtpError = "Invalid OTP";
//     notifyListeners();
//   }
// }
Future<void> verifyLoginOtp(
  BuildContext context,
  String mobile,
) async {

  if (!validMobileOtp()) return;

  isLoading = true;
  showRegisterButton = false;
  showVerifyEmailButton = false;
  mobileOtpError = null;
  notifyListeners();

  final result = await ApiService.verifyLoginOtp(
    mobile: mobile,
    otp: mobileOtpController.text.trim(),
  );

  isLoading = false;

  /// ✅ LOGIN SUCCESS
  if (result["status"] == "success") {

    await TokenHelper.saveToken(result["token"]);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  /// 🔥 NEW DEVICE (401)
  else if (result["status"] == "untrusted") {

    maskedEmail = result["maskedEmail"];

    mobileOtpError =
        "New device detected. Verify email to continue";

    showVerifyEmailButton = true;
    notifyListeners();
  }

  /// 🔴 USER NOT REGISTERED
  else if (result["status"] == "not_found") {

    mobileOtpError =
        "User not registered. Please register first";

    showRegisterButton = true;
    notifyListeners();
  }

  /// ❌ INVALID OTP
  else {
    mobileOtpError = "Invalid OTP";
    notifyListeners();
  }
}
  /// TIMER START
  void startTimer() {
    seconds = 120;
    canResend = false;

    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds > 0) {
        seconds--;
        notifyListeners();
      } else {
        canResend = true;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  /// TIMER TEXT
  String get timerText {
    int minutes = seconds ~/ 60;
    int sec = seconds % 60;

    if (minutes > 0) {
      if (sec == 0) return "$minutes min";
      return "$minutes min $sec sec";
    } else {
      return "$sec sec";
    }
  }

  /// 🔥 RESEND OTP
  Future<void> resendOtp(String mobile) async {
    if (isResending) return;

    isResending = true;
    notifyListeners();

    bool sent = await ApiService.resendOtp(mobile: mobile);

    isResending = false;

    if (sent) {
      startTimer();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    mobileOtpController.dispose();
    super.dispose();
  }

}
