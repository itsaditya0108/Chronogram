// import 'dart:convert';
import 'dart:convert';
import 'package:chronogram/app_helper/constent.dart';
import 'package:chronogram/app_helper/device_helper/device_helper.dart';
import 'package:chronogram/modal/user_detail_modal.dart';
import 'package:chronogram/app_helper/token_saver_helper/token_saver_helper.dart';
import 'package:chronogram/service/api_client.dart';

class ApiService {
  // static const String baseUrl = "http://192.168.1.4:8086/api";

  static final api = ApiClient();

  // static const String baseUrl =
  //     "https://glayds-unpainful-torri.ngrok-free.dev/api";
  static Future<Map<String, dynamic>> sendOtp(String mobile) async {
    try {
      const String sendOtpUrl = "auth/register/send-otp";
      final device = await DeviceHelper.getDeviceData();
      final response = await api.post(
        sendOtpUrl,
        data: {"mobileNumber": mobile, "deviceId": device["deviceId"]},
      );
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.data}");

      /// 🟢 SUCCESS
      if (response.statusCode == 200) {
        return {"status": "success"};
      }

      /// ❌ OTHER ERROR
      return response.data; //Response Error
    } catch (e) {
      print("API ERROR: $e");
      return {"error": Constent.sometingWntWrong};
    }
  }

  /// VERIFY OTP
  static Future<Map<String, dynamic>?> verifyOtp({
    required String mobile,
    required String otp,
  }) async {
    try {
      const url = "auth/verify-otp";

      final device = await DeviceHelper.getDeviceData();

      final response = await api.post(
        url,
        data: jsonEncode({"mobileNumber": mobile, "otpCode": otp, ...device}),
      );

      print("VERIFY STATUS: ${response.statusCode}");
      print("VERIFY BODY: ${response.data}");

      return response.data;
    } catch (e) {
      print("VERIFY ERROR: $e");
      return {"error": Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>> sendEmailOtp({
    required String email,
  }) async {
    try {
      const url = "auth/send-email-otp";
      String? regToken = await TokenHelper.getRegistrationToken();
      print("SEND EMAIL OTP REG TOKEN: $regToken");
      final response = await api.post(
        url,
        data: jsonEncode({"email": email, "registrationToken": regToken}),
      );
      print("SEND EMAIL OTP STATUS: ${response.statusCode}");
      print("SEND EMAIL OTP BODY: ${response.data}");

      /// 🟢 SUCCESS (NO JSON PARSE)
      if (response.statusCode == 200) {
        return response.data;
      }

      return response.data; //Response Error
    } catch (e) {
      print("SEND EMAIL OTP ERROR: $e");
      return {"error": Constent.sometingWntWrong};
    }
  }

  /// VERIFY EMAIL OTP FINAL SIGNUP
  static Future<Map<String, dynamic>?> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      String? registrationToken = await TokenHelper.getRegistrationToken();
      print("VERIFY EMAIL REG TOKEN: $registrationToken");
      const url = "auth/verify-email-registration-otp";
      final response = await api.post(
        url,
        data: jsonEncode({
          "email": email,
          "otpCode": otp,
          "registrationToken": registrationToken,
        }),
      );

      print("EMAIL OTP STATUS: ${response.statusCode}");
      print("EMAIL OTP BODY: ${response.data}");

      return response.data;
    } catch (e) {
      print("EMAIL OTP ERROR: $e");
      return {"error": Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>?> completeProfile({
    required String name,
    required String dob,
    required String mobile,
  }) async {
    try {
      const url = "auth/complete-profile";
      String? regToken = await TokenHelper.getRegistrationToken();
      print("PROFILE USING TOKEN: $regToken");
      final device = await DeviceHelper.getDeviceData();
      final response = await api.post(
        url,
        data: jsonEncode({
          "name": name,
          "dob": dob,
          "mobileNumber": mobile,
          "registrationToken": regToken,
          ...device,
        }),
      );
      print("PROFILE STATUS: ${response.statusCode}");
      print("PROFILE BODY: ${response.data}");
      if (response.statusCode == 200) {
        return response.data;
      }
      return response.data;
    } catch (e) {
      print("PROFILE ERROR: $e");
      return {"error": Constent.sometingWntWrong};
    }
  }

  /// 🔄 RESEND OTP (mobile + email)
  static Future<bool> resendOtp({String? mobile, String? email}) async {
    try {
      const url = "auth/register/resend-otp";
      Map<String, dynamic> body = {};
      if (mobile != null) {
        body["mobileNumber"] = mobile;
      }
      if (email != null) {
        String? regToken = await TokenHelper.getRegistrationToken();
        body["email"] = email;
        body["registrationToken"] = regToken;
      }
      final response = await api.post(url, data: jsonEncode(body));
      print("RESEND OTP STATUS: ${response.statusCode}");
      print("RESEND OTP BODY: ${response.data}");
      return response.statusCode == 200;
    } catch (e) {
      print("RESEND OTP ERROR: $e");
      return false;
    }
  }

  ////LOGIN Resend Otp
  static Future<bool> resendLoginOtp({String? mobile, String? email}) async {
    try {
      const url = "auth/login/resend-otp";
      Map<String, dynamic> body = {};
      if (mobile != null) {
        body["mobileNumber"] = mobile;
      }
      if (email != null) {
        String? regToken = await TokenHelper.getRegistrationToken();
        body["email"] = email;
        body["registrationToken"] = regToken;
      }
      final response = await api.post(url, data: jsonEncode(body));
      print("RESEND OTP STATUS: ${response.statusCode}");
      print("RESEND OTP BODY: ${response.data}");
      return response.statusCode == 200;
    } catch (e) {
      print("RESEND OTP ERROR: $e");
      return false;
    }
  }

  ////////
  static Future<Map<String, dynamic>> sendLoginOtp(String mobile) async {
    try {
      const url = "auth/login/send-otp";

      final device = await DeviceHelper.getDeviceData();

      final response = await api.post(
        url,
        data: jsonEncode({
          "mobileNumber": mobile,
          "deviceId": device["deviceId"], // 🔥 FIX HERE
        }),
      );
      print("SEND LOGIN OTP STATUS: ${response.statusCode}");
      print("SEND LOGIN OTP BODY: ${response.data}");

      if (response.statusCode == 200) {
        return {"status": "success"};
      }
      // Other Error
      return response.data;
    } catch (e) {
      print("LOGIN OTP ERROR: $e");
      return {'error': Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>> verifyLoginOtp({
    required String mobile,
    required String otp,
  }) async {
    try {
      const url = "auth/verify-login-otp";

      final device = await DeviceHelper.getDeviceData();

      final response = await api.post(
        url,
        data: jsonEncode({"mobileNumber": mobile, "otpCode": otp, ...device}),
      );

      print("LOGIN VERIFY STATUS: ${response.statusCode}");
      print("LOGIN VERIFY BODY: ${response.data}");

      final data = jsonDecode(response.data);

      /// 🟢 SUCCESS LOGIN
      if (response.statusCode == 200) {
        return {"status": "success", "token": data["accessToken"]};
      }
      /// 🟠 NEW DEVICE
      else if (response.statusCode == 401) {
        return {
          "status": "untrusted",
          "maskedEmail": data["maskedEmail"],
          "temporaryToken": data["temporaryToken"], // 🔥 FIX HERE
        };
      }
      /// 🔴 USER NOT FOUND (IMPORTANT)
      else if (response.statusCode == 400 ||
          data["message"].toString().contains("User not found")) {
        return response.data;
      }
      /// ❌ INVALID OTP
      else {
        return response.data;
      }
    } catch (e) {
      print("LOGIN VERIFY ERROR: $e");
      return {"error": Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>> verifyNewDeviceEmailOtp({
    required String mobile,
    required String otp,
    required String temporaryToken,
  }) async {
    try {
      const url = "auth/verify-new-device";

      final device = await DeviceHelper.getDeviceData();

      final response = await api.post(
        url,
        data: jsonEncode({
          "mobileNumber": mobile,
          "otp": otp,
          "temporaryToken": temporaryToken, // 🔥 FIX HERE
          ...device,
        }),
      );

      print("NEW DEVICE VERIFY STATUS: ${response.statusCode}");
      print("NEW DEVICE VERIFY BODY: ${response.data}");

      final data = jsonDecode(response.data);

      if (response.statusCode == 200) {
        return {"status": "success", "token": data["accessToken"]};
      }
      return response.data;
    } catch (e) {
      print("NEW DEVICE ERROR: $e");
      return {"error": Constent.sometingWntWrong};
    }
  }

  static Future<bool> resendNewDeviceOtp(String temporaryToken) async {
    try {
      const url = "auth/resend-new-device-otp";

      final response = await api.post(
        url,
        data: jsonEncode({
          "temporaryToken": temporaryToken, // 🔥 FIX HERE
        }),
      );

      print("NEW DEVICE RESEND STATUS: ${response.statusCode}");
      print("NEW DEVICE RESEND BODY: ${response.data}");
      print("TOKEN SENT: $temporaryToken");

      return response.statusCode == 200;
    } catch (e) {
      print("NEW DEVICE RESEND ERROR: $e");
      return false;
    }
  }

  static Future<UserDetailModal?> getUserProfile() async {
    try {
      String? token = await TokenHelper.getToken();
      const String url = "auth/me";

      final response = await api.get(url);

      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.data}");

      /// 🟢 SUCCESS
      if (response.statusCode == 200) {
        return UserDetailModal.fromJson(response.data);
      }

      /// 🔴 TOKEN EXPIRED / UNAUTHORIZED
      throw Exception(response.data);
    } catch (e) {
      print("PROFILE API ERROR: $e");
      rethrow;
    }
  }
}
