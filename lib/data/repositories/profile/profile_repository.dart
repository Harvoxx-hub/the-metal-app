import 'package:metal/core/error_handling/error_handler.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/datasources/remote/profile_remote_data_source.dart';
import 'package:metal/data/models/user_model.dart';
import 'package:metal/data/repositories/profile/profile_repository_abstract.dart';
import 'package:metal/domain/entities/user_dto.dart';

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
}
