import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/services/user_update_service.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

/// Profile setup step enumeration
enum ProfileSetupStep {
  basicInfo, // Name, username, gender, DOB
  metalSelection, // Choose metal
  passions, // Select passions/interests
  aboutYou, // Marital status, religion, profession, language
  moreAboutYou, // Description
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
  final List<String> completedSteps;
  final double progress;
  final String? errorMessage;
  final bool isLoading;

  ProfileSetupState({
    required this.currentStep,
    required this.collectedData,
    required this.completedSteps,
    required this.progress,
    this.errorMessage,
    this.isLoading = false,
  });

  ProfileSetupState copyWith({
    ProfileSetupStep? currentStep,
    Map<String, dynamic>? collectedData,
    List<String>? completedSteps,
    double? progress,
    String? errorMessage,
    bool? isLoading,
  }) {
    return ProfileSetupState(
      currentStep: currentStep ?? this.currentStep,
      collectedData: collectedData ?? Map.from(this.collectedData),
      completedSteps: completedSteps ?? List.from(this.completedSteps),
      progress: progress ?? this.progress,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory ProfileSetupState.initial() {
    return ProfileSetupState(
      currentStep: ProfileSetupStep.basicInfo,
      collectedData: {},
      completedSteps: [],
      progress: 0.0,
    );
  }
}

/// Profile setup flow manager
class ProfileSetupManager extends StateNotifier<ProfileSetupState> {
  final Ref ref;
  final UserUpdateService _userUpdateService;

  ProfileSetupManager(this.ref, this._userUpdateService)
      : super(ProfileSetupState.initial());

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

  /// Initialize setup from existing user data
  Future<void> initializeFromExistingUser() async {
    final userState = ref.read(userStateProvider);
    if (userState.data != null) {
      final user = userState.data!;
      final userData = user.toJson();

      // Determine current step based on completed data
      ProfileSetupStep currentStep = _determineCurrentStep(userData);

      // Calculate progress
      double progress = _calculateProgress(currentStep);

      // Get completed steps
      List<String> completedSteps = _getCompletedSteps(userData);

      state = state.copyWith(
        currentStep: currentStep,
        collectedData: userData,
        completedSteps: completedSteps,
        progress: progress,
      );
    }
  }

  /// Save data for current step and move to next
  Future<void> saveStepData({
    required ProfileSetupStep step,
    required Map<String, dynamic> stepData,
    bool moveToNext = true,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Validate step data
      final validation = _validateStepData(step, stepData);
      if (!validation.isValid) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: validation.errors.join(', '),
        );
        return;
      }

      // Merge with collected data
      final updatedData = Map<String, dynamic>.from(state.collectedData);
      updatedData.addAll(stepData);

      // Determine appropriate profile section
      ProfileSection? section = _getProfileSection(step);

      // Update user data
      if (section != null) {
        final response = await _userUpdateService.updateProfileSection(
          section: section,
          data: stepData,
        );

        if (!response.success!) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: response.message ?? 'Failed to save step data',
          );
          return;
        }
      } else {
        // Fallback to regular update
        final response = await _userUpdateService.updateUser(
          updates: stepData,
          validateRequired: false,
        );

        if (!response.success!) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: response.message ?? 'Failed to save step data',
          );
          return;
        }
      }

      // Update local state
      final completedSteps = List<String>.from(state.completedSteps);
      if (!completedSteps.contains(step.name)) {
        completedSteps.add(step.name);
      }

      ProfileSetupStep nextStep = step;
      if (moveToNext) {
        nextStep = _getNextStep(step);
      }

      double progress = _calculateProgress(nextStep);

      state = state.copyWith(
        currentStep: nextStep,
        collectedData: updatedData,
        completedSteps: completedSteps,
        progress: progress,
        isLoading: false,
      );

      // Refresh user state
      await ref.read(userStateProvider.notifier).refreshUser();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error saving step data: ${e.toString()}',
      );
    }
  }

  /// Complete entire profile setup
  Future<void> completeProfileSetup() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Ensure all required data is present
      final finalData = Map<String, dynamic>.from(state.collectedData);
      finalData['completedProfile'] = true;
      finalData['profileUpdated'] = true;

      final response = await _userUpdateService.completeProfile(
        finalData: finalData,
      );

      if (response.success!) {
        state = state.copyWith(
          currentStep: ProfileSetupStep.completed,
          progress: 1.0,
          isLoading: false,
        );

        // Refresh user state
        await ref.read(userStateProvider.notifier).refreshUser();
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message ?? 'Failed to complete profile',
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
    double progress = _calculateProgress(step);
    state = state.copyWith(
      currentStep: step,
      progress: progress,
    );
  }

  /// Skip current step
  void skipCurrentStep() {
    final nextStep = _getNextStep(state.currentStep);
    double progress = _calculateProgress(nextStep);

    state = state.copyWith(
      currentStep: nextStep,
      progress: progress,
    );
  }

  /// Go back to previous step
  void goToPreviousStep() {
    final previousStep = _getPreviousStep(state.currentStep);
    double progress = _calculateProgress(previousStep);

    state = state.copyWith(
      currentStep: previousStep,
      progress: progress,
    );
  }

  /// Reset profile setup
  void resetSetup() {
    state = ProfileSetupState.initial();
  }

  /// Determine current step based on user data
  ProfileSetupStep _determineCurrentStep(Map<String, dynamic> userData) {
    // Check completion in order
    if (userData['completedProfile'] == true) {
      return ProfileSetupStep.completed;
    }

    if (userData['address'] == null) {
      return ProfileSetupStep.address;
    }

    if (userData['preferences'] == null) {
      return ProfileSetupStep.preferences;
    }

    if (userData['connectWith'] == null) {
      return ProfileSetupStep.connectionOptions;
    }

    if (userData['description'] == null) {
      return ProfileSetupStep.moreAboutYou;
    }

    if (userData['extraData'] == null) {
      return ProfileSetupStep.aboutYou;
    }

    if (userData['passion'] == null ||
        (userData['passion'] as List?)?.isEmpty == true) {
      return ProfileSetupStep.passions;
    }

    if (userData['metal'] == null) {
      return ProfileSetupStep.metalSelection;
    }

    if (userData['fullname'] == null ||
        userData['username'] == null ||
        userData['gender'] == null ||
        userData['dob'] == null) {
      return ProfileSetupStep.basicInfo;
    }

    return ProfileSetupStep.location; // Default next step
  }

  /// Get completed steps
  List<String> _getCompletedSteps(Map<String, dynamic> userData) {
    final completed = <String>[];

    if (userData['fullname'] != null && userData['username'] != null) {
      completed.add(ProfileSetupStep.basicInfo.name);
    }

    if (userData['metal'] != null) {
      completed.add(ProfileSetupStep.metalSelection.name);
    }

    if (userData['passion'] != null &&
        (userData['passion'] as List?)?.isNotEmpty == true) {
      completed.add(ProfileSetupStep.passions.name);
    }

    if (userData['extraData'] != null) {
      completed.add(ProfileSetupStep.aboutYou.name);
    }

    if (userData['description'] != null) {
      completed.add(ProfileSetupStep.moreAboutYou.name);
    }

    if (userData['connectWith'] != null) {
      completed.add(ProfileSetupStep.connectionOptions.name);
    }

    if (userData['preferences'] != null) {
      completed.add(ProfileSetupStep.preferences.name);
    }

    if (userData['address'] != null) {
      completed.add(ProfileSetupStep.address.name);
    }

    if (userData['completedProfile'] == true) {
      completed.add(ProfileSetupStep.completed.name);
    }

    return completed;
  }

  /// Calculate progress percentage
  double _calculateProgress(ProfileSetupStep step) {
    final totalSteps = _stepOrder.length;
    final currentStepIndex = _stepOrder[step] ?? 0;
    return currentStepIndex / (totalSteps - 1);
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

  /// Get profile section for step
  ProfileSection? _getProfileSection(ProfileSetupStep step) {
    switch (step) {
      case ProfileSetupStep.basicInfo:
        return ProfileSection.basicInfo;
      case ProfileSetupStep.metalSelection:
        return ProfileSection.metals;
      case ProfileSetupStep.passions:
        return ProfileSection.passions;
      case ProfileSetupStep.aboutYou:
        return ProfileSection.extraData;
      case ProfileSetupStep.preferences:
        return ProfileSection.preferences;
      case ProfileSetupStep.address:
        return ProfileSection.address;
      default:
        return null;
    }
  }

  /// Validate step data
  ValidationResult _validateStepData(
      ProfileSetupStep step, Map<String, dynamic> data) {
    final errors = <String>[];

    switch (step) {
      case ProfileSetupStep.basicInfo:
        if (data['fullname'] == null ||
            (data['fullname'] as String).trim().isEmpty) {
          errors.add('Full name is required');
        }
        if (data['username'] == null ||
            (data['username'] as String).trim().isEmpty) {
          errors.add('Username is required');
        }
        if (data['gender'] == null) {
          errors.add('Gender is required');
        }
        if (data['dob'] == null || (data['dob'] as String).trim().isEmpty) {
          errors.add('Date of birth is required');
        }
        break;

      case ProfileSetupStep.metalSelection:
        if (data['metal'] == null || (data['metal'] as String).trim().isEmpty) {
          errors.add('Metal selection is required');
        }
        break;

      case ProfileSetupStep.passions:
        if (data['passion'] == null ||
            (data['passion'] as List?)?.isEmpty == true) {
          errors.add('At least one passion must be selected');
        }
        break;

      case ProfileSetupStep.address:
        if (data['address'] != null) {
          final address = data['address'] as Map<String, dynamic>;
          if (address['country'] == null || address['state'] == null) {
            errors.add('Country and state are required');
          }
        }
        break;

      default:
        // Other steps may have optional validation
        break;
    }

    return ValidationResult(errors.isEmpty, errors);
  }
}

/// Provider for profile setup manager
final profileSetupManagerProvider =
    StateNotifierProvider<ProfileSetupManager, ProfileSetupState>((ref) {
  final userUpdateService = ref.watch(userUpdateServiceProvider);
  return ProfileSetupManager(ref, userUpdateService);
});

/// Provider for current setup step
final currentSetupStepProvider = Provider<ProfileSetupStep>((ref) {
  final setupState = ref.watch(profileSetupManagerProvider);
  return setupState.currentStep;
});

/// Provider for setup progress
final setupProgressProvider = Provider<double>((ref) {
  final setupState = ref.watch(profileSetupManagerProvider);
  return setupState.progress;
});
