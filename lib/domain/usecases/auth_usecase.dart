import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/repositories/auth/auth_repository_abstract.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/domain/usecases/base_usecase.dart';

/// Login use case parameters
class LoginParams {
  final String email;
  final String password;

  LoginParams({
    required this.email,
    required this.password,
  });
}

/// Signup use case parameters
class SignupParams {
  final String email;
  final String password;
  final String phoneNumber;
  final String? referralCode;
  final String? fcmToken;

  SignupParams({
    required this.email,
    required this.password,
    required this.phoneNumber,
    this.referralCode,
    this.fcmToken,
  });
}

/// Login use case
class LoginUseCase implements BaseUseCase<LoginResponseDto, LoginParams> {
  final AuthRepositoryAbstract repository;

  LoginUseCase(this.repository);

  @override
  Future<BaseState<LoginResponseDto>> call(LoginParams params) async {
    return await repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

/// Signup use case
class SignupUseCase implements BaseUseCase<LoginResponseDto, SignupParams> {
  final AuthRepositoryAbstract repository;

  SignupUseCase(this.repository);

  @override
  Future<BaseState<LoginResponseDto>> call(SignupParams params) async {
    return await repository.signup(
      email: params.email,
      password: params.password,
      phoneNumber: params.phoneNumber,
      referralCode: params.referralCode,
      fcmToken: params.fcmToken,
    );
  }
}

/// Logout use case
class LogoutUseCase implements BaseUseCaseNoParams<void> {
  final AuthRepositoryAbstract repository;

  LogoutUseCase(this.repository);

  @override
  Future<BaseState<void>> call() async {
    return await repository.logout();
  }
}

