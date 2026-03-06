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
  static Map<String, dynamic> _cleanMap(Map<String, dynamic> map) {
    // Spring Boot often puts the real error in 'error' and the path in 'message' for 400/500/429
    if (map.containsKey('error') && map['error'] != null) {
      String errMsg = map['error'].toString();
      if (map.containsKey('message')) {
         String msg = map['message'].toString();
         if (msg.startsWith('uri=') || msg.startsWith('path=')) {
            map['message'] = errMsg;
         }
      } else {
        map['message'] = errMsg;
      }
    }

    if (map.containsKey('message') && map['message'] != null) {
      String msg = map['message'].toString();
      final exceptionMatch = RegExp(r'Exception: (.*)').firstMatch(msg);
      if (exceptionMatch != null) {
        String match = exceptionMatch.group(1) ?? "";
        if (match.endsWith("]")) {
           match = match.substring(0, match.length - 1);
        }
        map['message'] = match.trim();
      }
    }
    return map;
  }

  static Map<String, dynamic> _parseData(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) {
      return _cleanMap(data);
    }
    if (data is Map) {
      return _cleanMap(Map<String, dynamic>.from(data));
    }
    if (data is String) {
      if (data.isEmpty) return {};
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          return _cleanMap(Map<String, dynamic>.from(decoded));
        }
      } catch (e) {
        if (data.contains("url=")) {
           return {"message": "Email already registered or invalid"};
        }
        return {"message": data};
      }
    }
    
    // Fallback if data is passed as some object with a weird toString representation
    String strData = data.toString();
    
    // Check for raw Spring Boot exception strings in HTML or plain text
    final exceptionMatch = RegExp(r'Exception: (.*)').firstMatch(strData);
    if (exceptionMatch != null) {
        String match = exceptionMatch.group(1) ?? "";
        // Clean up any trailing brackets if it was wrapped in an array like [Exception: ...]
        if (match.endsWith("]")) {
           match = match.substring(0, match.length - 1);
        }
        return {"message": match.trim()};
    }
    
    if (strData.contains("url=") || strData.contains("path=") || (strData.startsWith("{") && strData.contains("}"))) {
       // if we got a weird spring boot error map stringification, extract the message if possible.
       final match = RegExp(r'message=([^,]+)').firstMatch(strData);
       if (match != null) {
          return {"message": match.group(1)};
       }
       final bodyMatch = RegExp(r'body=([^,]+)').firstMatch(strData);
       if (bodyMatch != null) {
           return {"message": bodyMatch.group(1)};
       }
       return {"message": "Email already registered or invalid"};
    }
    return {"message": strData};
  }

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

      final parsedData = _parseData(response.data);

      /// 🟢 SUCCESS
      if (response.statusCode == 200) {
        if (parsedData["otpSessionToken"] != null) {
          await TokenHelper.saveOtpSessionToken(parsedData["otpSessionToken"]);
        }
        return {"status": "success"};
      }

      /// ❌ OTHER ERROR
      return parsedData; //Response Error
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
      final otpSessionToken = await TokenHelper.getOtpSessionToken();

      final response = await api.post(
        url,
        data: jsonEncode({
          "mobileNumber": mobile, 
          "otpCode": otp, 
          "otpSessionToken": otpSessionToken,
          ...device
        }),
      );

      print("VERIFY STATUS: ${response.statusCode}");
      print("VERIFY BODY: ${response.data}");

      final data = _parseData(response.data);
      data['statusCode'] = response.statusCode;
      return data;
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
      final device = await DeviceHelper.getDeviceData();
      print("SEND EMAIL OTP REG TOKEN: $regToken");
      final response = await api.post(
        url,
        data: jsonEncode({
          "email": email, 
          "registrationToken": regToken,
          "deviceId": device["deviceId"],
        }),
      );
      print("SEND EMAIL OTP STATUS: ${response.statusCode}");
      print("SEND EMAIL OTP BODY: ${response.data}");
      print("TYPE: ${response.data.runtimeType}");

      final data = _parseData(response.data);
      data['statusCode'] = response.statusCode;

      /// 🟢 SUCCESS (NO JSON PARSE)
      if (response.statusCode == 200) {
        return data;
      }

      return data; //Response Error
    } catch (e) {
      print("SEND EMAIL OTP ERROR: $e");
      return {"error": Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>> resendRegistrationEmailOtp({
    required String email,
  }) async {
    try {
      const url = "auth/register/resend-email-otp";
      String? regToken = await TokenHelper.getRegistrationToken();
      final device = await DeviceHelper.getDeviceData();
      final response = await api.post(
        url,
        data: jsonEncode({
          "email": email, 
          "registrationToken": regToken,
          "deviceId": device["deviceId"],
        }),
      );
      print("RESEND EMAIL OTP STATUS: ${response.statusCode}");
      print("RESEND EMAIL OTP BODY: ${response.data}");

      final data = _parseData(response.data);
      data['statusCode'] = response.statusCode;

      return data;
    } catch (e) {
      print("RESEND EMAIL OTP ERROR: $e");
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

      final data = _parseData(response.data);
      data['statusCode'] = response.statusCode;
      return data;
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
        return _parseData(response.data);
      }
      return _parseData(response.data);
    } catch (e) {
      print("PROFILE ERROR: $e");
      return {"error": Constent.sometingWntWrong};
    }
  }

  /// 🔄 RESEND OTP (mobile + email)
  static Future<bool> resendOtp({String? mobile, String? email}) async {
    try {
      final device = await DeviceHelper.getDeviceData();
      String url = "";
      Map<String, dynamic> body = {};
      
      if (email != null) {
        url = "auth/register/resend-email-otp";
        String? regToken = await TokenHelper.getRegistrationToken();
        body["email"] = email;
        body["registrationToken"] = regToken;
        body["deviceId"] = device["deviceId"];
      } else if (mobile != null) {
        url = "auth/register/resend-mobile-otp";
        body["mobileNumber"] = mobile;
        body["deviceId"] = device["deviceId"];
      } else {
        return false;
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
      final device = await DeviceHelper.getDeviceData();
      Map<String, dynamic> body = {};
      if (mobile != null) {
        body["mobileNumber"] = mobile;
        body["deviceId"] = device["deviceId"];
      }
      if (email != null) {
        String? regToken = await TokenHelper.getRegistrationToken();
        body["email"] = email;
        body["registrationToken"] = regToken;
        // email resend on login usually goes to resendNewDeviceOtp with temporaryToken, but handled here just in case.
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

      final parsedData = _parseData(response.data);

      if (response.statusCode == 200) {
        if (parsedData["otpSessionToken"] != null) {
          await TokenHelper.saveOtpSessionToken(parsedData["otpSessionToken"]);
        }
        return {"status": "success"};
      }
      // Other Error
      return parsedData;
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
      final otpSessionToken = await TokenHelper.getOtpSessionToken();

      final response = await api.post(
        url,
        data: jsonEncode({
          "mobileNumber": mobile, 
          "otpCode": otp, 
          "otpSessionToken": otpSessionToken,
          ...device
        }),
      );

      print("LOGIN VERIFY STATUS: ${response.statusCode}");
      print("LOGIN VERIFY BODY: ${response.data}");

      final data = _parseData(response.data);
      data['statusCode'] = response.statusCode;

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
        return data; // using original map as return
      }
      /// ❌ INVALID OTP
      else {
        return data;
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

      final data = _parseData(response.data);
      data['statusCode'] = response.statusCode;

      if (response.statusCode == 200) {
        return {"status": "success", "token": data["accessToken"]};
      }
      return data;
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
        return UserDetailModal.fromJson(_parseData(response.data));
      }

      /// 🔴 TOKEN EXPIRED / UNAUTHORIZED
      throw Exception(response.data);
    } catch (e) {
      print("PROFILE API ERROR: $e");
      rethrow;
    }
  }
  static Future<bool> logout() async {
    try {
      String? token = await TokenHelper.getToken();
      
      // Ideally read the refreshToken from secure storage if we save it securely.
      // Since it's requested via Query Param per documentation:
      // ?refreshToken=YOUR_REFRESH_TOKEN
      // If we don't have a secure token store yet, we may need to pass it dynamically.
      // For now, implementing the core API call.
      String? refreshToken = await TokenHelper.getToken(); // Placeholder, usually refresh is saved separately

      if (token == null) return false;

      final String url = "auth/logout?refreshToken=$refreshToken";

      final response = await api.post(
         url,
      );

      print("LOGOUT STATUS CODE: ${response.statusCode}");
      print("LOGOUT BODY: ${response.data}");

      if (response.statusCode == 200) {
        await TokenHelper.removeToken();
        // await TokenHelper.removeRefreshToken(); // When implemented
        return true;
      }
      return false;
    } catch (e) {
      print("LOGOUT API ERROR: $e");
      return false;
    }
  }
}
