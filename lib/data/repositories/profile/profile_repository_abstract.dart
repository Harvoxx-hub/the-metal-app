import 'dart:io';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/repositories/base_repository.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/domain/entities/blocked_user_dto.dart';

/// Abstract repository interface for profile operations
/// This defines the contract that all profile repositories must implement
abstract class ProfileRepositoryAbstract extends BaseRepository {
  /// Get user profile
  /// Used to fetch and maintain user state throughout the application
  Future<BaseState<UserDto>> getUserProfile();

  /// Get user by ID
  /// Used to fetch any user's public profile information
  Future<BaseState<UserDto>> getUserById(String userId);

  /// Search users by username. Returns a list of matching users.
  Future<BaseState<List<UserDto>>> searchUsers({required String query});

  /// Update user profile
  Future<BaseState<UserDto>> updateUserProfile({
    required Map<String, dynamic> profileData,
  });

  /// Complete profile setup
  Future<BaseState<UserDto>> completeProfile({
    required Map<String, dynamic> finalData,
  });

  /// Get blocked users with pagination
  Future<BaseState<BlockedUsersResponseDto>> getBlockedUsers({
    required int page,
    required int limit,
  });

  /// Block a user
  Future<BaseState<void>> blockUser({
    required String userId,
    String? reason,
  });

  /// Unblock a user
  Future<BaseState<void>> unblockUser({
    required String userId,
  });

  /// Delete user account
  Future<BaseState<void>> deleteAccount({
    required String password,
  });

  /// Upload profile photo
  /// Complete flow: Upload photo to storage -> Update profile with photo URL
  Future<BaseState<UserDto>> uploadProfilePhoto({
    required File photoFile,
    required String contentType,
  });
}
