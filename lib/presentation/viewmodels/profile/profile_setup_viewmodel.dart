import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/domain/usecases/profile_usecase.dart';
import 'package:metal/domain/usecases/profile_usecase_providers.dart';

/// Profile setup step enumeration
enum ProfileSetupStep {
  basicInfo, // Name, username, gender, DOB
  metalSelection, // Choose metal
  passions, // Select passions/interests
  aboutYou, // Marital status, religion, profession, language
  moreAboutYou, // Description/bio
  connectionOptions, // What looking for
  preferences, // Dating preferences
  address, // Home address
  location, // Location permissions
  notifications, // Notification permissions
  completed, // Profile setup complete
}

/// Profile setup state
class ProfileSetupState {
  final ProfileSetupStep currentStep;
  final Map<String, dynamic> collectedData;
  final double progress;
  final bool isLoading;
  final String? errorMessage;

  ProfileSetupState({
    required this.currentStep,
    required this.collectedData,
    required this.progress,
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileSetupState copyWith({
    ProfileSetupStep? currentStep,
    Map<String, dynamic>? collectedData,
    double? progress,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileSetupState(
      currentStep: currentStep ?? this.currentStep,
      collectedData: collectedData ?? Map.from(this.collectedData),
      progress: progress ?? this.progress,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  factory ProfileSetupState.initial() {
    return ProfileSetupState(
      currentStep: ProfileSetupStep.basicInfo,
      collectedData: {},
      progress: 0.0,
    );
  }
}

/// Profile setup ViewModel
/// Manages multi-step profile completion flow
/// Step data is stored locally, only final completion calls API
class ProfileSetupViewModel extends StateNotifier<ProfileSetupState> {
  final CompleteProfileUseCase completeProfileUseCase;

  ProfileSetupViewModel({
    required this.completeProfileUseCase,
  }) : super(ProfileSetupState.initial());

  static const Map<ProfileSetupStep, int> _stepOrder = {
    ProfileSetupStep.basicInfo: 0,
    ProfileSetupStep.metalSelection: 1,
    ProfileSetupStep.passions: 2,
    ProfileSetupStep.aboutYou: 3,
    ProfileSetupStep.moreAboutYou: 4,
    ProfileSetupStep.connectionOptions: 5,
    ProfileSetupStep.preferences: 6,
    ProfileSetupStep.address: 7,
    ProfileSetupStep.location: 8,
    ProfileSetupStep.notifications: 9,
    ProfileSetupStep.completed: 10,
  };

  /// Save step data and move to next step
  /// Data is stored locally, no API call until profile completion
  Future<void> saveStepData({
    required ProfileSetupStep step,
    required Map<String, dynamic> stepData,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Merge with collected data (local storage only)
      final updatedData = Map<String, dynamic>.from(state.collectedData);
      updatedData.addAll(stepData);

      // Move to next step (no API call, just local state update)
      final nextStep = _getNextStep(step);
      final progress = _calculateProgress(nextStep);

      state = state.copyWith(
        currentStep: nextStep,
        collectedData: updatedData,
        progress: progress,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error saving step: ${e.toString()}',
      );
    }
  }

  /// Complete profile setup
  Future<void> completeProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final finalData = Map<String, dynamic>.from(state.collectedData);
      finalData['completedProfile'] = true;
      finalData['profileUpdated'] = true;

      // Call API to complete profile
      final result = await completeProfileUseCase(
        CompleteProfileParams(finalData: finalData),
      );

      if (result.isSuccess) {
        state = state.copyWith(
          currentStep: ProfileSetupStep.completed,
          progress: 1.0,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.errorMessage ?? 'Failed to complete profile',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error completing profile: ${e.toString()}',
      );
    }
  }

  /// Navigate to specific step
  void navigateToStep(ProfileSetupStep step) {
    final progress = _calculateProgress(step);
    state = state.copyWith(currentStep: step, progress: progress);
  }

  /// Go to previous step
  void goToPreviousStep() {
    final previousStep = _getPreviousStep(state.currentStep);
    final progress = _calculateProgress(previousStep);
    state = state.copyWith(currentStep: previousStep, progress: progress);
  }

  /// Get next step
  ProfileSetupStep _getNextStep(ProfileSetupStep currentStep) {
    final currentIndex = _stepOrder[currentStep] ?? 0;
    final nextIndex = currentIndex + 1;

    for (final entry in _stepOrder.entries) {
      if (entry.value == nextIndex) {
        return entry.key;
      }
    }

    return ProfileSetupStep.completed;
  }

  /// Get previous step
  ProfileSetupStep _getPreviousStep(ProfileSetupStep currentStep) {
    final currentIndex = _stepOrder[currentStep] ?? 0;
    final prevIndex = currentIndex - 1;

    if (prevIndex < 0) return ProfileSetupStep.basicInfo;

    for (final entry in _stepOrder.entries) {
      if (entry.value == prevIndex) {
        return entry.key;
      }
    }

    return ProfileSetupStep.basicInfo;
  }

  /// Calculate progress percentage
  double _calculateProgress(ProfileSetupStep step) {
    final totalSteps = _stepOrder.length;
    final currentStepIndex = _stepOrder[step] ?? 0;
    return currentStepIndex / (totalSteps - 1);
  }
}

/// Profile setup ViewModel Provider
final profileSetupViewModelProvider =
    StateNotifierProvider<ProfileSetupViewModel, ProfileSetupState>((ref) {
  return ProfileSetupViewModel(
    completeProfileUseCase: ref.read(completeProfileUseCaseProvider),
  );
});
