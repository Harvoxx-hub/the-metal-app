import 'dart:async';
import 'package:dio/dio.dart';
import 'package:metal/core/constants/app_constants.dart';
import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/storage/secure_storage_helper.dart';

/// Service for handling token refresh operations
/// Separated from interceptor for better testability and reusability
class TokenRefreshService {
  final SecureStorageHelper _secureStorage;
  final Dio _refreshClient;
  
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  TokenRefreshService({
    required SecureStorageHelper secureStorage,
  })  : _secureStorage = secureStorage,
        _refreshClient = Dio(BaseOptions(
          baseUrl: AppConstants.apiUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ));

  /// Refresh authentication token
  /// Returns new token if refresh succeeds, null otherwise
  Future<String?> refresh() async {
    if (_isRefreshing) {
      // Wait for ongoing refresh
      return await _waitForRefresh();
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorage.getString('refresh_token');
      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      // Use separate Dio instance for refresh (no interceptors to avoid circular dependency)
      final response = await _refreshClient.post(
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
            await _secureStorage.setString('auth_token', newToken);
            if (newRefreshToken != null) {
              await _secureStorage.setString('refresh_token', newRefreshToken);
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

  /// Clear all authentication tokens
  Future<void> clearTokens() async {
    await _secureStorage.delete('auth_token');
    await _secureStorage.delete('refresh_token');
  }
}

/// Helper class for pending requests during token refresh
class _PendingRequest {
  final Completer<String?> completer;

  _PendingRequest({required this.completer});
}

