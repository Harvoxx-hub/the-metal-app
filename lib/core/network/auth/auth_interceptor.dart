import 'package:dio/dio.dart';
import 'package:metal/core/constants/app_constants.dart';
import 'package:metal/core/network/auth/token_refresh_service.dart';
import 'package:metal/core/storage/secure_storage_helper.dart';
import 'package:metal/core/storage/shared_prefs_helper.dart';

/// Interceptor for handling authentication
/// - Attaches auth tokens to requests
/// - Handles token refresh on 401 errors
class AuthInterceptor extends Interceptor {
  final SecureStorageHelper? _secureStorage;
  final SharedPrefsHelper? _sharedPrefs;
  final TokenRefreshService _tokenRefreshService;
  late final Dio
      _retryClient; // Clean Dio instance for retrying requests (without interceptors)

  AuthInterceptor({
    SecureStorageHelper? secureStorage,
    SharedPrefsHelper? sharedPrefs,
    TokenRefreshService? tokenRefreshService,
  })  : _secureStorage = secureStorage,
        _sharedPrefs = sharedPrefs,
        _tokenRefreshService = tokenRefreshService ??
            TokenRefreshService(
              secureStorage: secureStorage ?? SecureStorageHelper(),
            ) {
    // Create a clean Dio instance for retries (without interceptors to avoid infinite loops)
    _retryClient = Dio(BaseOptions(
      baseUrl: AppConstants.apiUrl,
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
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Attach authentication token if available
    final token = await _getAuthToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Ensure Content-Type is set
    options.headers['Content-Type'] =
        options.headers['Content-Type'] ?? 'application/json';

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - token expired
    if (err.response?.statusCode == 401) {
      // Skip refresh for auth endpoints (login, signup, refresh)
      final path = err.requestOptions.path;
      if (_isAuthEndpoint(path)) {
        handler.next(err);
        return;
      }

      // Try to refresh token
      try {
        final newToken = await _tokenRefreshService.refresh();
        if (newToken != null) {
          // Retry the original request with new token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';

          try {
            final response = await _retryClient.request(
              opts.path,
              data: opts.data,
              queryParameters: opts.queryParameters,
              options: Options(
                method: opts.method,
                headers: opts.headers,
              ),
            );
            handler.resolve(response);
            return;
          } catch (e) {
            // Retry failed, proceed with error
          }
        } else {
          // Refresh failed, clear tokens
          await _tokenRefreshService.clearTokens();
        }
      } catch (e) {
        print('Token refresh failed: $e');
        await _tokenRefreshService.clearTokens();
      }
    }

    handler.next(err);
  }

  /// Check if path is an auth endpoint (should not trigger token refresh)
  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/signup') ||
        path.contains('/auth/refresh');
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
