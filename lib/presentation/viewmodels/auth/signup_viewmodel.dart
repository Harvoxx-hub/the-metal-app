import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/di/provider_setup.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/storage/secure_storage_helper.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/domain/usecases/auth_usecase.dart';
import 'package:metal/domain/usecases/auth_usecase_providers.dart';
import 'package:metal/fcm/fcm_client.dart';
import 'package:metal/presentation/viewmodels/base_viewmodel.dart';

/// Signup ViewModel
/// Manages signup state and business logic
class SignupViewModel extends BaseViewModel<LoginResponseDto> {
  final SignupUseCase signupUseCase;
  final SecureStorageHelper secureStorage;

  SignupViewModel({
    required this.signupUseCase,
    required this.secureStorage,
  });

  /// Signup with user details
  Future<void> signup({
    required String email,
    required String password,
    required String phoneNationalNumber,
    required String phoneCountryIso2,
    String? referralCode,
  }) async {
    setLoading();

    try {
      // Initialize FCM token
      String? fcmToken;
      try {
        fcmToken = await FCMClient.instance.init();
      } catch (e) {
        debugPrint('FCM initialization failed during signup: $e');
        // Continue with signup even if FCM fails
        fcmToken = null;
      }

      final result = await signupUseCase(
        SignupParams(
          email: email,
          password: password,
          phoneNationalNumber: phoneNationalNumber,
          phoneCountryIso2: phoneCountryIso2,
          referralCode: referralCode,
          fcmToken: fcmToken,
        ),
      );

      if (result.isSuccess && result.data != null) {
        // Store authentication token and refresh token
        await _storeAuthTokens(
          result.data!.token,
          result.data!.refreshToken,
        );
        setSuccess(result.data!);
      } else {
        setError(result.errorMessage ?? 'Signup failed');
      }
    } catch (e) {
      setError('Signup failed: ${e.toString()}');
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
      debugPrint('Failed to store auth tokens: $e');
    }
  }
}

/// Signup ViewModel Provider
final signupViewModelProvider =
    StateNotifierProvider<SignupViewModel, BaseState<LoginResponseDto>>((ref) {
  return SignupViewModel(
    signupUseCase: ref.read(signupUseCaseProvider),
    secureStorage: ref.read(secureStorageHelperProvider),
  );
});
