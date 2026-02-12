import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' hide Location;

import '../../data/models/user_location_model.dart';
import '../utils/permission_helper.dart';

/// Result class for location service operations
class LocationResult {
  final UserLocationModel? location;
  final bool permissionDenied;
  final bool serviceDisabled;
  final String? errorMessage;

  LocationResult({
    this.location,
    this.permissionDenied = false,
    this.serviceDisabled = false,
    this.errorMessage,
  });

  bool get isSuccess => location != null;
  bool get needsPermission => permissionDenied || serviceDisabled;
}

/// Simple and clean location service
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Get current location with address
  /// Returns LocationResult with location data and permission status
  Future<LocationResult> getCurrentLocation() async {
    try {
      // Check if location service is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location service is disabled');
        return LocationResult(
          serviceDisabled: true,
          errorMessage:
              'Location services are disabled. Please enable location services.',
        );
      }

      // Check permissions
      final permissionResult = await _checkLocationPermission();
      if (!permissionResult['granted']) {
        debugPrint('Location permission not granted');
        return LocationResult(
          permissionDenied: true,
          errorMessage: permissionResult['message'] as String? ??
              'Location permission not granted',
        );
      }

      // Get coordinates
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Get address details from coordinates
      final addressDetails = await _getAddressDetailsFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return LocationResult(
        location: UserLocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
          address: addressDetails['address'],
          city: addressDetails['city'],
          state: addressDetails['state'],
          country: addressDetails['country'],
        ),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return LocationResult(
        errorMessage: 'Failed to get location: $e',
      );
    }
  }

  /// Check location permission using permission_handler (single source of truth).
  /// Returns a map with 'granted' boolean and optional 'message'.
  Future<Map<String, dynamic>> _checkLocationPermission() async {
    final result = await PermissionHelper.requestLocationPermission();

    if (result.granted) {
      return {'granted': true};
    }
    if (result.permanentlyDenied) {
      return {
        'granted': false,
        'message':
            'Location permission is permanently denied. Please enable it in app settings.',
      };
    }
    return {
      'granted': false,
      'message':
          'Location permission is denied. Please enable location permission in settings.',
    };
  }

  /// Convert coordinates to address details
  /// Returns a map with address string, city, state, and country
  Future<Map<String, String?>> _getAddressDetailsFromCoordinates(
      double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isEmpty) {
        return {
          'address': 'Location not available',
          'city': null,
          'state': null,
          'country': null,
        };
      }

      final place = placemarks.first;

      // Extract individual components
      final city = place.locality;
      final state = place.administrativeArea;
      final country = place.country;

      // Build address string with city, state, and country
      final parts = <String>[];

      // Add city if available
      if (city != null && city.isNotEmpty) {
        parts.add(city);
      }

      // Add state if available
      if (state != null && state.isNotEmpty) {
        parts.add(state);
      }

      // Add country if available
      if (country != null && country.isNotEmpty) {
        parts.add(country);
      }

      final address =
          parts.isEmpty ? 'Location not available' : parts.join(', ');

      return {
        'address': address,
        'city': city,
        'state': state,
        'country': country,
      };
    } catch (e) {
      debugPrint('Error getting address: $e');
      return {
        'address': 'Location not available',
        'city': null,
        'state': null,
        'country': null,
      };
    }
  }
}
