import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/repositories/profile/profile_repository_abstract.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/domain/usecases/base_usecase.dart';

/// Profile update parameters
class UpdateProfileParams {
  final String? fullname;
  final String? username;
  final String? gender;
  final String? dob;
  final String? bio;
  final String? metal;
  final List<String>? passions;
  final Map<String, dynamic>? extraData;

  UpdateProfileParams({
    this.fullname,
    this.username,
    this.gender,
    this.dob,
    this.bio,
    this.metal,
    this.passions,
    this.extraData,
  });

  Map<String, dynamic> toJson() {
    return {
      if (fullname != null) 'fullname': fullname,
      if (username != null) 'username': username,
      if (gender != null) 'gender': gender,
      if (dob != null) 'dob': dob,
      if (bio != null) 'bio': bio,
      if (metal != null) 'metal': metal,
      if (passions != null) 'passion': passions,
      if (extraData != null) 'extraData': extraData,
      'profileUpdated': true,
    };
  }
}

/// Get user profile use case
/// Used to fetch and maintain user state throughout the application
class GetUserProfileUseCase implements BaseUseCaseNoParams<UserDto> {
  final ProfileRepositoryAbstract repository;

  GetUserProfileUseCase(this.repository);

  @override
  Future<BaseState<UserDto>> call() async {
    return await repository.getUserProfile();
  }
}

/// Update profile use case
class UpdateProfileUseCase
    implements BaseUseCase<UserDto, UpdateProfileParams> {
  final ProfileRepositoryAbstract repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<BaseState<UserDto>> call(UpdateProfileParams params) async {
    return await repository.updateUserProfile(
      profileData: params.toJson(),
    );
  }
}

/// Complete profile parameters
class CompleteProfileParams {
  final Map<String, dynamic> finalData;

  CompleteProfileParams({
    required this.finalData,
  });

  Map<String, dynamic> toJson() {
    return finalData;
  }
}

/// Complete profile use case
class CompleteProfileUseCase
    implements BaseUseCase<UserDto, CompleteProfileParams> {
  final ProfileRepositoryAbstract repository;

  CompleteProfileUseCase(this.repository);

  @override
  Future<BaseState<UserDto>> call(CompleteProfileParams params) async {
    return await repository.completeProfile(
      finalData: params.toJson(),
    );
  }
}
