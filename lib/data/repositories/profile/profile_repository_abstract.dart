import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/repositories/base_repository.dart';
import 'package:metal/domain/entities/user_dto.dart';

/// Abstract repository interface for profile operations
/// This defines the contract that all profile repositories must implement
abstract class ProfileRepositoryAbstract extends BaseRepository {
  /// Get user profile
  /// Used to fetch and maintain user state throughout the application
  Future<BaseState<UserDto>> getUserProfile();

  /// Update user profile
  Future<BaseState<UserDto>> updateUserProfile({
    required Map<String, dynamic> profileData,
  });

  /// Complete profile setup
  Future<BaseState<UserDto>> completeProfile({
    required Map<String, dynamic> finalData,
  });
}
