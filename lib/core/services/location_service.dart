import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geocoding/geocoding.dart' as geo_coding;

import '../../features/authentication/domain/entries/user.model.dart';

/// Service for handling all location-related operations
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await geo.Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('Error checking location service: $e');
      return false;
    }
  }

  /// Check location permission status
  Future<geo.LocationPermission> getLocationPermission() async {
    try {
      return await geo.Geolocator.checkPermission();
    } catch (e) {
      debugPrint('Error checking location permission: $e');
      return geo.LocationPermission.denied;
    }
  }

  /// Request location permission
  Future<geo.LocationPermission> requestLocationPermission() async {
    try {
      return await geo.Geolocator.requestPermission();
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return geo.LocationPermission.denied;
    }
  }

  /// Get current position with timeout
  Future<geo.Position?> getCurrentPosition({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      return await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
        timeLimit: timeout,
      );
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return null;
    }
  }

  /// Get address from coordinates with fallback strategy
  Future<String> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await geo_coding.placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        debugPrint(
            'No placemarks found for coordinates: $latitude, $longitude');
        return _getFallbackAddress();
      }

      final place = placemarks.first;

      // Try different combinations for better address formatting
      if (place.locality != null && place.country != null) {
        return "${place.locality}, ${place.country}";
      } else if (place.administrativeArea != null && place.country != null) {
        return "${place.administrativeArea}, ${place.country}";
      } else if (place.country != null) {
        return place.country!;
      } else if (place.locality != null) {
        return place.locality!;
      } else {
        debugPrint(
            'Placemark fields are null for coordinates: $latitude, $longitude');
        return _getFallbackAddress();
      }
    } catch (e) {
      debugPrint('Error getting address from coordinates: $e');
      return _getFallbackAddress();
    }
  }

  /// Get fallback address based on platform
  String _getFallbackAddress() {
    if (Platform.isAndroid) {
      return "Location not available";
    } else if (Platform.isIOS) {
      return "Location not available";
    } else {
      return "Location not available";
    }
  }

  /// Get complete location data (coordinates + address)
  Future<Location?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return null;
      }

      // Check permission
      var permission = await getLocationPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await requestLocationPermission();
      }

      if (permission == geo.LocationPermission.denied ||
          permission == geo.LocationPermission.deniedForever) {
        debugPrint('Location permission denied');
        return null;
      }

      // Get current position
      final position = await getCurrentPosition();
      if (position == null) {
        debugPrint('Failed to get current position');
        return null;
      }

      // Get address from coordinates
      final address = await getAddressFromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return Location(
        lat: position.latitude,
        lng: position.longitude,
        address: address,
      );
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    final permission = await getLocationPermission();
   
    if (permission == geo.LocationPermission.denied) {
      await requestLocationPermission();
      return false;
    }
    return permission == geo.LocationPermission.whileInUse ||
        permission == geo.LocationPermission.always;
  }

  /// Check if location services are available and permission is granted
  Future<bool> isLocationAvailable() async {
    final serviceEnabled = await isLocationServiceEnabled();
    final hasPermission = await hasLocationPermission();
    return serviceEnabled && hasPermission;
  }
}
