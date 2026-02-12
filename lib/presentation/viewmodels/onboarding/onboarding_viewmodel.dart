import 'package:metal/domain/usecases/auth_check_usecase.dart';
import 'package:metal/presentation/viewmodels/base_viewmodel.dart';

/// Onboarding ViewModel
/// Handles onboarding state and marking it as seen
class OnboardingViewModel extends BaseViewModel<bool> {
  final AuthCheckUseCase authCheckUseCase;

  OnboardingViewModel({
    required this.authCheckUseCase,
  });

  /// Mark onboarding as seen
  Future<void> markOnboardingSeen() async {
    try {
      await authCheckUseCase.markOnboardingSeen();
      setSuccess(true);
    } catch (e) {
      setError('Failed to save onboarding state: ${e.toString()}');
    }
  }
}
