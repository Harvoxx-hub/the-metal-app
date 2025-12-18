import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/di/provider_setup.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/data/repositories/profile/profile_repository_providers.dart';
import 'package:metal/domain/usecases/auth_check_usecase.dart';
import 'package:metal/presentation/viewmodels/splash/splash_viewmodel.dart';

/// Auth Check Use Case Provider
final authCheckUseCaseProvider = Provider<AuthCheckUseCase>((ref) {
  return AuthCheckUseCase(
    secureStorage: ref.read(secureStorageHelperProvider),
    sharedPrefs: ref.read(sharedPrefsHelperProvider),
    profileRepository: ref.read(profileRepositoryProvider),
  );
});

/// Splash ViewModel Provider
final splashViewModelProvider =
    StateNotifierProvider<SplashViewModel, BaseState<UserDto?>>((ref) {
  return SplashViewModel(
    authCheckUseCase: ref.read(authCheckUseCaseProvider),
  );
});
