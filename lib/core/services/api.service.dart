import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metal/core/error/error.handle.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/auth.pref.service.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiService {
  final Dio _dio;
  final String baseUrl = 'https://metal-server.vercel.app/api/v1';

  ApiService()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        )) {
    _dio.interceptors.addAll([
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: false,
        responseHeader: false,
        error: true,
        compact: false,
        maxWidth: 90,
      ),
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach the token to each request
          // options.headers['Authorization'] =
          //     'Bearer ${await AuthManager.getAccessToken()}';
          print('Network Call: ${options.path}');
          handler.next(options);
        },
        onError: (DioError e, handler) async {
          handler.next(e);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
      ),
    ]);
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await AuthManager.getRefreshToken();
      final response = await _dio.post(
        '$baseUrl/auth/refresh-token', // Your refresh token endpoint
        data: {'refreshtoken': refreshToken},
      );

      if (response.statusCode == 200) {
        print(response.data);
        final newAccessToken = response.data['access_token'];
        await AuthManager.saveRefreshToken(response.data['refresh_token']);
        print('Token refreshed successfully');
        return newAccessToken;
      }
    } catch (e) {
      print(
        'Refresh token failed',
      );
    }
    return null;
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _dio.get('$baseUrl/$endpoint');
      return _handleResponse(response);
    } catch (error, s) {
      print('GET request error');
      throw ErrorHandler.handle(error).failure;
    }
  }

  Future<dynamic> patch(String endpoint,
      {Map<String, dynamic>? body, FormData? formData}) async {
    try {
      final response = await _dio.patch(
        '$baseUrl/$endpoint',
        data: formData ?? (body != null ? jsonEncode(body) : null),
      );
      return _handleResponse(response);
    } catch (error, s) {
      print('PATCH request error');
      throw ErrorHandler.handle(error).failure;
    }
  }

  Future<dynamic> post(String endpoint,
      {Map<String, dynamic>? body, FormData? formData}) async {
    try {
      final response = await _dio.post(
        '$baseUrl/$endpoint',
        data: formData ?? jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (error, s) {
      print('POST request error');
      throw ErrorHandler.handle(error).failure;
    }
  }

  Future<Responses> _handleResponse(Response response) async {
    final body = response.data;
    final data = Responses.fromJson(body);

    if (data.success!) {
      return data;
    } else {
      print("Network Error: ${data.message}");
      Fluttertoast.showToast(msg: data.message.toString());
      throw data;
    }
  }
}
