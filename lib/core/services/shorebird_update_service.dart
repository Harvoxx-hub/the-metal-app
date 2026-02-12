import 'package:flutter/foundation.dart';

/// Service for handling Shorebird OTA updates
/// Manages patch checking, downloading, and applying
///
/// Note: With auto_update enabled in shorebird.yaml, Shorebird automatically
/// checks for and downloads patches on app launch. This service ensures
/// proper initialization timing to prevent splash screen hangs.
class ShorebirdUpdateService {
  ShorebirdUpdateService._();
  static final ShorebirdUpdateService instance = ShorebirdUpdateService._();

  bool _isInitialized = false;
  bool _isChecking = false;

  /// Initialize Shorebird and wait for it to be ready
  /// This is critical to prevent the app from getting stuck on splash screen
  /// after applying a patch on Android.
  ///
  /// With auto_update enabled, Shorebird handles patches automatically,
  /// but we need to give it time to initialize before the app proceeds.
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('Shorebird: Already initialized');
      return;
    }

    try {
      debugPrint('Shorebird: Initializing...');

      // With auto_update enabled, Shorebird automatically handles patch downloads
      // However, we need to wait a bit to ensure Shorebird has time to:
      // 1. Check for available patches
      // 2. Download any patches if available
      // 3. Apply patches before the app continues
      //
      // This delay prevents the app from getting stuck on splash screen
      // when a patch has been applied but the app tries to use patched code
      // before it's fully ready.
      await Future.delayed(const Duration(milliseconds: 1000));

      _isInitialized = true;
      debugPrint('Shorebird: Initialization complete');
    } catch (e) {
      debugPrint('Shorebird: Error during initialization: $e');
      // Continue even if initialization fails to prevent app from hanging
      _isInitialized = true;
    }
  }

  /// Check if a new patch is available for download
  ///
  /// Note: With auto_update enabled in shorebird.yaml, Shorebird automatically
  /// handles patch checking and downloading. This method is a placeholder for
  /// future manual control if auto_update is disabled.
  Future<bool> checkForUpdates() async {
    if (_isChecking) {
      debugPrint('Shorebird: Update check already in progress');
      return false;
    }

    try {
      _isChecking = true;

      // Ensure Shorebird is initialized first
      if (!_isInitialized) {
        await initialize();
      }

      // With auto_update enabled, Shorebird handles updates automatically
      // This is a placeholder for future manual update checking
      debugPrint(
          'Shorebird: Update check triggered (auto_update is enabled in shorebird.yaml)');
      return false;
    } catch (e) {
      debugPrint('Shorebird: Error checking for updates: $e');
      return false;
    } finally {
      _isChecking = false;
    }
  }

  /// Download and apply the latest patch if available
  ///
  /// Note: With auto_update enabled, patches are downloaded automatically.
  /// This method is a placeholder for future manual control.
  Future<bool> downloadAndApplyPatch() async {
    try {
      // Ensure Shorebird is initialized first
      if (!_isInitialized) {
        await initialize();
      }

      debugPrint(
          'Shorebird: Patch download triggered (auto_update handles this automatically)');
      return false;
    } catch (e) {
      debugPrint('Shorebird: Error downloading patch: $e');
      return false;
    }
  }
}
