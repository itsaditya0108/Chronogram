import 'dart:convert';
import 'dart:io';
import 'package:chronogram/app_helper/constent.dart';
import 'package:chronogram/app_helper/device_helper/device_helper.dart';
import 'package:chronogram/modal/user_detail_modal.dart';
import 'package:chronogram/app_helper/token_saver_helper/token_saver_helper.dart';
import 'package:chronogram/service/api_client.dart';
import 'package:chronogram/service/image_api_client.dart';
import 'package:chronogram/service/video_api_client.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' hide MultipartFile, Response;

class ApiService {
  static final api = ApiClient();
  static final imageApi = ImageApiClient();
  static final videoApi = VideoApiClient();
  final ApiClient client = ApiClient();


  /// ================== ERROR MAPPING & SANITIZATION ==================
  
  static const Map<String, String> _errorMessages = {
    "Invalid mobile number format": "Please enter a valid 10-digit mobile number.",
    "Device ID is required": "Device initialization error. Please restart the app.",
    "User already registered. Please login.": "This number is already registered. Please login instead.",
    "Your account is temporarily locked": "Your account is locked for 15 minutes due to multiple failed attempts.",
    "Invalid Mobile OTP": "Incorrect OTP. Please check and try again.",
    "OTP not found or expired": "OTP has expired. Please request a new one.",
    "Invalid session": "Session expired. Please request a new OTP.",
    "OTP session mismatch": "Security session mismatch. Please request a new OTP.",
    "Email is required for registration": "Email address is required.",
    "Invalid email format": "Please enter a valid email address.",
    "Email already in use": "This email is already associated with another account.",
    "Invalid registration token": "Registration session expired. Please start over.",
    "Invalid OTP": "Incorrect OTP. Please try again.",
    "OTP expired": "OTP has expired. Please try resending.",
    "Only alphabetic characters": "Name should only contain letters.",
    "Users must be 12 years or older": "You must be at least 12 years old to register.",
    "User not found. Please register.": "This number is not registered. Please sign up first.",
    "APPROVAL_REQUIRED": "New device detected. OTP sent to your email.",
    "INVALID_OTP_SESSION": "Session expired. Please request a new OTP.",
    "OTP_EXPIRED": "OTP has expired. Please resend.",
    "Account deleted.": "This account has been deleted. Please contact support.",
    "Mobile verified. Verify Email to proceed.": "Mobile verified. Please verify your email.",
    "Email verified. Complete profile": "Email verified. Please complete your profile.",
    "Maximum OTP attempts reached": "Maximum OTP attempts reached. Please try again after 15 minutes.",
  };

  static String _getMappedMessage(String technicalMsg) {
    for (var entry in _errorMessages.entries) {
      if (technicalMsg.contains(entry.key)) {
        return entry.value;
      }
    }
    return Constent.sometingWntWrong; // Sanitized generic fallback
  }

