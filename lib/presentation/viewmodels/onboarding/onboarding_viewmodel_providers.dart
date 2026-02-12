import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/presentation/viewmodels/onboarding/onboarding_viewmodel.dart';
import 'package:metal/presentation/viewmodels/splash/splash_viewmodel_providers.dart';

/// Onboarding ViewModel Provider
final onboardingViewModelProvider =
    StateNotifierProvider<OnboardingViewModel, BaseState<bool>>((ref) {
  return OnboardingViewModel(
    authCheckUseCase: ref.read(authCheckUseCaseProvider),
  );
});
