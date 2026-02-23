// import 'dart:convert';
import 'dart:convert';
import 'package:chronogram/device_helper/device_helper.dart';
import 'package:chronogram/token_saver_helper/token_saver_helper.dart';
import 'package:http/http.dart' as http;

class ApiService {
static const String baseUrl = "http://192.168.1.4:8086/api";
  static Future<bool> sendOtp(String mobile) async {
    try {
      const String sendOtpUrl = "$baseUrl/auth/send-otp";
      print("API HIT START");
      final response = await http.post(
        Uri.parse(sendOtpUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"mobileNumber": mobile}),
      );
      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("API ERROR: $e");
      return false;
    }
  }

  /// VERIFY OTP
  static Future<Map<String, dynamic>?> verifyOtp({
    required String mobile,
    required String otp,
  }) async {
    try {
      const url = "$baseUrl/auth/verify-otp";

      final device = await DeviceHelper.getDeviceData();

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"mobileNumber": mobile, "otpCode": otp, ...device}),
      );

      print("VERIFY STATUS: ${response.statusCode}");
      print("VERIFY BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print("VERIFY ERROR: $e");
      return null;
    }
  }



static Future<bool> sendEmailOtp({
  required String email,
}) async {
  try {
    const url = "$baseUrl/auth/send-email-otp";

    String? regToken = await TokenHelper.getRegistrationToken();
    print("SEND EMAIL OTP REG TOKEN: $regToken");

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "registrationToken": regToken,
      }),
    );
    print("SEND EMAIL OTP STATUS: ${response.statusCode}");
    print("SEND EMAIL OTP BODY: ${response.body}");

    return response.statusCode == 200;
  } catch (e) {
    print("SEND EMAIL OTP ERROR: $e");
    return false;
  }
}

/// VERIFY EMAIL OTP FINAL SIGNUP
static Future<Map<String, dynamic>?> verifyEmailOtp({
  required String email,
  required String otp,
  required String registrationToken,
}) async {
  try {
    const url = "$baseUrl/auth/verify-email-registration-otp";
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otpCode": otp,
        "registrationToken": registrationToken,
      }),
    );

    print("EMAIL OTP STATUS: ${response.statusCode}");
    print("EMAIL OTP BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }

  } catch (e) {
    print("EMAIL OTP ERROR: $e");
    return null;
  }
}


static Future<Map<String, dynamic>?> completeProfile({
  required String name,
  required String dob,
  required String mobile,
}) async {
  try {
    const url = "$baseUrl/auth/complete-profile";

    String? regToken = await TokenHelper.getRegistrationToken();
    print("PROFILE USING TOKEN: $regToken");

    final device = await DeviceHelper.getDeviceData();

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "dob": dob,
        "mobileNumber": mobile, // 🔥 IMPORTANT ADD
        "registrationToken": regToken,
        ...device
      }),
    );
    print("PROFILE STATUS: ${response.statusCode}");
    print("PROFILE BODY: ${response.body}");
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  } catch (e) {
    print("PROFILE ERROR: $e");
    return null;
  }
}

/// 🔄 RESEND OTP (mobile + email)
static Future<bool> resendOtp({
  String? mobile,
  String? email,
}) async {
  try {
    const url = "$baseUrl/auth/resend-otp";
    Map<String, dynamic> body = {};
    if (mobile != null) {
      body["mobileNumber"] = mobile;
    }
    if (email != null) {
      String? regToken = await TokenHelper.getRegistrationToken();
      body["email"] = email;
      body["registrationToken"] = regToken;
    }
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    print("RESEND OTP STATUS: ${response.statusCode}");
    print("RESEND OTP BODY: ${response.body}");
    return response.statusCode == 200;
  } catch (e) {
    print("RESEND OTP ERROR: $e");
    return false;
  }
}

static Future<bool> sendLoginOtp(String mobile) async {
  try {
    const url = "$baseUrl/auth/send-otp";

    final device = await DeviceHelper.getDeviceData();

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "mobileNumber": mobile,
        ...device,
      }),
    );

    print("SEND LOGIN OTP STATUS: ${response.statusCode}");
    print("SEND LOGIN OTP BODY: ${response.body}");

    return response.statusCode == 200;
  } catch (e) {
    print("LOGIN OTP ERROR: $e");
    return false;
  }
}


static Future<Map<String, dynamic>> verifyLoginOtp({
  required String mobile,
  required String otp,
}) async {

  try {
    const url = "$baseUrl/auth/verify-login-otp";

    final device = await DeviceHelper.getDeviceData();

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "mobileNumber": mobile,
        "otpCode": otp,
        ...device
      }),
    );

    print("LOGIN VERIFY STATUS: ${response.statusCode}");
    print("LOGIN VERIFY BODY: ${response.body}");

    final data = jsonDecode(response.body);

    /// 🟢 SUCCESS LOGIN
    if (response.statusCode == 200) {
      return {
        "status": "success",
        "token": data["accessToken"]
      };
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
      return {
        "status": "not_found"
      };
    }

    /// ❌ INVALID OTP
    else {
      return {
        "status": "invalid"
      };
    }

  } catch (e) {
    print("LOGIN VERIFY ERROR: $e");
    return {"status": "error"};
  }
}

static Future<Map<String, dynamic>> verifyNewDeviceEmailOtp({
  required String mobile,
  required String otp,
  required String temporaryToken,
}) async {
  try {
    const url = "$baseUrl/auth/verify-new-device";

    final device = await DeviceHelper.getDeviceData();

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "mobileNumber": mobile,
        "otp": otp,
        "temporaryToken": temporaryToken, // 🔥 FIX HERE
        ...device
      }),
    );

    print("NEW DEVICE VERIFY STATUS: ${response.statusCode}");
    print("NEW DEVICE VERIFY BODY: ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        "status": "success",
        "token": data["accessToken"]
      };
    } else {
      return {"status": "error"};
    }
  } catch (e) {
    print("NEW DEVICE ERROR: $e");
    return {"status": "error"};
  }
}

static Future<bool> resendNewDeviceOtp(String temporaryToken) async {
  try {
    const url = "$baseUrl/auth/resend-new-device-otp";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "temporaryToken": temporaryToken,   // 🔥 FIX HERE
      }),
    );

    print("NEW DEVICE RESEND STATUS: ${response.statusCode}");
    print("NEW DEVICE RESEND BODY: ${response.body}");
    print("TOKEN SENT: $temporaryToken");

    return response.statusCode == 200;
  } catch (e) {
    print("NEW DEVICE RESEND ERROR: $e");
    return false;
  }
}



}
