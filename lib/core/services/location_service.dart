import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' hide Location;

import '../../features/authentication/domain/entries/user.model.dart';

/// Simple and clean location service
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Get current location with address
  Future<Location?> getCurrentLocation() async {
    try {
      // Check permissions
      if (!await _hasLocationPermission()) {
        debugPrint('Location permission not granted');
        return null;
      }

      // Get coordinates
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Get address from coordinates
      final address = await _getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return Location(
        lat: position.latitude,
        lng: position.longitude,
        address: address,
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// Check if location permission is granted
  Future<bool> _hasLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Convert coordinates to address
  Future<String> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isEmpty) {
        return 'Location not available';
      }

      final place = placemarks.first;

      // Build address from available fields
      final parts = <String>[];

      if (place.street != null && place.street!.isNotEmpty) {
        parts.add(place.street!);
      }
      if (place.locality != null && place.locality!.isNotEmpty) {
        parts.add(place.locality!);
      }
      if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty) {
        parts.add(place.administrativeArea!);
      }
      if (place.country != null && place.country!.isNotEmpty) {
        parts.add(place.country!);
      }

      return parts.isEmpty ? 'Location not available' : parts.join(', ');
    } catch (e) {
      debugPrint('Error getting address: $e');
      return 'Location not available';
    }
  }
}
