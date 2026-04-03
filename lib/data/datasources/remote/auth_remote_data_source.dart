import 'package:dio/dio.dart';
import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/network/dio_client.dart';
import 'package:metal/data/datasources/base_data_source.dart';

/// Remote data source for authentication
/// Handles all API calls related to authentication
class AuthRemoteDataSource extends BaseRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSource(this.dioClient);

  /// Login with email and password
  /// Returns the API response as Map
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.buildPath(ApiRoutes.login),
        data: {
          'email': email,
          'password': password,
        },
      );

      // Handle API response format
      // Assuming response.data contains { success, data, message }
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
        throw Exception(data['message'] ?? 'Login failed');
      }

      throw Exception('Invalid response format');
    } on DioException {
      // Re-throw DioException to preserve response data for error handling
      // ErrorHandler will extract the proper error message from the response
      rethrow;
    }
  }

  /// Signup with user details
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String phoneNationalNumber,
    required String phoneCountryIso2,
    String? referralCode,
    String? fcmToken,
  }) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.buildPath(ApiRoutes.signup),
        data: {
          'email': email,
          'password': password,
          'phoneNationalNumber': phoneNationalNumber,
          'phoneCountryIso2': phoneCountryIso2,
          if (referralCode != null) 'referralCode': referralCode,
          if (fcmToken != null) 'fcmToken': fcmToken,
        },
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
        throw Exception(data['message'] ?? 'Signup failed');
      }

      throw Exception('Invalid response format');
    } on DioException {
      // Re-throw DioException to preserve response data for error handling
      // ErrorHandler will extract the proper error message from the response
      rethrow;
    }
  }

  /// Refresh authentication token
  /// Used when token expires (401 error)
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.buildPath(ApiRoutes.refreshToken),
        data: {
          'refreshToken': refreshToken,
        },
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
        throw Exception(data['message'] ?? 'Token refresh failed');
      }

      throw Exception('Invalid response format');
    } on DioException {
      // Re-throw DioException to preserve response data for error handling
      // ErrorHandler will extract the proper error message from the response
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await dioClient.post(ApiRoutes.buildPath(ApiRoutes.logout));
    } on DioException {
      // Re-throw DioException to preserve response data for error handling
      // ErrorHandler will extract the proper error message from the response
      rethrow;
    }
  }

  /// Send verification code to email
  Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.buildPath(ApiRoutes.sendVerificationCode),
        data: {'email': email},
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>? ?? {'success': true};
        }
        throw Exception(data['message'] ?? 'Failed to send verification code');
      }

      throw Exception('Invalid response format');
    } on DioException {
      // Re-throw DioException to preserve response data for error handling
      // ErrorHandler will extract the proper error message from the response
      rethrow;
    }
  }

  /// Verify OTP code
  Future<Map<String, dynamic>> verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.buildPath(ApiRoutes.verifyCode),
        data: {
          'email': email,
          'code': code,
        },
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>? ?? {'success': true};
        }
        throw Exception(data['message'] ?? 'Invalid verification code');
      }

      throw Exception('Invalid response format');
    } on DioException {
      // Re-throw DioException to preserve response data for error handling
      // ErrorHandler will extract the proper error message from the response
      rethrow;
    }
  }

  /// Reset password with OTP verification
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.buildPath(ApiRoutes.resetPassword),
        data: {
          'email': email,
          'code': code,
          'newPassword': newPassword,
        },
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>? ?? {'success': true};
        }
        throw Exception(data['message'] ?? 'Password reset failed');
      }

      throw Exception('Invalid response format');
    } on DioException {
      // Re-throw DioException to preserve response data for error handling
      // ErrorHandler will extract the proper error message from the response
      rethrow;
    }
  }
}
