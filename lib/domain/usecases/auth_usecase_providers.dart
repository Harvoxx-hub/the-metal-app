import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/auth/auth_repository_providers.dart';
import 'package:metal/domain/usecases/auth_usecase.dart';

/// Login Use Case Provider
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

/// Signup Use Case Provider
final signupUseCaseProvider = Provider<SignupUseCase>((ref) {
  return SignupUseCase(ref.read(authRepositoryProvider));
});

/// Logout Use Case Provider
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
});
