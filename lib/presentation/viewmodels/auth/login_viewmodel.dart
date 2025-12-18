import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/di/provider_setup.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/storage/secure_storage_helper.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/domain/usecases/auth_usecase.dart';
import 'package:metal/domain/usecases/auth_usecase_providers.dart';
import 'package:metal/presentation/viewmodels/base_viewmodel.dart';

/// Login ViewModel
/// Manages login state and business logic
class LoginViewModel extends BaseViewModel<LoginResponseDto> {
  final LoginUseCase loginUseCase;
  final SecureStorageHelper secureStorage;

  LoginViewModel({
    required this.loginUseCase,
    required this.secureStorage,
  });

  /// Login with email and password
  Future<void> login(String email, String password) async {
    setLoading();

    final result = await loginUseCase(
      LoginParams(email: email, password: password),
    );

    if (result.isSuccess && result.data != null) {
      // Store authentication token and refresh token
      await _storeAuthTokens(
        result.data!.token,
        result.data!.refreshToken,
      );

      setSuccess(result.data!);
    } else {
      setError(result.errorMessage ?? 'Login failed');
    }
  }

  /// Store authentication tokens securely
  Future<void> _storeAuthTokens(String token, String? refreshToken) async {
    try {
      await secureStorage.setString('auth_token', token);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await secureStorage.setString('refresh_token', refreshToken);
      }
    } catch (e) {
      print('Failed to store auth tokens: $e');
    }
  }
}

/// Login ViewModel Provider
final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, BaseState<LoginResponseDto>>((ref) {
  return LoginViewModel(
    loginUseCase: ref.read(loginUseCaseProvider),
    secureStorage: ref.read(secureStorageHelperProvider),
  );
});
