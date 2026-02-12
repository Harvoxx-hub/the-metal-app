import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/viewmodels/user/user_state_provider.dart';

/// Service to track and update app version
class AppVersionService {
  static final AppVersionService _instance = AppVersionService._internal();
  factory AppVersionService() => _instance;
  AppVersionService._internal();

  String? _cachedVersion;

  /// Get current app version
  Future<String?> getAppVersion() async {
    try {
      if (_cachedVersion != null) {
        return _cachedVersion;
      }

      final packageInfo = await PackageInfo.fromPlatform();
      _cachedVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

      // Return version in format: "version+buildNumber" (e.g., "1.0.26+83")
      return _cachedVersion;
    } catch (e) {
      debugPrint('Error getting app version: $e');
      return null;
    }
  }

  /// Update app version in Firestore for the current user
  Future<void> updateAppVersion(WidgetRef ref) async {
    try {
      final version = await getAppVersion();
      if (version == null) {
        debugPrint('Could not get app version to update');
        return;
      }

      // Check if user is authenticated
      final user = ref.read(userStateProvider).user;
      if (user == null) {
        debugPrint('No user logged in, skipping app version update');
        return;
      }

      // Update user's app version in backend
      await ref.read(userStateProvider.notifier).updateUserField(
            field: 'appVersion',
            value: version,
          );

      debugPrint('App version updated successfully: $version');
    } catch (e) {
      debugPrint('Error updating app version: $e');
    }
  }
}
