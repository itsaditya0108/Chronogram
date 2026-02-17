// import 'dart:convert';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {

  static Future<bool> sendOtp(String mobile) async {
    try {
      const String sendOtpUrl =
      "http://192.168.1.4:8086/api/auth/send-otp";
      print("API HIT START");

      final response = await http.post(
        Uri.parse(sendOtpUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "mobileNumber": mobile,
        }),
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
}
