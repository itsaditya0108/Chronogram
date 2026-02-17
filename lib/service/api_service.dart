// import 'dart:convert';
import 'dart:convert';
import 'package:chronogram/device_helper/device_helper.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<bool> sendOtp(String mobile) async {
    try {
      const String sendOtpUrl = "http://192.168.1.4:8086/api/auth/send-otp";
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
      const url = "http://192.168.1.4:8086/api/auth/verify-otp";

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
  
}
