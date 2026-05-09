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

  /// Get user profile (current user)
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
    } on DioException catch (_) {
      rethrow;
    }
  }

  /// Get user by ID
  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await dioClient.get(
        ApiRoutes.buildPath('${ApiRoutes.getUserById}/$userId'),
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          // The API now returns user data directly with connection status included
          return data['data'] as Map<String, dynamic>;
        }
        throw Exception(data['message'] ?? 'Failed to get user by ID');
      }

      throw Exception('Invalid response format');
    } on DioException catch (_) {
      rethrow;
    }
  }

  /// Search users by username. No limit; empty query returns [].
  /// Backend: GET /api/v1/users?query=
  Future<List<Map<String, dynamic>>> searchUsers({
    required String query,
  }) async {
    try {
      final response = await dioClient.get(
        ApiRoutes.buildPath(ApiRoutes.searchUsers),
        queryParameters: {
          'query': query.trim(),
        },
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final dataObj = data['data'] as Map<String, dynamic>;
          final users = dataObj['users'] as List<dynamic>? ?? [];
          return users.map((user) => user as Map<String, dynamic>).toList();
        }
        throw Exception(data['message'] ?? 'Failed to search users');
      }

      throw Exception('Invalid response format');
    } on DioException catch (_) {
      rethrow;
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
    } on DioException catch (_) {
      rethrow;
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
    } on DioException catch (_) {
      rethrow;
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
    } on DioException catch (_) {
      rethrow;
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
    } on DioException catch (_) {
      rethrow;
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
    } on DioException catch (_) {
      rethrow;
    }
  }

  /// Delete user account
  Future<void> deleteAccount({
    required String password,
  }) async {
    try {
      final response = await dioClient.delete(
        ApiRoutes.buildPath(ApiRoutes.deleteAccount),
        data: {
          'password': password,
          'confirmation': 'DELETE_MY_ACCOUNT',
        },
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return;
        }
        throw Exception(data['message'] ?? 'Failed to delete account');
      }

      throw Exception('Invalid response format');
    } on DioException {
      // Rethrow so ErrorHandler can extract backend message (e.g. "Invalid password")
      rethrow;
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