  static Map<String, dynamic> _cleanMap(Map<String, dynamic> map, {int? statusCode}) {
    // 1. Handle Network Errors from ApiClient
    if (map.containsKey('isNetworkError') && map['isNetworkError'] == true) {
      return map; 
    }

    // 2. Handle 429 Too Many Requests (Rate Limiting)
    if (statusCode == 429) {
      String blockMsg = _errorMessages["Your account is temporarily locked"]!;
      String? msgInput = map['message']?.toString();
      String? errInput = map['error']?.toString();
      
      // Prioritize actual text over uri=/path=
      String? raw;
      if (errInput != null && !errInput.startsWith('uri=') && !errInput.startsWith('path=')) {
        raw = errInput;
      } else if (msgInput != null && !msgInput.startsWith('uri=') && !msgInput.startsWith('path=')) {
        raw = msgInput;
      } else {
        raw = msgInput ?? errInput;
      }

      if (raw != null) {
        // If the message contains specific wait time, use it
        bool hasWait = raw.toLowerCase().contains("wait") || raw.toLowerCase().contains("minute");
        if (hasWait) {
          blockMsg = raw;
        } else {
          String mapped = _getMappedMessage(raw);
          if (mapped != Constent.sometingWntWrong) {
            blockMsg = mapped;
          }
        }
      }
      return {"message": blockMsg, "isBlocked": true, "error": blockMsg, "statusCode": 429};
    }

    // 3. Handle 410 Gone (Deleted Account)
    if (statusCode == 410) {
      String msg = _errorMessages["Account deleted."]!;
      return {"message": msg, "error": msg, "statusCode": 410, "isDeleted": true};
    }

    // 4. Handle 403 Forbidden (Security Mismatches)
    if (statusCode == 403) {
      String msg = "Access denied. Please try again.";
      if (map.containsKey('message') || map.containsKey('error')) {
        msg = _getMappedMessage((map['message'] ?? map['error']).toString());
      }
      return {"message": msg, "error": msg, "statusCode": 403};
    }

    // 4. Spring Boot technical message handling
    String? msgInput = map['message']?.toString();
    String? errInput = map['error']?.toString();
    
    // Prioritize the field that actually contains text (not just uri=...)
    String? currentMessage;
    if (errInput != null && !errInput.startsWith('uri=') && !errInput.startsWith('path=')) {
      currentMessage = errInput;
    } else if (msgInput != null && !msgInput.startsWith('uri=') && !msgInput.startsWith('path=')) {
      currentMessage = msgInput;
    } else {
      currentMessage = msgInput ?? errInput;
    }
    
    if (currentMessage != null) {
      // Clean up "Exception: " prefix if present
      final exceptionMatch = RegExp(r'Exception: (.*)').firstMatch(currentMessage);
      if (exceptionMatch != null) {
        currentMessage = exceptionMatch.group(1) ?? currentMessage;
        if (currentMessage.endsWith("]")) {
          currentMessage = currentMessage.substring(0, currentMessage.length - 1);
        }
      }

      // If it's still a technical URI/Path, use generic fallback UNLESS it's a known rate-limit/already-sent case
      if (currentMessage.startsWith('uri=') || currentMessage.startsWith('path=')) {
        if (currentMessage.contains('send-otp') || currentMessage.contains('resend')) {
          final waitMatch = RegExp(r'wait (\d+) seconds').firstMatch(currentMessage);
          if (waitMatch != null) {
            String seconds = waitMatch.group(1)!;
            String sanitized = "OTP already sent. Please wait $seconds seconds.";
            map['message'] = sanitized;
            map['error'] = sanitized;
            map['isAlreadySent'] = true;
          } else {
            String sanitized = "OTP already sent. Please wait or check your messages.";
            map['message'] = sanitized;
            map['error'] = sanitized;
            map['isAlreadySent'] = true;
          }
        } else {
          map['message'] = Constent.sometingWntWrong; 
          map['error'] = Constent.sometingWntWrong;
        }
      } else {
        // Apply mapping for known technical strings
        String sanitized = _getMappedMessage(currentMessage.trim());
        
        // 🟢 IMPROVED SUCCESS HANDLING: 
        // If it's a success code (2xx), or if the message is already friendly (doesn't look technical),
        // and no mapping was found, PRESERVE the original message.
        bool isSuccess = (statusCode != null && statusCode >= 200 && statusCode < 300);
        if (sanitized == Constent.sometingWntWrong && isSuccess) {
           sanitized = currentMessage.trim();
        }

        // 🛑 PRESERVE "attempts remaining" or "wait X seconds" even if sanitized
        if (currentMessage.toLowerCase().contains("attempts remaining")) {
          final attemptsMatch = RegExp(r'(\d+) attempts remaining', caseSensitive: false).firstMatch(currentMessage);
          if (attemptsMatch != null) {
            String count = attemptsMatch.group(1)!;
            if (sanitized == Constent.sometingWntWrong) sanitized = "Incorrect OTP.";
            sanitized = "$sanitized $count attempts remaining.";
          }
        }
        
        // 🔍 DEBUG LOG: Technical vs User Message
        print("I/flutter: [API_SERVICE] TECHNICAL: $currentMessage | SANITIZED: $sanitized | STATUS: $statusCode");

        map['message'] = sanitized;
        map['error'] = sanitized; // Ensure both are consistent for UI providers
        
        // Add bypass flag if it matches bypassable patterns
        if (sanitized.contains("already sent") || sanitized.contains("already exists") || sanitized.contains("OTP sent successfully") || sanitized.contains("successful")) {
          map['isAlreadySent'] = true;
        }
      }
    }
    
    // 🔍 DEBUG LOG: Technical vs User Message
    print("I/flutter: [API_SERVICE] FINAL_DATA: $map");
    
    return map;
  }

