import 'package:flutter/widgets.dart';
 
import 'package:metal/core/services/shorebird_update_service.dart';

/// Handles app lifecycle events for presence management and notifications.
///
/// This handler works in conjunction with [PresenceService] which handles
/// the core presence logic using Firebase Realtime Database's .onDisconnect().
///
/// The handler now delegates presence updates to PresenceService, which:
/// 1. Automatically handles auth state changes (login/logout)
/// 2. Uses server-side disconnect detection for reliability
/// 3. Syncs status to Firestore via Cloud Functions
class AppLifecycleHandler extends WidgetsBindingObserver {
  DateTime? _lastResumedTime;
  bool _isInitialized = false;

  AppLifecycleHandler();

  /// Initialize the handler and presence service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize the presence service (handles its own auth state)
   
    _isInitialized = true;

    print('AppLifecycleHandler initialized');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized) {
      print('AppLifecycleHandler not initialized, skipping state change');
      return;
    }

    final now = DateTime.now();

    switch (state) {
      case AppLifecycleState.resumed:
        _lastResumedTime = now;
        
        // Check for Shorebird updates when app resumes
        _checkForShorebirdUpdates();
  
        break;

      case AppLifecycleState.inactive:
        // App is inactive but still visible (e.g., incoming call, control center)
        // Don't change presence - this is often temporary
        print('App is inactive - presence unchanged');
        break;

      case AppLifecycleState.hidden:
        // App is hidden but not paused (iOS specific)
        // Don't change presence - user might come back quickly
        print('App is hidden - presence unchanged');
        break;

      case AppLifecycleState.paused:
  
        break;

      case AppLifecycleState.detached:
        // App is detached from the engine
        // Note: This is unreliable and may not be called on force kills
        // That's why we rely on RTDB .onDisconnect() as the primary mechanism
       
        break;
    }
  }

  /// Check for Shorebird OTA updates when app resumes
  /// Only checks if app has been in background for at least 30 seconds
  void _checkForShorebirdUpdates() async {
    try {
      // Only check for updates if app was in background for a reasonable time
      // This avoids excessive checks on quick app switches
      if (_lastResumedTime != null) {
        final timeSinceLastResume = DateTime.now().difference(_lastResumedTime!);
        if (timeSinceLastResume.inSeconds < 30) {
          // Skip if app was only briefly in background
          return;
        }
      }

      // Check for updates in background (non-blocking)
      ShorebirdUpdateService.instance.checkForUpdates().then((hasUpdate) {
        if (hasUpdate) {
          print('Shorebird: New patch available, downloading in background...');
          // Download will happen automatically if auto_update is enabled
          // Otherwise, we can trigger it here if needed
          ShorebirdUpdateService.instance.downloadAndApplyPatch();
        }
      }).catchError((e) {
        print('Shorebird: Error during update check on resume: $e');
      });
    } catch (e) {
      print('Shorebird: Error setting up update check: $e');
    }
  }
 }
