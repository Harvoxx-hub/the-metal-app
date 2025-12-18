import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/strings/app_strings.dart';
import 'package:metal/presentation/viewmodels/profile/profile_setup_viewmodel.dart';
import 'package:metal/presentation/views/profile/profile_setup_constants.dart';

/// Profile Setup Helpers
/// Shared utilities for profile setup screens
class ProfileSetupHelpers {
  /// Show error message widget
  static Widget buildErrorWidget(String? errorMessage) {
    if (errorMessage == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(
        bottom: ProfileSetupConstants.gapSmall,
        left: ProfileSetupConstants.horizontalPadding,
        right: ProfileSetupConstants.horizontalPadding,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ProfileSetupConstants.errorBackgroundColor
            .withOpacity(ProfileSetupConstants.errorOpacity),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ProfileSetupConstants.errorBackgroundColor
              .withOpacity(ProfileSetupConstants.errorBorderOpacity),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: ProfileSetupConstants.errorBackgroundColor,
            size: 20,
          ),
          const Gap(8),
          Expanded(
            child: Text(
              errorMessage,
              style: const TextStyle(
                color: ProfileSetupConstants.errorBackgroundColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show validation error snackbar
  static void showValidationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ProfileSetupConstants.errorBackgroundColor,
      ),
    );
  }

  /// Show warning snackbar
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ProfileSetupConstants.warningBackgroundColor,
      ),
    );
  }

  /// Handle step save and navigation
  static Future<void> saveStepAndNavigate({
    required BuildContext context,
    required WidgetRef ref,
    required ProfileSetupStep step,
    required Map<String, dynamic> stepData,
    required String nextRoute,
    bool mounted = true,
  }) async {
    await ref.read(profileSetupViewModelProvider.notifier).saveStepData(
          step: step,
          stepData: stepData,
        );

    final setupState = ref.read(profileSetupViewModelProvider);
    if (setupState.errorMessage == null && mounted && context.mounted) {
      Navigator.pushNamed(context, nextRoute);
    }
  }

  /// Get button text based on loading state
  static String getButtonText(bool isLoading, {String defaultText = AppStrings.nextButton}) {
    return isLoading ? AppStrings.saving : defaultText;
  }
}

