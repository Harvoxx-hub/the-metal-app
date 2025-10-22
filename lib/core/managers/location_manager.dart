import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_service.dart';
import '../../features/authentication/provider/user_state_notifier.dart';

/// Simple location manager for app startup
class LocationManager {
  static final LocationManager _instance = LocationManager._internal();
  factory LocationManager() => _instance;
  LocationManager._internal();

  final LocationService _locationService = LocationService();
  bool _hasUpdatedLocation = false;

  /// Update user location on app startup
  Future<void> updateLocationOnAppStart(WidgetRef ref) async {
    // Prevent multiple updates
    if (_hasUpdatedLocation) return;

    try {
      // Check if user is authenticated
      final user = ref.read(userStateProvider).data;
      if (user == null) return;

      // Get current location
      final location = await _locationService.getCurrentLocation();
      if (location == null) return;

      // Update user location in Firestore
      await ref.read(userStateProvider.notifier).updateUserField(
            field: 'location',
            value: location.toJson(),
          );

      _hasUpdatedLocation = true;
      debugPrint('Location updated successfully: ${location.address}');
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }

  /// Reset the update flag (useful for testing)
  void resetUpdateFlag() {
    _hasUpdatedLocation = false;
  }
}
