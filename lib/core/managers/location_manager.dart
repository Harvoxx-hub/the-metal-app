import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_service.dart';
import '../services/app_version_service.dart';
import '../utils/permission_helper.dart';
import '../../presentation/viewmodels/user/user_state_provider.dart';

/// Simple location manager for app startup
class LocationManager {
  static final LocationManager _instance = LocationManager._internal();
  factory LocationManager() => _instance;
  LocationManager._internal();

  final LocationService _locationService = LocationService();
  final AppVersionService _appVersionService = AppVersionService();
  bool _hasUpdatedLocation = false;

  /// Update user location and app version on app startup
  Future<void> updateLocationOnAppStart(
      WidgetRef ref, BuildContext context) async {
    // Prevent multiple updates
    if (_hasUpdatedLocation) return;

    try {
      // Check if user is authenticated
      final user = ref.read(userStateProvider).user;
      if (user == null) return;

      // Get current location
      final result = await _locationService.getCurrentLocation();

      if (result.isSuccess && result.location != null) {
        // Update user location in Firestore
        await ref.read(userStateProvider.notifier).updateUserField(
              field: 'location',
              value: result.location!.toJson(),
            );

        debugPrint(
            'Location updated successfully: ${result.location!.address}');
      } else if (result.needsPermission && context.mounted) {
        // Handle permission denial
        await _handleLocationPermission(context, result, ref);
      }

      // Update app version
      await _appVersionService.updateAppVersion(ref);

      _hasUpdatedLocation = true;
    } catch (e) {
      debugPrint('Error updating location/app version: $e');
    }
  }

  /// Get current location and update user profile. Call after user grants permission (e.g. on Discovery).
  /// Returns true if location was obtained and profile updated.
  Future<bool> updateProfileLocation(WidgetRef ref) async {
    try {
      final user = ref.read(userStateProvider).user;
      if (user == null) return false;

      final result = await _locationService.getCurrentLocation();
      if (result.isSuccess && result.location != null) {
        await ref.read(userStateProvider.notifier).updateUserField(
              field: 'location',
              value: result.location!.toJson(),
            );
        debugPrint(
            'Profile location updated successfully: ${result.location!.address}');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating profile location: $e');
      return false;
    }
  }

  /// Handle location permission denial
  /// Note: This method is kept for backward compatibility but location permission
  /// is now handled in the HomePage with a full-screen UI instead of dialogs
  Future<void> _handleLocationPermission(
      BuildContext context, LocationResult result, WidgetRef ref) async {
    if (!context.mounted) return;

    // Check if location service is disabled
    if (result.serviceDisabled) {
      // For app startup, we'll let the HomePage handle the UI
      // Just log the issue
      debugPrint('Location service is disabled');
      return;
    }

    // Check if permission is permanently denied (permission_handler)
    final isPermanentlyDenied =
        await PermissionHelper.isLocationPermanentlyDenied();
    if (isPermanentlyDenied) {
      debugPrint('Location permission is permanently denied');
      // The HomePage will show the location permission screen
      return;
    }

    // Permission denied - HomePage will handle showing the screen
    debugPrint('Location permission denied');
  }

  /// Reset the update flag (useful for testing)
  void resetUpdateFlag() {
    _hasUpdatedLocation = false;
  }
}
