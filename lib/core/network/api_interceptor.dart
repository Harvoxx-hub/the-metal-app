import 'dart:async';
import 'package:dio/dio.dart';
import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/storage/secure_storage_helper.dart';
import 'package:metal/core/storage/shared_prefs_helper.dart';
import 'package:metal/app_config.dart';

/// Interceptor for API requests
/// Handles authentication token attachment, token refresh, and error handling
class ApiInterceptor extends Interceptor {
  final SharedPrefsHelper? _sharedPrefs;
  final SecureStorageHelper? _secureStorage;
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  // Use a separate Dio instance for token refresh to avoid circular dependency
  late final Dio _refreshDio;

  ApiInterceptor({
    SharedPrefsHelper? sharedPrefs,
    SecureStorageHelper? secureStorage,
  })  : _sharedPrefs = sharedPrefs,
        _secureStorage = secureStorage {
    // Create separate Dio instance for token refresh (without interceptors)
    _refreshDio = Dio(BaseOptions(
      baseUrl: AppConfig.config.url,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Attach authentication token if available
    final token = await _getAuthToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Add any other common headers here
    options.headers['Content-Type'] =
        options.headers['Content-Type'] ?? 'application/json';

    print('🌐 Network Call: ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print('❌ Network Error: ${err.message}');
    print('   Path: ${err.requestOptions.path}');
    print('   Status: ${err.response?.statusCode}');

    // Handle 401 Unauthorized - token expired
    if (err.response?.statusCode == 401) {
      // Skip refresh for auth endpoints (login, signup, refresh)
      final path = err.requestOptions.path;
      if (path.contains('/auth/login') ||
          path.contains('/auth/signup') ||
          path.contains('/auth/refresh')) {
        handler.next(err);
        return;
      }

      // Try to refresh token
      try {
        final newToken = await _refreshToken();
        if (newToken != null) {
          // Retry the original request with new token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';

          // Create new request using the original Dio instance
          final response = await _retryRequest(opts);
          handler.resolve(response);
          return;
        }
      } catch (e) {
        print('Token refresh failed: $e');
        // If refresh fails, clear tokens and let error propagate
        await _clearTokens();
      }
    }

    handler.next(err);
  }

  /// Refresh authentication token
  /// Uses a separate Dio instance to avoid circular dependency
  Future<String?> _refreshToken() async {
    if (_isRefreshing) {
      // Wait for ongoing refresh
      return await _waitForRefresh();
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      // Use separate Dio instance for refresh (no interceptors to avoid circular dependency)
      final response = await _refreshDio.post(
        ApiRoutes.buildPath(ApiRoutes.refreshToken),
        data: {
          'refreshToken': refreshToken,
        },
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final responseData = data['data'] as Map<String, dynamic>;
          final newToken = responseData['token'] as String?;
          final newRefreshToken = responseData['refreshToken'] as String?;

          if (newToken != null && newToken.isNotEmpty) {
            await _secureStorage?.setString('auth_token', newToken);
            if (newRefreshToken != null) {
              await _secureStorage?.setString('refresh_token', newRefreshToken);
            }

            // Resolve all pending requests
            _resolvePendingRequests(newToken);
            return newToken;
          }
        }
      }

      return null;
    } catch (e) {
      print('Error refreshing token: $e');
      _rejectPendingRequests(e);
      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Wait for ongoing token refresh
  Future<String?> _waitForRefresh() async {
    final completer = Completer<String?>();
    _pendingRequests.add(_PendingRequest(completer: completer));
    return completer.future;
  }

  /// Resolve all pending requests with new token
  void _resolvePendingRequests(String token) {
    for (final request in _pendingRequests) {
      request.completer.complete(token);
    }
    _pendingRequests.clear();
  }

  /// Reject all pending requests
  void _rejectPendingRequests(dynamic error) {
    for (final request in _pendingRequests) {
      request.completer.completeError(error);
    }
    _pendingRequests.clear();
  }

  /// Retry request with new token
  /// Uses the original Dio instance from the error
  Future<Response> _retryRequest(RequestOptions options) async {
    // Create a new Dio instance with base configuration
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.config.url,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ));

    return await dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: options.headers,
      ),
    );
  }

  /// Get refresh token from storage
  Future<String?> _getRefreshToken() async {
    if (_secureStorage != null) {
      return await _secureStorage!.getString('refresh_token');
    }
    return null;
  }

  /// Clear all authentication tokens
  Future<void> _clearTokens() async {
    await _secureStorage?.delete('auth_token');
    await _secureStorage?.delete('refresh_token');
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        '✅ Network Response: ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  /// Get authentication token from secure storage
  Future<String?> _getAuthToken() async {
    // Try secure storage first (for tokens)
    if (_secureStorage != null) {
      final token = await _secureStorage!.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        return token;
      }
    }

    // Fallback to shared prefs if needed
    if (_sharedPrefs != null) {
      return _sharedPrefs!.getString('auth_token');
    }

    return null;
  }
}

/// Helper class for pending requests during token refresh
class _PendingRequest {
  final Completer<String?> completer;

  _PendingRequest({required this.completer});
}
