import 'package:dio/dio.dart';
import 'package:metal/core/constants/app_constants.dart';
import 'package:metal/core/network/auth/auth_interceptor.dart';
import 'package:metal/core/storage/secure_storage_helper.dart';
import 'package:metal/core/storage/shared_prefs_helper.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// HTTP client with interceptors for authentication, logging, and error handling
/// This is the core network client used by all data sources
class DioClient {
  final Dio _dio;
  final AuthInterceptor _authInterceptor;

  DioClient({
    SecureStorageHelper? secureStorage,
    SharedPrefsHelper? sharedPrefs,
  })  : _dio = Dio(BaseOptions(
          baseUrl: AppConstants.apiUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        )),
        _authInterceptor = AuthInterceptor(
          secureStorage: secureStorage,
          sharedPrefs: sharedPrefs,
        ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.addAll([
      _authInterceptor,
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
  /// Dio automatically handles JSON encoding for Map/List types
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.post(
      path,
      data: data, // Let Dio handle encoding for Map/List/String/FormData
      queryParameters: queryParameters,
      options: options ??
          Options(
            contentType:
                data is FormData ? 'multipart/form-data' : 'application/json',
          ),
      cancelToken: cancelToken,
    );
  }

  /// PATCH request
  /// Dio automatically handles JSON encoding for Map/List types
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.patch(
      path,
      data: data, // Let Dio handle encoding for Map/List/String/FormData
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PUT request
  /// Dio automatically handles JSON encoding for Map/List types
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.put(
      path,
      data: data, // Let Dio handle encoding for Map/List/String/FormData
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// DELETE request
  /// Dio automatically handles JSON encoding for Map/List types
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.delete(
      path,
      data: data, // Let Dio handle encoding for Map/List/String/FormData
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
