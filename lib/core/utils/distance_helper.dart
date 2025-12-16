import 'dart:math';
import '../../features/authentication/domain/entries/user.model.dart';

/// Lightweight distance calculation utility for sorting users by proximity
class DistanceHelper {
  /// Earth's radius in kilometers
  static const double _earthRadiusKm = 6371.0;

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Calculate distance from current user to another user
  /// Returns distance in kilometers, or double.infinity if location data is missing
  static double getDistanceFromCurrentUser(
    UserModel? currentUser,
    UserModel targetUser,
  ) {
    if (currentUser?.location?.lat == null ||
        currentUser?.location?.lng == null ||
        targetUser.location?.lat == null ||
        targetUser.location?.lng == null) {
      return double.infinity; // No location data, put at end
    }

    return calculateDistance(
      currentUser!.location!.lat!,
      currentUser.location!.lng!,
      targetUser.location!.lat!,
      targetUser.location!.lng!,
    );
  }

  /// Sort users by distance from current user (closest first)
  /// Users without location data are placed at the end
  static List<UserModel> sortUsersByDistance(
    List<UserModel> users,
    UserModel? currentUser,
  ) {
    if (currentUser?.location?.lat == null ||
        currentUser?.location?.lng == null) {
      // No current user location, return unsorted
      return users;
    }

    // Create a copy to avoid mutating the original list
    final sortedUsers = List<UserModel>.from(users);

    // Sort by distance
    sortedUsers.sort((a, b) {
      final distanceA = getDistanceFromCurrentUser(currentUser, a);
      final distanceB = getDistanceFromCurrentUser(currentUser, b);
      return distanceA.compareTo(distanceB);
    });

    return sortedUsers;
  }
}
