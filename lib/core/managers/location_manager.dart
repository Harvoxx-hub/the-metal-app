import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/location_service.dart';
import '../../features/location/provider/location_notifier.dart';
import '../../features/authentication/provider/user_state_notifier.dart';

/// Manager for handling location updates on app startup
class LocationManager {
  static final LocationManager _instance = LocationManager._internal();
  factory LocationManager() => _instance;
  LocationManager._internal();

  final LocationService _locationService = LocationService();
  bool _hasUpdatedLocation = false;

  /// Update user location on app startup
  /// This should be called once when the app starts
  Future<void> updateLocationOnAppStart(WidgetRef ref) async {
    // Prevent multiple updates
    if (_hasUpdatedLocation) return;

    try {
      // Check if user is authenticated
      final user = ref.read(userStateProvider).data;
      if (user == null) {
        return;
      }

      // Check if location is available
      final isAvailable = await _locationService.isLocationAvailable();
      if (!isAvailable) {
        return;
      }

      // Update location using the notifier
      await ref.read(locationNotifierProvider.notifier).updateUserLocation();

      _hasUpdatedLocation = true;
    } catch (e) {
      // Log error but don't crash the app
      print('Error updating location on app start: $e');
    }
  }

  /// Reset the update flag (useful for testing or manual refresh)
  void resetUpdateFlag() {
    _hasUpdatedLocation = false;
  }

  /// Check if location has been updated
  bool get hasUpdatedLocation => _hasUpdatedLocation;
}
