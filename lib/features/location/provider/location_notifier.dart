import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/base.state.dart';
import '../../../core/services/location_service.dart';
import '../../../features/authentication/domain/entries/user.model.dart';
import '../../../features/authentication/provider/user_state_notifier.dart';

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier(this.ref) : super(LocationState.initial());

  final Ref ref;
  final LocationService _locationService = LocationService();

  /// Update user location and save to backend
  Future<void> updateUserLocation() async {
    if (state.isLoading) return; // Prevent multiple simultaneous updates

    state = LocationState.loading();

    try {
      // Get current location
      final location = await _locationService.getCurrentLocation();

      if (location == null) {
        state = LocationState.error('Unable to get current location');
        return;
      }

      // Update user location in backend
      await ref.read(userStateProvider.notifier).updateUserField(
            field: 'location',
            value: location.toJson(),
          );

      state = LocationState.success(location);
    } catch (e) {
      state = LocationState.error('Failed to update location: ${e.toString()}');
    }
  }

  /// Check if location is available
  Future<bool> isLocationAvailable() async {
    return await _locationService.isLocationAvailable();
  }

  /// Get current location without updating backend
  Future<Location?> getCurrentLocation() async {
    return await _locationService.getCurrentLocation();
  }

  /// Clear error and reset to initial state
  void clearError() {
    state = LocationState.initial();
  }

  /// Reset state to initial
  void reset() {
    state = LocationState.initial();
  }
}

typedef LocationState = BaseState<Location>;

final locationNotifierProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier(ref);
});