  static Map<String, dynamic> _parseData(dynamic data, {int? statusCode}) {
    Map<String, dynamic> resultMap = {};
    
    if (data == null) {
      resultMap = {};
    } else if (data is Map<String, dynamic>) {
      resultMap = _cleanMap(data, statusCode: statusCode);
    } else if (data is Map) {
      resultMap = _cleanMap(Map<String, dynamic>.from(data), statusCode: statusCode);
    } else if (data is String) {
      if (data.isNotEmpty) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map) {
            resultMap = _cleanMap(Map<String, dynamic>.from(decoded), statusCode: statusCode);
          } else {
            resultMap = {"message": data};
          }
        } catch (e) {
          if (data.contains("url=") || data.contains("path=")) {
            resultMap = {"message": "Action failed. Please try again."};
          } else {
            resultMap = {"message": data};
          }
        }
      }
    } else {
      String strData = data.toString();
      final exceptionMatch = RegExp(r'Exception: (.*)').firstMatch(strData);
      if (exceptionMatch != null) {
          String match = exceptionMatch.group(1) ?? "";
          if (match.endsWith("]")) match = match.substring(0, match.length - 1);
          resultMap = {"message": match.trim()};
      } else if (strData.contains("url=") || strData.contains("path=")) {
         final match = RegExp(r'message=([^,]+)').firstMatch(strData);
         if (match != null) resultMap = {"message": match.group(1)};
         else resultMap = {"message": "Action failed. Please try again."};
      } else {
        resultMap = {"message": strData};
      }
    }

    if (statusCode != null) {
      resultMap['statusCode'] = statusCode;
    }
    return resultMap;
  }

  /// ================== FIREBASE LOGIN ==================

  static Future<Map<String, dynamic>> firebaseLogin(String idToken) async {
    try {
      const String url = "auth/firebase-login";
      final device = await DeviceHelper.getDeviceData();
      final otpSessionToken = await TokenHelper.getOtpSessionToken();

      final response = await api.post(url, data: {
        "firebaseIdToken": idToken,
        "otpSessionToken": otpSessionToken,
        ...device,
      });
      print("[API] firebaseLogin ← ${response.statusCode} | ${response.data}");

      // Extract raw message BEFORE _parseData sanitizes it, so callers can check backend step info.
      String rawMessage = '';
      if (response.data is Map) {
        rawMessage = (response.data['message'] ?? '').toString();
      }

      final data = _parseData(response.data, statusCode: response.statusCode);

      if (response.statusCode == 200 || response.statusCode == 201) {
         // 🔑 Robust Token Extraction
         String? accessToken = data["accessToken"] ?? data["token"] ?? data["registrationToken"];
         String? refreshToken = data["refreshToken"];

         if (accessToken != null) {
          if (refreshToken != null && refreshToken.isNotEmpty) {
            await TokenHelper.saveToken(accessToken);
            await TokenHelper.saveRefreshToken(refreshToken);
            return {"status": "success", "rawMessage": rawMessage, ...data};
          } else {
             // 🕒 NEW/INCOMPLETE USER: Save as registration token
             await TokenHelper.saveRegistrationToken(accessToken);
             return {"status": "incomplete", "rawMessage": rawMessage, ...data};
          }
         }
         return {"status": "success", "rawMessage": rawMessage, ...data};
      } else if (response.statusCode == 401 && data["message"].toString().contains("APPROVAL_REQUIRED")) {
        return {
          "status": "untrusted",
          "maskedEmail": data["maskedEmail"],
          "temporaryToken": data["temporaryToken"],
          "message": data["message"],
        };
      } else if (response.statusCode == 404 || data["message"].toString().contains("register") || data["message"].toString().contains("not found")) {
        return {"status": "not_found", ...data};
      }

      return {"status": "error", ...data};

    } catch (e) {
      return {"status": "error", "error": Constent.sometingWntWrong};
    }
  }

  /// ================== REGISTRATION FLOW ==================

  /// [skipSms] = true: Backend validates user existence only; Firebase sends the SMS.
  static Future<Map<String, dynamic>> sendOtp(String mobile, {bool skipSms = false}) async {
    try {
      const String url = "auth/register/send-otp";
      final device = await DeviceHelper.getDeviceData();
      final response = await api.post(url, data: {
        "mobileNumber": mobile,
        ...device,
        if (skipSms) "skipSms": true,
      });
      print("[API] sendOtp ← ${response.statusCode} | ${response.data}");
      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        if (data["otpSessionToken"] != null) {
          await TokenHelper.saveOtpSessionToken(data["otpSessionToken"]);
        }
        return {"status": "success", ...data};
      }
      return data;
    } catch (e) {
      return {"error": Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>?> verifyOtp({required String mobile, required String otp}) async {
    try {
      const url = "auth/verify-otp";
      final device = await DeviceHelper.getDeviceData();
      final otpSessionToken = await TokenHelper.getOtpSessionToken();

      final response = await api.post(url, data: {
        "mobileNumber": mobile, 
        "otpCode": otp, 
        "otpSessionToken": otpSessionToken,
        ...device
      });
      print("[API] verifyOtp ← ${response.statusCode} | ${response.data}");
      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        if (data["accessToken"] != null) {
          await TokenHelper.saveRegistrationToken(data["accessToken"]);
        }
        data["status"] = "success";
      }
      return data;
    } catch (e) {
      return {"error": Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>> sendEmailOtp({required String email}) async {
    try {
      const url = "auth/send-email-otp";
      String? regToken = await TokenHelper.getRegistrationToken();
      final device = await DeviceHelper.getDeviceData();
      final response = await api.post(url, data: {
        "email": email, 
        "registrationToken": regToken,
        "deviceId": device["deviceId"],
      });
      print("[API] sendEmailOtp ← ${response.statusCode} | ${response.data}");
      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        if (data["accessToken"] != null) {
          await TokenHelper.saveRegistrationToken(data["accessToken"]);
        }
        data["status"] = "success";
      }
      return data;
    } catch (e) {
      return {"error": Constent.sometingWntWrong};
    }
  }


  static Future<Map<String, dynamic>?> verifyEmailOtp({required String email, required String otp}) async {
    try {
      String? regToken = await TokenHelper.getRegistrationToken();
      const url = "auth/verify-email-registration-otp";
      final response = await api.post(url, data: {
        "email": email,
        "otpCode": otp,
        "registrationToken": regToken,
      });
      print("[API] verifyEmailOtp ← ${response.statusCode} | ${response.data}");
      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
         if (data["accessToken"] != null) {
           await TokenHelper.saveRegistrationToken(data["accessToken"]);
         }
         data["status"] = "success";
      }
      return data;
    } catch (e) {
      return {"error": Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>?> completeProfile({required String name, required String dob, required String mobile}) async {
    try {
      const url = "auth/complete-profile";
      String? regToken = await TokenHelper.getRegistrationToken();
      final device = await DeviceHelper.getDeviceData();
      final response = await api.post(url, data: {
        "name": name,
        "dob": dob,
        "mobileNumber": mobile,
        "registrationToken": regToken,
        ...device,
      });
      print("[API] completeProfile ← ${response.statusCode} | ${response.data}");
      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        if (data["accessToken"] != null) await TokenHelper.saveToken(data["accessToken"]);
        if (data["refreshToken"] != null) await TokenHelper.saveRefreshToken(data["refreshToken"]);
        data["status"] = "success";
      }
      return data;
    } catch (e) {
      return {"error": Constent.sometingWntWrong};
    }
  }

  /// ================== LOGIN FLOW ==================

  /// [skipSms] = true: Backend validates user existence only; Firebase sends the SMS.
  static Future<Map<String, dynamic>> sendLoginOtp(String mobile, {bool skipSms = false}) async {
    try {
      const url = "auth/login/send-otp";
      final device = await DeviceHelper.getDeviceData();
      final response = await api.post(url, data: {
        "mobileNumber": mobile,
        ...device,
        if (skipSms) "skipSms": true,
      });
      print("[API] sendLoginOtp ← ${response.statusCode} | ${response.data}");
      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        if (data["otpSessionToken"] != null) {
          await TokenHelper.saveOtpSessionToken(data["otpSessionToken"]);
        }
        return {"status": "success", ...data};
      }
      return data;
    } catch (e) {
      return {'error': Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>> verifyLoginOtp({required String mobile, required String otp}) async {
    try {
      const url = "auth/verify-login-otp";
      final device = await DeviceHelper.getDeviceData();
      final otpSessionToken = await TokenHelper.getOtpSessionToken();

      final response = await api.post(url, data: {
        "mobileNumber": mobile, 
        "otpCode": otp, 
        "otpSessionToken": otpSessionToken,
        ...device
      });
      print("[API] verifyLoginOtp ← ${response.statusCode} | ${response.data}");
      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        if (data["accessToken"] != null) await TokenHelper.saveToken(data["accessToken"]);
        if (data["refreshToken"] != null) await TokenHelper.saveRefreshToken(data["refreshToken"]);
        return {"status": "success", "token": data["accessToken"]};
      } else if (response.statusCode == 401 && data["message"].toString().contains("APPROVAL_REQUIRED")) {
        return {
          "status": "untrusted",
          "maskedEmail": data["maskedEmail"],
          "temporaryToken": data["temporaryToken"],
          "message": data["message"],
        };
      }
      return data;
    } catch (e) {
      return {"error": Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>> verifyNewDeviceEmailOtp({required String mobile, required String otp, required String temporaryToken}) async {
    try {
      const url = "auth/verify-new-device";
      final device = await DeviceHelper.getDeviceData();
      final response = await api.post(url, data: {
        "mobileNumber": mobile,
        "otp": otp,
        "temporaryToken": temporaryToken,
        ...device,
      });
      print("[API] verifyNewDeviceEmailOtp ← ${response.statusCode} | ${response.data}");
      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        if (data["accessToken"] != null) await TokenHelper.saveToken(data["accessToken"]);
        if (data["refreshToken"] != null) await TokenHelper.saveRefreshToken(data["refreshToken"]);
        return {"status": "success", "token": data["accessToken"]};
      }
      return data;
    } catch (e) {
      return {"error": Constent.sometingWntWrong};
    }
  }

  /// ================== RESEND ENDPOINTS ==================

  static Future<Map<String, dynamic>> resendOtp({String? mobile, String? email}) async {
    try {
      const String url = "auth/register/resend-otp";
      final device = await DeviceHelper.getDeviceData();
      
      Map<String, dynamic> body = email != null
          ? {
              "email": email,
              "registrationToken": await TokenHelper.getRegistrationToken(),
              "deviceId": device["deviceId"]
            }
          : {
              "mobileNumber": mobile, 
              "deviceId": device["deviceId"]
            };

      final response = await api.post(url, data: body);
      print("[API] resendOtp ← ${response.statusCode} | ${response.data}");
      final data = _parseData(response.data, statusCode: response.statusCode);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Backend guide states resending an OTP invalidates the previous token.
        // We MUST save the new one immediately to keep the session in sync.
        if (data["otpSessionToken"] != null) {
          await TokenHelper.saveOtpSessionToken(data["otpSessionToken"]);
        }
        if (data["registrationToken"] != null) {
          await TokenHelper.saveRegistrationToken(data["registrationToken"]);
        }
        // Step 3 (Email OTP) often returns 'accessToken' as the Step-token
        if (data["accessToken"] != null) {
          await TokenHelper.saveRegistrationToken(data["accessToken"]);
        }
        return {"success": true, ...data};
      }
      return {"success": false, ...data};
    } catch (e) {
      return {"success": false, "message": Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>> resendRegistrationEmailOtp({required String email}) async {
    return await resendOtp(email: email);
  }

  static Future<Map<String, dynamic>> resendLoginOtp({required String mobile}) async {
    try {
      final device = await DeviceHelper.getDeviceData();
      const String url = "auth/login/resend-otp";
      final response = await api.post(url, data: {"mobileNumber": mobile, "deviceId": device["deviceId"]});
      print("[API] resendLoginOtp ← ${response.statusCode} | ${response.data}");
      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        if (data["otpSessionToken"] != null) {
          await TokenHelper.saveOtpSessionToken(data["otpSessionToken"]);
        }
        return {"status": "success", ...data};
      }
      return data;
    } catch (e) {
      return {"error": Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>> resendNewDeviceOtp(String temporaryToken) async {
    try {
      const url = "auth/resend-new-device-otp";
      final response = await api.post(url, data: {"temporaryToken": temporaryToken});
      print("[API] resendNewDeviceOtp ← ${response.statusCode} | ${response.data}");
      final data = _parseData(response.data, statusCode: response.statusCode);
      
      if (response.statusCode == 200) {
        return {"status": "success", ...data};
      }
      return data;
    } catch (e) {
      return {"error": Constent.sometingWntWrong};
    }
  }

  /// ================== USER & SESSION ==================

  static Future<UserDetailModal?> getUserProfile() async {
    try {
      final response = await api.get("auth/me");
      if (response.statusCode == 200) {
        return UserDetailModal.fromJson(_parseData(response.data, statusCode: response.statusCode));
      }
      throw Exception(response.data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> logout() async {
    try {
      String? token = await TokenHelper.getToken();
      String? refreshToken = await TokenHelper.getRefreshToken();

      if (token == null || refreshToken == null) {
        await TokenHelper.clear();
        return true;
      }

      const String url = "auth/logout";
      
      // Use dio directly with queryParameters to ensure JWT chars (+, /, .) are URL-encoded.
      // The backend @RequestParam expects encoded dots/chars in the URL.
      await api.dio.post(
        url,
        queryParameters: {"refreshToken": refreshToken},
        options: Options(
          headers: {"Authorization": "Bearer $token"}
        ),
      );
      
      await TokenHelper.clear();
      return true;
    } catch (e) {
      await TokenHelper.clear();
      return true;
    }
  }

  static Future<bool> deleteAccount() async {
    try {
      String? token = await TokenHelper.getToken();
      if (token == null) return false;

      final response = await api.dio.delete(
        "account",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            if (Platform.isIOS) "X-Platform": "iOS"
          }
        ),
      );

      if (response.statusCode == 200) {
        await TokenHelper.clear();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// ======  Profile Photo (Image Service - 8084) ======

  static Future<Map<String, dynamic>> uploadProfilePicture(File imageFile) async {
    try {
      const String url = 'profile-picture';
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });
      // ✅ imageApi — Image Service (port 8084)
      final response = await imageApi.post(url, data: formData);
      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'status': 'success', ...data};
      }
      return data;
    } catch (e) {
      return {'error': Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>> getProfileHistory() async {
    try {
      const String url = 'profile-picture/history';
      final response = await imageApi.get(url);
      if (response.statusCode == 200) {
        // Directly handle list response
        final data = response.data;
        if (data is List) {
          return {'status': 'success', 'history': data};
        }
        return {'status': 'success', 'history': []};
      }
      return _parseData(response.data, statusCode: response.statusCode);
    } catch (e) {
      return {'error': Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>> setActiveProfilePicture(int id) async {
    try {
      final String url = 'profile-picture/$id/select';
      print("[API] setActiveProfilePicture → URL: $url");
      final response = await imageApi.post(url, data: {});
      print("[API] setActiveProfilePicture ← ${response.statusCode} | ${response.data}");
      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        return {'status': 'success', ...data};
      }
      return data;
    } catch (e) {
      print("[API] setActiveProfilePicture ERROR: $e");
      return {'error': Constent.sometingWntWrong};
    }
  }

  static String getActiveProfileUrl({String size = 'medium'}) {
    // Returns full URL for the active profile picture
    return "${ImageApiClient.imageBaseUrl}profile-picture/$size";
  }

  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith('http')) return path;

    String baseUrl = ImageApiClient.imageBaseUrl;
    
    // Normalizing overlap: If path starts with /api/ and baseUrl ends with /api/
    if (path.startsWith('/api/') && baseUrl.endsWith('/api/')) {
      // Remove '/api/' from the end of baseUrl before joining (baseUrl length is X, '/api/' is 5)
      // Or just join from the domain root.
      String root = baseUrl.substring(0, baseUrl.indexOf('/api/')); // e.g. http://192.168.1.3:8084
      return root + path;
    }

    if (baseUrl.endsWith('/') && path.startsWith('/')) {
      return baseUrl + path.substring(1);
    } else if (!baseUrl.endsWith('/') && !path.startsWith('/')) {
      return "$baseUrl/$path";
    }
    return baseUrl + path;
  }

  // ============================================================
  // STORAGE APIs
  // ============================================================

  /// Storage usage fetch karo (used vs limit)
  static Future<Map<String, dynamic>> getStorageUsage() async {
    try {
      final response = await api.get("storage/usage");
      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        return {"status": "success", ...data};
      }
      return data;
    } catch (e) {
      return {"error": Constent.sometingWntWrong};
    }
  }

  /// Storage breakdown fetch karo (photos vs videos alag alag)
  static Future<Map<String, dynamic>> getStorageDetails() async {
    try {
      final response = await api.get("storage/details");
      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        return {"status": "success", ...data};
      }
      return data;
    } catch (e) {
      return {"error": Constent.sometingWntWrong};
    }
  }

  /// ====== SETTINGS APIs =======

  static Future<Map<String, dynamic>> getSyncPreference() async {
    try {
      final response = await api.get('settings/sync');
      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        return {'status': 'success', ...data};
      }
      return data;
    } catch (e) {
      return {'error': Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>> updateSyncPreference(String mode) async {
    try {
      final response = await api.put('settings/sync', data: {'mode': mode});
      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        return {'status': 'success', ...data};
      }
      return data;
    } catch (e) {
      return {'error': Constent.sometingWntWrong};
    }
  }

  // ================================================================
  // IMAGE VAULT APIs  (Image Service - port 8084)
  // ================================================================
 
  /// Bulk upload — sirf unsync photos upload karta hai, 5-5 ke batches mein
  static Future<Map<String, dynamic>> uploadImagesBulk({
    required List<File> files,
    String type = "personal",
  }) async {
    try {
      const String url = "images/bulk";
      print("=== UPLOAD START: ${files.length} files ===");
 
      final List<MultipartFile> multipartFiles = [];
      for (final file in files) {
        try {
          final filename = file.path.split('/').last;
          final bool exists = await file.exists();
          final int size = exists ? await file.length() : 0;
          print("FILE: $filename | exists=$exists | size=$size bytes");
          if (!exists || size == 0) { print("SKIP: $filename"); continue; }
 
          String contentType = "image/jpeg";
          final ext = filename.split('.').last.toLowerCase();
          if (ext == "png")  contentType = "image/png";
          else if (ext == "webp") contentType = "image/webp";
          else if (ext == "gif")  contentType = "image/gif";
          else if (ext == "heic" || ext == "heif") contentType = "image/heic";
          else if (ext == "bmp" || ext == "dib") contentType = "image/bmp";
          else if (ext == "tif" || ext == "tiff") contentType = "image/tiff";
          else if (ext == "avif") contentType = "image/avif";
 
          multipartFiles.add(await MultipartFile.fromFile(
            file.path, filename: filename, contentType: DioMediaType.parse(contentType),
          ));
          print("ADDED: $filename ($contentType)");
        } catch (fileErr) {
          print("ERROR adding file ${file.path}: $fileErr");
        }
      }
 
      if (multipartFiles.isEmpty) {
        print("=== NO VALID FILES ===");
        return {"status": "error", "uploaded": 0, "failed": files.length, "message": "No valid files to upload"};
      }
 
      print("=== SENDING ${multipartFiles.length} files to $url ===");
      final FormData formData = FormData.fromMap({"files": multipartFiles, "type": type});
 
      // ✅ imageApi — Image Service (port 8084)
      final response = await imageApi.post(url, data: formData);
      final statusCode = response.statusCode ?? 500;
      print("=== RESPONSE STATUS: $statusCode ===");
      print("=== RESPONSE DATA: ${response.data} ===");
 
      if (statusCode == 200 || statusCode == 201) {
        final dynamic rawData = response.data;
        List<dynamic> uploadedList = [];
        if (rawData is List) uploadedList = rawData;
        else if (rawData is Map && rawData.containsKey('data')) uploadedList = rawData['data'] as List? ?? [];
 
        return {
          "status": "success",
          "uploaded": uploadedList.length,
          "failed": files.length - uploadedList.length,
          "responses": uploadedList,
        };
      }
 
      final data = _parseData(response.data, statusCode: statusCode);
      return {"status": "error", "uploaded": 0, "failed": files.length, ...data};
    } catch (e, stack) {
      print("=== UPLOAD EXCEPTION: $e ===");
      print("=== STACK: $stack ===");
      return {"status": "error", "uploaded": 0, "failed": files.length, "message": Constent.sometingWntWrong};
    }
  }

  /// Video Bulk upload
  static Future<Map<String, dynamic>> uploadVideosBulk({
    required List<File> files,
  }) async {
    try {
      const String url = "videos/uploads/bulk";
      print("=== VIDEO UPLOAD START: ${files.length} files ===");

      final List<MultipartFile> multipartFiles = [];
      for (final file in files) {
        try {
          final filename = file.path.split('/').last;
          final bool exists = await file.exists();
          final int size = exists ? await file.length() : 0;
          if (!exists || size == 0) continue;

          String contentType = "video/mp4";
          final ext = filename.split('.').last.toLowerCase();
          if (ext == "mov") contentType = "video/quicktime";
          else if (ext == "m4v") contentType = "video/x-m4v";
          else if (ext == "avi") contentType = "video/x-msvideo";
          else if (ext == "mkv") contentType = "video/x-matroska";
          else if (ext == "webm") contentType = "video/webm";
          else if (ext == "ogv") contentType = "video/ogg";

          multipartFiles.add(await MultipartFile.fromFile(
            file.path,
            filename: filename,
            contentType: DioMediaType.parse(contentType),
          ));
        } catch (e) {
          print("Error adding video file: $e");
        }
      }

      if (multipartFiles.isEmpty) {
        return {"status": "error", "message": "No valid videos found"};
      }

      final FormData formData = FormData.fromMap({"files": multipartFiles});
      final response = await videoApi.post(url, data: formData);
      final statusCode = response.statusCode ?? 500;

      if (statusCode == 200 || statusCode == 201) {
        final List<dynamic> resultList = response.data is List ? response.data : (response.data['data'] as List? ?? []);
        return {
          "status": "success",
          "uploaded": resultList.length,
          "failed": files.length - resultList.length,
          "data": resultList,
        };
      }

      final data = _parseData(response.data, statusCode: statusCode);
      return {"status": "error", ...data};
    } catch (e) {
      print("Video upload exception: $e");
      return {"status": "error", "message": Constent.sometingWntWrong};
    }
  }
}

