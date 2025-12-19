import 'dart:io';
import 'package:dio/dio.dart';
import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/network/dio_client.dart';
import 'package:metal/data/datasources/base_data_source.dart';
import 'package:metal/data/models/blocked_user_model.dart';
import 'package:metal/data/datasources/remote/media_remote_data_source.dart';

/// Remote data source for profile operations
/// Handles all API calls related to user profile
class ProfileRemoteDataSource extends BaseRemoteDataSource {
  final DioClient dioClient;
  final MediaRemoteDataSource? mediaDataSource;

  ProfileRemoteDataSource(
    this.dioClient, {
    this.mediaDataSource,
  });

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

  /// Get blocked users with pagination
  Future<BlockedUsersResponseModel> getBlockedUsers({
    required int page,
    required int limit,
  }) async {
    try {
      final response = await dioClient.get(
        ApiRoutes.buildPath(ApiRoutes.blockedUsers),
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return BlockedUsersResponseModel.fromJson(
            data['data'] as Map<String, dynamic>,
          );
        }
        throw Exception(data['message'] ?? 'Failed to get blocked users');
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Get blocked users failed: ${e.message}');
    }
  }

  /// Block a user
  Future<Map<String, dynamic>> blockUser({
    required String userId,
    String? reason,
  }) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.buildPath('${ApiRoutes.blockUser}/$userId'),
        data: {
          if (reason != null) 'reason': reason,
        },
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>? ?? {};
        }
        throw Exception(data['message'] ?? 'Failed to block user');
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Block user failed: ${e.message}');
    }
  }

  /// Unblock a user
  Future<Map<String, dynamic>> unblockUser({
    required String userId,
  }) async {
    try {
      final response = await dioClient.delete(
        ApiRoutes.buildPath('${ApiRoutes.unblockUser}/$userId'),
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>? ?? {};
        }
        throw Exception(data['message'] ?? 'Failed to unblock user');
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Unblock user failed: ${e.message}');
    }
  }

  /// Delete user account
  Future<void> deleteAccount({
    required String password,
  }) async {
    try {
      final response = await dioClient.delete(
        ApiRoutes.buildPath(ApiRoutes.deleteAccount),
        data: {'password': password},
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return;
        }
        throw Exception(data['message'] ?? 'Failed to delete account');
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Delete account failed: ${e.message}');
    }
  }

  /// Upload profile photo and update profile
  /// Complete flow: Upload photo to storage -> Update profile with photo URL
  /// Returns updated user profile data
  Future<Map<String, dynamic>> uploadProfilePhoto({
    required File photoFile,
    required String contentType,
  }) async {
    if (mediaDataSource == null) {
      throw Exception(
        'MediaRemoteDataSource is required for photo upload. '
        'Pass it in the constructor.',
      );
    }

    try {
      // Step 1: Upload photo to storage and get public URL
      final publicUrl = await mediaDataSource!.uploadMedia(
        file: photoFile,
        mediaType: MediaType.image,
        purpose: MediaPurpose.profile,
        contentType: contentType,
      );

      // Step 2: Update profile with new photo URL
      return await updateUserProfile(
        profileData: {'profilePhoto': publicUrl},
      );
    } catch (e) {
      throw Exception('Upload profile photo failed: $e');
    }
  }
}

