import 'package:chronogram/app_helper/token_saver_helper/token_saver_helper.dart';
import 'package:chronogram/main.dart';
import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio dio;

  bool isRedirecting = false;

  ApiClient._internal() {
    BaseOptions options = BaseOptions(
      baseUrl:
          "https://glayds-unpainful-torri.ngrok-free.dev/api/", // 🔁 change base url
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      validateStatus: (status) {
        return true; // 🔥 accept all status codes without throwing exception
      },
    );

    dio = Dio(options);

    // 🔐 Add interceptors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add token if needed
          String? token =
              await TokenHelper.getToken(); // get token from storage

          if (token?.isNotEmpty ?? false) {
            options.headers["Authorization"] = "Bearer $token";
          }

          print("REQUEST[${options.method}] => PATH: ${options.path}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print("RESPONSE[${response.statusCode}] => DATA: ${response.data}");

          if (response.statusCode == 401) {
            bool isNewDevice = false;
            final data = response.data;
            if (data is Map) {
              String msg = data['message']?.toString() ?? "";
              if (msg.contains("APPROVAL_REQUIRED") || msg.contains("verify") || msg.contains("untrusted")) {
                isNewDevice = true;
              }
              String error = data['error']?.toString() ?? "";
              if (error.contains("APPROVAL_REQUIRED") || error.contains("verify") || error.contains("untrusted")) {
                 isNewDevice = true;
              }
            }

            if (!isNewDevice && !isRedirecting) {
              isRedirecting = true;
              TokenHelper.clear();
              // 🔴 Navigate to login & remove all routes
              navigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SignUpScreen()),
                (route) => false,
              );
            }
          }

          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          return handler.next(e);
        },
      ),
    );
  }

  /// ================== GET ==================
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }

  /// ================== POST ==================
  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }

  /// ================== PUT ==================
  Future<Response> put(String path, {dynamic data}) async {
    try {
      final response = await dio.put(path, data: data);
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }

  /// ================== DELETE ==================
  Future<Response> delete(String path, {dynamic data}) async {
    try {
      final response = await dio.delete(path, data: data);
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }

  /// ================== ERROR HANDLE ==================
  dynamic _handleError(DioException error) {
    if (error.response != null && error.response?.data != null) {
      return error.response?.data;
    } else {
      return "Network error. Please try again.";
    }
  }
}
