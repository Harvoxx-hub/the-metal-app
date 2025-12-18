import 'package:dio/dio.dart';
import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/network/dio_client.dart';
import 'package:metal/data/datasources/base_data_source.dart';

/// Remote data source for profile operations
/// Handles all API calls related to user profile
class ProfileRemoteDataSource extends BaseRemoteDataSource {
  final DioClient dioClient;

  ProfileRemoteDataSource(this.dioClient);

  /// Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await dioClient.get(
        ApiRoutes.buildPath(ApiRoutes.getUserProfile),
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
        throw Exception(data['message'] ?? 'Failed to get user profile');
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Get user profile failed: ${e.message}');
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final response = await dioClient.put(
        ApiRoutes.buildPath(ApiRoutes.updateUserProfile),
        data: profileData,
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
        throw Exception(data['message'] ?? 'Failed to update profile');
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Update profile failed: ${e.message}');
    }
  }

  /// Complete profile setup
  Future<Map<String, dynamic>> completeProfile({
    required Map<String, dynamic> finalData,
  }) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.buildPath(ApiRoutes.completeProfile),
        data: finalData,
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
        throw Exception(data['message'] ?? 'Failed to complete profile');
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Complete profile failed: ${e.message}');
    }
  }
}

