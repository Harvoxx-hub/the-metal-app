import 'dart:io';
import 'package:metal/core/error_handling/error_handler.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/datasources/remote/profile_remote_data_source.dart';
import 'package:metal/data/models/user_model.dart';
import 'package:metal/data/repositories/profile/profile_repository_abstract.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/domain/entities/blocked_user_dto.dart';

/// Profile repository implementation
/// Coordinates between remote data source and domain layer
/// Handles all user profile operations
class ProfileRepository implements ProfileRepositoryAbstract {
  final ProfileRemoteDataSource profileRemoteDataSource;

  ProfileRepository({
    required this.profileRemoteDataSource,
  });

  @override
  Future<BaseState<UserDto>> getUserProfile() async {
    try {
      final response = await profileRemoteDataSource.getUserProfile();
      final user = UserModel.fromJson(response).toDomain();
      return BaseState.success(user);
    } catch (e) {
      return ErrorHandler.handleError<UserDto>(e);
    }
  }

  @override
  Future<BaseState<UserDto>> getUserById(String userId) async {
    try {
      final response = await profileRemoteDataSource.getUserById(userId);
      final user = UserModel.fromJson(response).toDomain();
      return BaseState.success(user);
    } catch (e) {
      return ErrorHandler.handleError<UserDto>(e);
    }
  }

  @override
  Future<BaseState<List<UserDto>>> searchUsers({required String query}) async {
    try {
      final response = await profileRemoteDataSource.searchUsers(
        query: query,
      );
      final users = response
          .map((json) => UserModel.fromJson(json).toDomain())
          .toList();
      return BaseState.success(users);
    } catch (e) {
      return ErrorHandler.handleError<List<UserDto>>(e);
    }
  }

  @override
  Future<BaseState<UserDto>> updateUserProfile({
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final response = await profileRemoteDataSource.updateUserProfile(
        profileData: profileData,
      );
      final user = UserModel.fromJson(response).toDomain();
      return BaseState.success(user);
    } catch (e) {
      return ErrorHandler.handleError<UserDto>(e);
    }
  }

  @override
  Future<BaseState<UserDto>> completeProfile({
    required Map<String, dynamic> finalData,
  }) async {
    try {
      final response = await profileRemoteDataSource.completeProfile(
        finalData: finalData,
      );
      final user = UserModel.fromJson(response).toDomain();
      return BaseState.success(user);
    } catch (e) {
      return ErrorHandler.handleError<UserDto>(e);
    }
  }

  @override
  Future<BaseState<BlockedUsersResponseDto>> getBlockedUsers({
    required int page,
    required int limit,
  }) async {
    try {
      final response = await profileRemoteDataSource.getBlockedUsers(
        page: page,
        limit: limit,
      );
      final dto = response.toDomain();
      return BaseState.success(dto);
    } catch (e) {
      return ErrorHandler.handleError<BlockedUsersResponseDto>(e);
    }
  }

  @override
  Future<BaseState<void>> blockUser({
    required String userId,
    String? reason,
  }) async {
    try {
      await profileRemoteDataSource.blockUser(
        userId: userId,
        reason: reason,
      );
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  @override
  Future<BaseState<void>> unblockUser({
    required String userId,
  }) async {
    try {
      await profileRemoteDataSource.unblockUser(userId: userId);
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  @override
  Future<BaseState<void>> deleteAccount({
    required String password,
  }) async {
    try {
      await profileRemoteDataSource.deleteAccount(password: password);
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  @override
  Future<BaseState<UserDto>> uploadProfilePhoto({
    required File photoFile,
    required String contentType,
  }) async {
    try {
      final response = await profileRemoteDataSource.uploadProfilePhoto(
        photoFile: photoFile,
        contentType: contentType,
      );
      final user = UserModel.fromJson(response).toDomain();
      return BaseState.success(user);
    } catch (e) {
      return ErrorHandler.handleError<UserDto>(e);
    }
  }
}
