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
    } on DioException catch (e) {
      // Re-throw with more context
      throw Exception('Login failed: ${e.message}');
    }
  }

  /// Signup with user details
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String phoneNumber,
    String? referralCode,
    String? fcmToken,
  }) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.buildPath(ApiRoutes.signup),
        data: {
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
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
    } on DioException catch (e) {
      throw Exception('Signup failed: ${e.message}');
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
    } on DioException catch (e) {
      throw Exception('Token refresh failed: ${e.message}');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await dioClient.post(ApiRoutes.buildPath(ApiRoutes.logout));
    } on DioException catch (e) {
      throw Exception('Logout failed: ${e.message}');
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
    } on DioException catch (e) {
      throw Exception('Failed to send verification code: ${e.message}');
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
    } on DioException catch (e) {
      throw Exception('Verification failed: ${e.message}');
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
    } on DioException catch (e) {
      throw Exception('Password reset failed: ${e.message}');
    }
  }
}
