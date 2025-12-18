import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/domain/usecases/auth_check_usecase.dart';
import 'package:metal/presentation/viewmodels/base_viewmodel.dart';

/// Splash ViewModel
/// Handles initial app state check and navigation decision
class SplashViewModel extends BaseViewModel<UserDto?> {
  final AuthCheckUseCase authCheckUseCase;

  SplashViewModel({
    required this.authCheckUseCase,
  });

  /// Check authentication state and determine navigation
  Future<void> checkAuthState() async {
    setLoading();

    final result = await authCheckUseCase();

    if (result.isSuccess) {
      // If result.data is null, user is not authenticated
      // If result.data is not null, user is authenticated
      setSuccess(result.data);
    } else {
      setError(result.errorMessage ?? 'Failed to check authentication');
    }
  }

  /// Check if user has seen onboarding
  Future<bool> hasSeenOnboarding() async {
    return await authCheckUseCase.hasSeenOnboarding();
  }

  /// Mark onboarding as seen
  Future<void> markOnboardingSeen() async {
    await authCheckUseCase.markOnboardingSeen();
  }
}

/// Splash navigation state
enum SplashNavigationState {
  onboarding, // User hasn't seen onboarding or not logged in
  login, // User needs to login
  verification, // User needs email verification
  welcome, // User needs to complete profile
  dashboard, // User is fully set up
}
