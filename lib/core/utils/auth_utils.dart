import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/route/routes.dart';

/// Auth utilities for common auth operations
class AuthUtils {
  /// Logout and navigate to onboarding
  /// Call this from anywhere to logout the user
  static Future<void> logout(BuildContext context, WidgetRef ref) async {
    // Clear user state and tokens
    await ref.read(userStateProvider.notifier).logout();

    // Navigate to onboarding and clear navigation stack
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.onboarding,
        (route) => false,
      );
    }
  }

  /// Check if user is authenticated
  static bool isAuthenticated(WidgetRef ref) {
    return ref.read(userStateProvider).isAuthenticated;
  }

  /// Get current user ID
  static String? getCurrentUserId(WidgetRef ref) {
    return ref.read(userStateProvider).user?.id;
  }

  /// Get current user email
  static String? getCurrentUserEmail(WidgetRef ref) {
    return ref.read(userStateProvider).user?.email;
  }
}

