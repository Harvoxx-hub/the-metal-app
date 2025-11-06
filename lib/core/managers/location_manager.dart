import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_service.dart';
import '../services/app_version_service.dart';
import '../../features/authentication/provider/user_state_notifier.dart';

/// Simple location manager for app startup
class LocationManager {
  static final LocationManager _instance = LocationManager._internal();
  factory LocationManager() => _instance;
  LocationManager._internal();

  final LocationService _locationService = LocationService();
  final AppVersionService _appVersionService = AppVersionService();
  bool _hasUpdatedLocation = false;

  /// Update user location and app version on app startup
  Future<void> updateLocationOnAppStart(WidgetRef ref) async {
    // Prevent multiple updates
    if (_hasUpdatedLocation) return;

    try {
      // Check if user is authenticated
      final user = ref.read(userStateProvider).data;
      if (user == null) return;

      // Get current location
      final location = await _locationService.getCurrentLocation();
      if (location != null) {
        // Update user location in Firestore
        await ref.read(userStateProvider.notifier).updateUserField(
              field: 'location',
              value: location.toJson(),
            );

        debugPrint('Location updated successfully: ${location.address}');
      }

      // Update app version
      await _appVersionService.updateAppVersion(ref);

      _hasUpdatedLocation = true;
    } catch (e) {
      debugPrint('Error updating location/app version: $e');
    }
  }

  /// Reset the update flag (useful for testing)
  void resetUpdateFlag() {
    _hasUpdatedLocation = false;
  }
}
