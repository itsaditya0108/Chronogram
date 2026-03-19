import 'package:chronogram/app_helper/constent.dart';
import 'package:chronogram/app_helper/token_saver_helper/token_saver_helper.dart';
import 'package:chronogram/main.dart';
import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_screen.dart';
import 'package:chronogram/service/connectivity_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio dio;

  bool isRedirecting = false;

  ApiClient._internal() {
    BaseOptions options = BaseOptions(
      baseUrl: "https://glayds-unpainful-torri.ngrok-free.dev/api/", // 🔁 Reverted to ngrok for real device testing
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      validateStatus: (status) {
        return true; 
      },
    );

    dio = Dio(options);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!ConnectivityService().isOnline) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                message: "No internet connection detected.",
              ),
            );
          }

          // 🔑 TOKEN LOGIC: Try primary token first, then fallback to registration token.
          String? token = await TokenHelper.getToken();
          if (token == null || token.isEmpty) {
            token = await TokenHelper.getRegistrationToken();
          }

          if (token?.isNotEmpty ?? false) {
            options.headers["Authorization"] = "Bearer $token";
          }

          print("REQUEST[${options.method}] => PATH: ${options.path}");
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          print("RESPONSE[${response.statusCode}] => DATA: ${response.data}");

          if (response.statusCode == 401) {
            bool isNewDevice = false;
            final data = response.data;
            if (data is Map) {
              String msg = (data['message'] ?? data['error'] ?? "").toString();
              if (msg.contains("APPROVAL_REQUIRED") || msg.contains("verify") || msg.contains("untrusted")) {
                isNewDevice = true;
              }
            }

            if (!isNewDevice && !isRedirecting) {
              // 🔄 TOKEN REFRESH LOGIC
              String? refreshToken = await TokenHelper.getRefreshToken();
              if (refreshToken != null) {
                try {
                  // Assuming standard refresh endpoint based on guide's hint
                  final refreshRes = await dio.post("auth/refresh-token", queryParameters: {"refreshToken": refreshToken});
                  if (refreshRes.statusCode == 200) {
                    String newToken = refreshRes.data["accessToken"];
                    await TokenHelper.saveToken(newToken);
                    
                    // Retry original request
                    final opts = response.requestOptions;
                    opts.headers["Authorization"] = "Bearer $newToken";
                    
                    final clonedRes = await dio.fetch(opts);
                    return handler.resolve(clonedRes);
                  }
                } catch (e) {
                  print("Token refresh failed: $e");
                }
              }

              isRedirecting = true;
              await TokenHelper.clear();
              navigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SignUpScreen()),
                (route) => false,
              );
              return handler.next(response);
            }
          }

          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          print("ERROR[${e.type}] => MESSAGE: ${e.message}");
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
      return Response(
        requestOptions: e.requestOptions,
        data: _handleError(e),
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  /// ================== POST ==================
  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      return Response(
        requestOptions: e.requestOptions,
        data: _handleError(e),
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  /// ================== PUT ==================
  Future<Response> put(String path, {dynamic data}) async {
    try {
      final response = await dio.put(path, data: data);
      return response;
    } on DioException catch (e) {
      return Response(
        requestOptions: e.requestOptions,
        data: _handleError(e),
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  /// ================== DELETE ==================
  Future<Response> delete(String path, {dynamic data}) async {
    try {
      final response = await dio.delete(path, data: data);
      return response;
    } on DioException catch (e) {
      return Response(
        requestOptions: e.requestOptions,
        data: _handleError(e),
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  /// ================== ERROR HANDLE ==================
  dynamic _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return {"message": Constent.sometingWntWrong, "isNetworkError": true};
    } else if (error.type == DioExceptionType.connectionError) {
      return {"message": Constent.sometingWntWrong, "isNetworkError": true};
    } else if (error.response != null && error.response?.data != null) {
      return error.response?.data;
    } else {
      return {"message": Constent.sometingWntWrong, "isNetworkError": true};
    }
  }
}
