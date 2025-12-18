import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/managers/location_manager.dart';
import 'package:metal/core/services/firebase.remote.config.service.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/presentation/views/dashboard/widgets/new_update_dialog.dart';
import 'package:metal/presentation/views/dashboard/widgets/thought_reminder_dialog.dart';
import 'package:metal/presentation/views/dashboard/widgets/verification.dialog.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle app startup tasks
/// Centralizes initialization logic that was previously in the dashboard
/// Uses NEW Clean Architecture - UserDto from domain/entities
class StartupService {
  bool _initialized = false;

  /// Run all startup tasks
  /// Call this once when dashboard loads
  Future<void> runStartupTasks(
    BuildContext context,
    WidgetRef ref,
    UserDto? userData,
  ) async {
    if (_initialized || userData == null || !context.mounted) return;
    _initialized = true;

    // 1. Update location
    await _updateLocation(context, ref);

    // 2. Check onboarding and user status
    await _checkOnboardingAndUserStatus(context, userData);
  }

  /// Update user location on startup
  Future<void> _updateLocation(BuildContext context, WidgetRef ref) async {
    try {
      await LocationManager().updateLocationOnAppStart(ref, context);
    } catch (e) {
      debugPrint('Location update failed: $e');
    }
  }

  /// Check onboarding status and show relevant dialogs
  Future<void> _checkOnboardingAndUserStatus(
    BuildContext context,
    UserDto userData,
  ) async {
    if (!context.mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    final hasSeenThoughtReminder =
        prefs.getBool('hasSeenThoughtReminder') ?? false;
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.buildNumber;

    // Calculate if user is within 7 days of creation
    final creationDate = userData.createdAt != null
        ? DateTime.parse(userData.createdAt!)
        : DateTime.now();
    final isWithin7Days = DateTime.now().difference(creationDate).inDays <= 7;

    if (!hasSeenOnboarding) {
      await prefs.setBool('hasSeenOnboarding', true);
      await _checkUserVerificationStatus(context, userData);
    } else if (_isUpdateAvailable(currentVersion)) {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (_) => const CustomDialog(content: NewUpdateDialog()),
        );
      }
    } else {
      await _checkUserVerificationStatus(context, userData);

      // Show thought reminder for new users
      if (isWithin7Days && !hasSeenThoughtReminder && context.mounted) {
        await showDialog(
          context: context,
          builder: (_) => const CustomDialog(content: ThoughtReminderDialog()),
        );
        await prefs.setBool('hasSeenThoughtReminder', true);
      }
    }
  }

  /// Check if app update is available
  bool _isUpdateAvailable(String currentVersion) {
    final latestVersion = FirebaseRemoteConfigService().getLatestVersion();
    final currentPart = int.tryParse(currentVersion) ?? 0;
    final latestPart = int.tryParse(latestVersion) ?? 0;
    return latestPart > currentPart;
  }

  /// Check user verification status and show dialog if needed
  Future<void> _checkUserVerificationStatus(
    BuildContext context,
    UserDto userData,
  ) async {
    if (userData.workEmailVerified == false && context.mounted) {
      await showDialog(
        context: context,
        builder: (_) => const CustomDialog(content: VerificationDialog()),
      );
    }
  }

  /// Reset initialization state (for testing or re-init)
  void reset() {
    _initialized = false;
  }
}

/// Provider for StartupService
final startupServiceProvider = Provider<StartupService>((ref) {
  return StartupService();
});
