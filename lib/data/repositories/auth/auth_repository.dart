import 'package:metal/core/error_handling/error_handler.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/datasources/remote/auth_remote_data_source.dart';
import 'package:metal/data/models/user_model.dart';
import 'package:metal/data/repositories/auth/auth_repository_abstract.dart';
import 'package:metal/domain/entities/user_dto.dart';

/// Authentication repository implementation
/// Coordinates between remote data source and domain layer
/// Handles only authentication operations (login, signup, logout)
class AuthRepository implements AuthRepositoryAbstract {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthRepository({
    required this.authRemoteDataSource,
  });

  @override
  Future<BaseState<LoginResponseDto>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await authRemoteDataSource.login(
        email: email,
        password: password,
      );

      // Map API response to domain entity
      final loginResponse = LoginResponseModel.fromJson({
        'data': response,
      }).toDomain();

      return BaseState.success(loginResponse);
    } catch (e) {
      return ErrorHandler.handleError<LoginResponseDto>(e);
    }
  }

  @override
  Future<BaseState<LoginResponseDto>> signup({
    required String email,
    required String password,
    required String phoneNationalNumber,
    required String phoneCountryIso2,
    String? referralCode,
    String? fcmToken,
  }) async {
    try {
      final response = await authRemoteDataSource.signup(
        email: email,
        password: password,
        phoneNationalNumber: phoneNationalNumber,
        phoneCountryIso2: phoneCountryIso2,
        referralCode: referralCode,
        fcmToken: fcmToken,
      );

      final loginResponse = LoginResponseModel.fromJson({
        'data': response,
      }).toDomain();

      return BaseState.success(loginResponse);
    } catch (e) {
      return ErrorHandler.handleError<LoginResponseDto>(e);
    }
  }

  @override
  Future<BaseState<void>> logout() async {
    try {
      await authRemoteDataSource.logout();
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  @override
  Future<BaseState<void>> sendVerificationCode(String email) async {
    try {
      await authRemoteDataSource.sendVerificationCode(email);
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  @override
  Future<BaseState<void>> verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      await authRemoteDataSource.verifyCode(email: email, code: code);
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  @override
  Future<BaseState<void>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await authRemoteDataSource.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }
}
