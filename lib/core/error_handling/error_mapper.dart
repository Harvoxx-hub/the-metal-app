import 'package:dio/dio.dart';
import 'package:metal/core/model/responces.dart';

/// Maps API errors to domain-friendly error messages
class ErrorMapper {
  static String mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        // Try to extract error message from response first
        final errorMessage = _extractErrorFromResponse(error.response?.data);
        if (errorMessage != null) {
          return errorMessage;
        }
        return _mapStatusCode(error.response?.statusCode);
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Extract user-friendly error message from API response
  static String? _extractErrorFromResponse(dynamic responseData) {
    if (responseData == null) return null;

    if (responseData is Map) {
      // Check for 'error' field first (e.g., "INVALID_LOGIN_CREDENTIALS")
      if (responseData.containsKey('error')) {
        final error = responseData['error'];
        if (error is String) {
          return _mapErrorCodeToMessage(error);
        }
      }
      // Check for 'message' field as fallback
      if (responseData.containsKey('message')) {
        final message = responseData['message'];
        if (message is String) {
          return message;
        }
      }
    }
    return null;
  }

  /// Map error codes to user-friendly messages
  static String _mapErrorCodeToMessage(String errorCode) {
    switch (errorCode) {
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Invalid email or password. Please try again.';
      case 'USER_NOT_FOUND':
        return 'User not found.';
      case 'EMAIL_ALREADY_EXISTS':
        return 'This email is already registered.';
      case 'INVALID_TOKEN':
        return 'Invalid or expired token. Please login again.';
      case 'UNAUTHORIZED':
        return 'Unauthorized. Please login again.';
      case 'FORBIDDEN':
        return 'Access forbidden.';
      case 'VALIDATION_ERROR':
        return 'Please check your input and try again.';
      default:
        // Convert snake_case or UPPER_SNAKE_CASE to readable format
        return errorCode
            .replaceAll('_', ' ')
            .toLowerCase()
            .split(' ')
            .map((word) =>
                word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  static String _mapStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access forbidden.';
      case 404:
        return 'Resource not found.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  /// Extract error message from API response
  static String extractErrorMessage(dynamic error) {
    if (error is Responses) {
      return error.message ?? 'An error occurred';
    }
    if (error is DioException) {
      return mapDioException(error);
    }
    // Handle Exception objects that might contain error messages
    if (error is Exception) {
      final errorString = error.toString();
      // Check if it's a wrapped DioException message
      if (errorString.contains('DioException') ||
          errorString.contains('Login failed:')) {
        // Try to extract meaningful part
        if (errorString.contains('INVALID_LOGIN_CREDENTIALS')) {
          return 'Invalid email or password. Please try again.';
        }
      }
      // Return a cleaner version of the exception message
      return errorString
          .replaceAll('Exception: ', '')
          .replaceAll('Login failed: ', '');
    }
    return error.toString();
  }
}
