import 'dart:convert';

import 'package:dio/dio.dart';
 
import 'package:metal/core/network/api_interceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// HTTP client with interceptors for authentication, logging, and error handling
/// This is the core network client used by all data sources
class DioClient {
  final Dio _dio;
  final ApiInterceptor _interceptor;

  DioClient({
    required ApiInterceptor interceptor,
  })  : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        )),
        _interceptor = interceptor {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.addAll([
      _interceptor,
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: false,
        responseHeader: false,
        error: true,
        compact: false,
        maxWidth: 90,
      ),
    ]);
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.post(
      path,
      data: data is FormData ? data : (data != null ? jsonEncode(data) : null),
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.patch(
      path,
      data: data is FormData ? data : (data != null ? jsonEncode(data) : null),
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.put(
      path,
      data: data is FormData ? data : (data != null ? jsonEncode(data) : null),
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.delete(
      path,
      data: data is FormData ? data : (data != null ? jsonEncode(data) : null),
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}

