import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:metal/core/error/error.handle.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/auth.manager.dart';

class ApiService {
  final Dio _dio = Dio(); // Create an instance of Dio
  final String baseUrl = 'https://metal-server.vercel.app/api/v1';
  final AuthManager _authManager = AuthManager();

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add the access token to the request header
          options.headers['Authorization'] =
              'Bearer ${await _authManager.getAccessToken()}';
          return handler.next(options);
        },
        onError: (DioError e, handler) async {
          if (e.response?.statusCode == 401) {
            // If a 401 response is received, refresh the access token
            String newAccessToken = await _authManager.refreshToken();

            // Update the request header with the new access token
            e.requestOptions.headers['Authorization'] =
                'Bearer $newAccessToken';

            // Repeat the request with the updated header
            return handler.resolve(await _dio.fetch(e.requestOptions));
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _dio.get(
        '$baseUrl/$endpoint',
      );
      return _handleResponse(response);
    } catch (error) {
      print('DioError: $error');
      throw error;
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
    } catch (error) {
      print('DioError: $error');
      throw error;
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
    } catch (error) {
      print('DioError: $error');
      throw error;
    }
  }

  Future<Responses> _handleResponse(Response response) async {
    final body = response.data;
    final data = Responses.fromJson(body);
    if (data.success) {
      print(data.data);
      return data;
    } else {
      ErrorHandler.handleError(_createAppError(response.statusCode!, body));
      throw _createAppError(response.statusCode!, body);
    }
  }

  AppError _createAppError(int statusCode, dynamic body) {
    return AppError(
      code: body['code'] ?? 'unknown-error',
      message: body['message'] ?? 'An error occurred.',
      errorData: body['data']
    );
  }
}
