import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/core/utils/constant/firebase.firestore.collection.key.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/home_page/data/domain/repositories/iswipe_repository.dart';
import 'package:metal/features/thought/data/domain/entries/melt.request.model.dart';

class SwipeRepository implements ISwipeRepository {
  final FirebaseServiceDb _firebaseService = FirebaseServiceDb.instance;

  @override
  Future<Responses> getSwipeUsers({
    String? lastUserId,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return Responses(
          success: false,
          message: "User not authenticated",
        );
      }

      final currentUserId = currentUser.uid;

      // Get current user's data to apply filters
      final currentUserResponse = await _firebaseService.readDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.users,
        documentId: currentUserId,
      );

      if (currentUserResponse == null) {
        return Responses(
          success: false,
          message: "Current user data not found",
        );
      }

      final currentUserData = UserModel.fromJson(currentUserResponse);

      // Get blocked users
      final blockedUsers = await _firebaseService.readCollection(
        collectionPath: "users/$currentUserId/blocked",
      );
      final blockedUserIds = blockedUsers.map((doc) => doc['id']).toList();

      // Get already swiped users
      final swipedUsers = await _firebaseService.readCollection(
        collectionPath: "users/$currentUserId/swipes",
      );
      final swipedUserIds =
          swipedUsers.map((doc) => doc['targetUserId']).toList();

      // Get connected users from the connections collection
      final connections = await _firebaseService.queryBuilderCollection(
        collectionPath: FirebaseFirestoreCollectionKeys.connections,
        queryBuilder: (query) {
          return query.where('users', arrayContains: currentUserId);
        },
      );

      // Extract the other user IDs from connections
      final connectedUserIds = <String>[];
      for (var connection in connections) {
        final users = connection['users'] as List<dynamic>?;
        if (users != null) {
          for (var userId in users) {
            if (userId != currentUserId) {
              connectedUserIds.add(userId.toString());
            }
          }
        }
      }

      // Build query to get users for swiping
      // Use a larger limit to account for filtering

      var query = _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.users)
          .where('id', isNotEqualTo: currentUserId)
          .where('isDeleted', isEqualTo: false)
          .where('showMyProfile', isEqualTo: true);

      // Note: Gender preference filtering is now handled in client-side filtering
      // to support bidirectional matching (both users must want each other's gender)

      final querySnapshot = await query.get();
      final allUsers = querySnapshot.docs.map((doc) => doc.data()).toList();

      // Filter out blocked, swiped, and connected users
      // add that metal is not null
      // add that profile is completed
      // add location requirement (must have location data)
      // add bidirectional gender preference filtering
      // add age range filtering
      final filteredUsers = allUsers.where((user) {
        final userId = user['id'] as String?;
        if (userId == null ||
            blockedUserIds.contains(userId) ||
            swipedUserIds.contains(userId) ||
            connectedUserIds.contains(userId) ||
            user['metal'] == null ||
            user['completedProfile'] != true) {
          return false;
        }

        // Require location data - filter out users without location
        final userLocation = user['location'] as Map<String, dynamic>?;
        if (userLocation == null ||
            userLocation['lat'] == null ||
            userLocation['lng'] == null) {
          return false; // Skip users without location data
        }

        // Apply bidirectional gender preference filtering
        if (!_isGenderPreferenceMatch(currentUserData, user)) {
          return false;
        }

        // Apply age range filtering
        if (!_isAgeInRange(currentUserData, user)) {
          return false;
        }

        // Apply demographic filtering
        if (!_isDemographyMatch(currentUserData, user)) {
          return false;
        }

        // Apply distance filtering
        if (!_isWithinDistanceRange(currentUserData, user)) {
          return false;
        }

        return true;
      }).toList();

      // Sort by most recent lastActive only (descending)
      filteredUsers.sort((a, b) {
        final String? aLast = a['lastActive'] as String?;
        final String? bLast = b['lastActive'] as String?;
        final DateTime aDt = DateTime.tryParse(aLast ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final DateTime bDt = DateTime.tryParse(bLast ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bDt.compareTo(aDt); // newer first
      });

      // Convert to UserModel
      final swipeUsers =
          filteredUsers.map((user) => UserModel.fromJson(user)).toList();

      // If we still have no users after filtering, try to get more
      if (swipeUsers.isEmpty) {
        // Try with a larger batch
        //    return await getSwipeUsers( );
      }

      return Responses(
        success: true,
        message: swipeUsers.isEmpty
            ? "No more users available to swipe"
            : "Swipe users retrieved successfully",
        data: swipeUsers,
      );
    } catch (e) {
      print(e);

      return Responses(
        success: false,
        message: "Failed to get swipe users: $e",
      );
    }
  }

  @override
  Future<Responses> getMoreSwipeUsers({
    required String lastUserId,
    int limit = 6,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return Responses(
          success: false,
          message: "User not authenticated",
        );
      }

      final currentUserId = currentUser.uid;

      // Get blocked users
      final blockedUsers = await _firebaseService.readCollection(
        collectionPath: "users/$currentUserId/blocked",
      );
      final blockedUserIds = blockedUsers.map((doc) => doc['id']).toList();

      // Get already swiped users
      final swipedUsers = await _firebaseService.readCollection(
        collectionPath: "users/$currentUserId/swipes",
      );
      final swipedUserIds =
          swipedUsers.map((doc) => doc['targetUserId']).toList();

      // Get connected users from the connections collection
      final connections = await _firebaseService.queryBuilderCollection(
        collectionPath: FirebaseFirestoreCollectionKeys.connections,
        queryBuilder: (query) {
          return query.where('users', arrayContains: currentUserId);
        },
      );

      // Extract the other user IDs from connections
      final connectedUserIds = <String>[];
      for (var connection in connections) {
        final users = connection['users'] as List<dynamic>?;
        if (users != null) {
          for (var userId in users) {
            if (userId != currentUserId) {
              connectedUserIds.add(userId.toString());
            }
          }
        }
      }

      // Build query with pagination
      var query = _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.users)
          .where('id', isNotEqualTo: currentUserId)
          .where('isDeleted', isEqualTo: false)
          .where('showMyProfile', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .startAfter([lastUserId]).limit(limit);

      final querySnapshot = await query.get();
      final allUsers = querySnapshot.docs.map((doc) => doc.data()).toList();

      // Get current user's data to apply bidirectional gender filtering
      final currentUserResponse = await _firebaseService.readDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.users,
        documentId: currentUserId,
      );

      if (currentUserResponse == null) {
        return Responses(
          success: false,
          message: "Current user data not found",
        );
      }

      final currentUserData = UserModel.fromJson(currentUserResponse);

      // Filter out blocked, swiped, and connected users
      // add location requirement (must have location data)
      // add bidirectional gender preference filtering
      // add age range filtering
      final filteredUsers = allUsers.where((user) {
        final userId = user['id'] as String?;
        if (userId == null ||
            blockedUserIds.contains(userId) ||
            swipedUserIds.contains(userId) ||
            connectedUserIds.contains(userId) ||
            user['metal'] == null ||
            user['completedProfile'] != true) {
          return false;
        }

        // Require location data - filter out users without location
        final userLocation = user['location'] as Map<String, dynamic>?;
        if (userLocation == null ||
            userLocation['lat'] == null ||
            userLocation['lng'] == null) {
          return false; // Skip users without location data
        }

        // Apply bidirectional gender preference filtering
        if (!_isGenderPreferenceMatch(currentUserData, user)) {
          return false;
        }

        // Apply age range filtering
        if (!_isAgeInRange(currentUserData, user)) {
          return false;
        }

        // Apply demographic filtering
        if (!_isDemographyMatch(currentUserData, user)) {
          return false;
        }

        // Apply distance filtering
        if (!_isWithinDistanceRange(currentUserData, user)) {
          return false;
        }

        return true;
      }).toList();

      // Sort by most recent lastActive only (descending)
      filteredUsers.sort((a, b) {
        final String? aLast = a['lastActive'] as String?;
        final String? bLast = b['lastActive'] as String?;
        final DateTime aDt = DateTime.tryParse(aLast ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final DateTime bDt = DateTime.tryParse(bLast ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bDt.compareTo(aDt); // newer first
      });

      // Convert to UserModel
      final swipeUsers =
          filteredUsers.map((user) => UserModel.fromJson(user)).toList();

      return Responses(
        success: true,
        message: swipeUsers.isEmpty
            ? "No more users available to swipe"
            : "More swipe users retrieved successfully",
        data: swipeUsers,
      );
    } catch (e) {
      print(e);
      return Responses(
        success: false,
        message: "Failed to get more swipe users: $e",
      );
    }
  }

  @override
  Future<Responses> recordSwipeAction({
    required String targetUserId,
    required SwipeAction action,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return Responses(
          success: false,
          message: "User not authenticated",
        );
      }

      final currentUserId = currentUser.uid;
      final now = DateTime.now().toIso8601String();

      // Record the swipe action in user's swipes subcollection
      await _firebaseService.createDocument(
        collectionPath: "users/$currentUserId/swipes",
        data: {
          'targetUserId': targetUserId,
          'action': action.name,
          'timestamp': now,
          'createdAt': now,
        },
      );

      // For likes and super likes, also create a melt request
      // This will trigger the cloud function to check for mutual likes
      if (action == SwipeAction.like || action == SwipeAction.superLike) {
        final meltRequest = MeltRequestModel(
          requesterId: currentUserId,
          recipientId: targetUserId,
          isAnonymous: true,
          createdAt: now,
          senderId: currentUserId,
        );

        await _firebaseService.createDocument(
          collectionPath: FirebaseFirestoreCollectionKeys.meltRequests,
          data: meltRequest.toJson(),
        );
      }

      return Responses(
        success: true,
        message: "Swipe action recorded successfully",
        data: {'action': action.name, 'targetUserId': targetUserId},
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Failed to record swipe action: $e",
      );
    }
  }

  @override
  Future<Responses> getSwipeHistory() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return Responses(
          success: false,
          message: "User not authenticated",
        );
      }

      final currentUserId = currentUser.uid;

      final swipes = await _firebaseService.readCollection(
        collectionPath: "users/$currentUserId/swipes",
      );

      return Responses(
        success: true,
        message: "Swipe history retrieved successfully",
        data: swipes,
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Failed to get swipe history: $e",
      );
    }
  }

  /// Parse gender preferences from comma-separated string
  /// Handles formats like: "Female", "Male", "Female,Others,Male"
  List<String> _parseGenderPreferences(String connectWith) {
    return connectWith
        .split(',')
        .map((gender) => gender.trim())
        .where((gender) => gender.isNotEmpty)
        .toList();
  }

  /// Check if there's a bidirectional gender preference match
  /// Both users must want to connect with each other's gender
  bool _isGenderPreferenceMatch(
      UserModel currentUser, Map<String, dynamic> targetUser) {
    // Get current user's gender and preferences
    final currentUserGender = currentUser.gender;
    final currentUserConnectWith = currentUser.connectWith;

    // Get target user's gender and preferences
    final targetUserGender = targetUser['gender'] as String?;
    final targetUserConnectWith = targetUser['connectWith'] as String?;

    // If any required data is missing, don't match
    if (currentUserGender == null ||
        targetUserGender == null ||
        currentUserConnectWith == null ||
        targetUserConnectWith == null) {
      return false;
    }

    // Parse preferences for both users
    final currentUserPreferences =
        _parseGenderPreferences(currentUserConnectWith);
    final targetUserPreferences =
        _parseGenderPreferences(targetUserConnectWith);

    // Check bidirectional match:
    // 1. Current user wants to connect with target user's gender
    // 2. Target user wants to connect with current user's gender
    final currentUserWantsTargetGender =
        currentUserPreferences.contains(targetUserGender);
    final targetUserWantsCurrentGender =
        targetUserPreferences.contains(currentUserGender);

    return currentUserWantsTargetGender && targetUserWantsCurrentGender;
  }

  /// Check if target user's age is within current user's age preference range
  bool _isAgeInRange(UserModel currentUser, Map<String, dynamic> targetUser) {
    // If no age preference is set, allow all ages
    final ageRange = currentUser.preferences?.ageRange;
    if (ageRange == null || ageRange.isEmpty) {
      return true;
    }

    // Parse age range (e.g., "25 - 30 years", "26-35", "36-45", "46+")
    final ageLimits = _parseAgeRange(ageRange);
    if (ageLimits == null) {
      print('Failed to parse age range: $ageRange');
      return true; // If parsing fails, allow all ages
    }

    // Get target user's age
    final targetUserAge = _calculateAge(targetUser['dob'] as String?);
    if (targetUserAge == null) {
      return true; // If age can't be calculated, allow
    }

    // Check if age is within range
    final isInRange = targetUserAge >= ageLimits['min']! &&
        targetUserAge <= ageLimits['max']!;

    if (!isInRange) {
      print(
          'Age filter: User ${targetUser['id']} age $targetUserAge not in range ${ageLimits['min']}-${ageLimits['max']}');
    }

    return isInRange;
  }

  /// Parse age range string into min and max values
  Map<String, int>? _parseAgeRange(String ageRange) {
    try {
      // Clean the string - remove "years" and extra spaces
      final cleanRange = ageRange.toLowerCase().replaceAll('years', '').trim();

      if (cleanRange.contains('+')) {
        // Handle "46+" format
        final minAge = int.parse(cleanRange.replaceAll('+', ''));
        return {'min': minAge, 'max': 100}; // Cap at 100 for practical purposes
      } else if (cleanRange.contains('-')) {
        // Handle "25 - 30" or "25-30" format
        final parts = cleanRange.split('-');
        if (parts.length == 2) {
          final minAge = int.parse(parts[0].trim());
          final maxAge = int.parse(parts[1].trim());
          return {'min': minAge, 'max': maxAge};
        }
      } else {
        // Handle single age (e.g., "25")
        final age = int.parse(cleanRange.trim());
        return {'min': age, 'max': age};
      }
    } catch (e) {
      print('Error parsing age range: $ageRange, error: $e');
    }
    return null;
  }

  /// Calculate age from date of birth string
  int? _calculateAge(String? dob) {
    if (dob == null || dob.isEmpty) return null;

    try {
      DateTime birthDate;

      // Handle different date formats
      if (dob.contains('/')) {
        // Handle DD/MM/YYYY format (e.g., "21/10/2003")
        final parts = dob.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          birthDate = DateTime(year, month, day);
        } else {
          throw FormatException('Invalid date format: $dob');
        }
      } else {
        // Handle ISO format (e.g., "2003-10-21")
        birthDate = DateTime.parse(dob);
      }

      final now = DateTime.now();
      int age = now.year - birthDate.year;

      // Adjust if birthday hasn't occurred this year
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }

      return age;
    } catch (e) {
      print('Error calculating age from DOB: $dob, error: $e');
      return null;
    }
  }

  /// Check if target user is within current user's maximum distance preference
  bool _isWithinDistanceRange(
      UserModel currentUser, Map<String, dynamic> targetUser) {
    // If distance filtering is disabled, allow all distances
    if (currentUser.enableDistanceFilter == false) {
      return true;
    }

    // If no distance preference is set, allow all distances
    final distancePreference = currentUser.distance;
    if (distancePreference == null || distancePreference.isEmpty) {
      return true;
    }

    // Parse maximum distance (e.g., "50 km" or "50")
    double? maxDistanceKm;
    try {
      final distanceStr = distancePreference.replaceAll(RegExp(r'[^0-9.]'), '');
      maxDistanceKm = double.tryParse(distanceStr);
    } catch (e) {
      print(
          'Error parsing distance preference: $distancePreference, error: $e');
      return true; // If parsing fails, allow all distances
    }

    if (maxDistanceKm == null) {
      return true; // If no valid distance found, allow all
    }

    // Get locations
    final currentUserLocation = currentUser.location;
    final targetUserLocation = targetUser['location'] as Map<String, dynamic>?;

    // If either user has no location data, allow (can't filter by distance)
    if (currentUserLocation?.lat == null ||
        currentUserLocation?.lng == null ||
        targetUserLocation == null ||
        targetUserLocation['lat'] == null ||
        targetUserLocation['lng'] == null) {
      return true; // Allow users without location data
    }

    // Calculate distance
    final distance = _calculateDistance(
      currentUserLocation!.lat!,
      currentUserLocation.lng!,
      (targetUserLocation['lat'] as num).toDouble(),
      (targetUserLocation['lng'] as num).toDouble(),
    );

    print('Distance: $distance');
    print('Max Distance: $maxDistanceKm');
    // Check if within range
    return distance <= maxDistanceKm;
  }

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Check if target user's location matches current user's demographic preference
  bool _isDemographyMatch(
      UserModel currentUser, Map<String, dynamic> targetUser) {
    // Get current user's demographic preference
    final demographyPreference = currentUser.preferences?.demography;

    // If no demographic preference is set, allow all
    if (demographyPreference == null || demographyPreference.isEmpty) {
      return true;
    }

    // If preference is "Anywhere in the world", allow all
    if (demographyPreference.toLowerCase() == 'anywhere in the world') {
      return true;
    }

    // Get target user's location
    final targetUserLocation = targetUser['location'] as Map<String, dynamic>?;

    // If target user has no location data, allow (can't filter by demography)
    if (targetUserLocation == null ||
        targetUserLocation['lat'] == null ||
        targetUserLocation['lng'] == null) {
      return true;
    }

    // Get continent from target user's location
    final targetLat = (targetUserLocation['lat'] as num).toDouble();
    final targetLng = (targetUserLocation['lng'] as num).toDouble();
    final targetContinent = _getContinentFromLatLng(targetLat, targetLng);

    // If we can't determine continent, allow
    if (targetContinent == null) {
      return true;
    }

    // Check if continent matches demographic preference
    return _isContinentMatch(targetContinent, demographyPreference);
  }

  /// Returns the continent name for a given lat/lng, or null if unknown
  String? _getContinentFromLatLng(double lat, double lng) {
    // Simple bounding box approach for major continents
    if (lat >= -35 && lat <= 37 && lng >= -20 && lng <= 52) return 'Africa';
    if (lat >= 1 && lat <= 77 && lng >= 26 && lng <= 180) return 'Asia';
    if (lat >= 7 && lat <= 83 && lng >= -168 && lng <= -52)
      return 'North America';
    if (lat >= -56 && lat <= 13 && lng >= -81 && lng <= -34)
      return 'South America';
    if (lat >= 34 && lat <= 72 && lng >= -25 && lng <= 60) return 'Europe';
    if (lat >= -50 && lat <= -10 && lng >= 110 && lng <= 180)
      return 'Australia';
    if (lat <= -60) return 'Antarctica';
    return null;
  }

  /// Returns true if the continent matches the demographic preference
  bool _isContinentMatch(String continent, String demographyPreference) {
    return continent.toLowerCase() == demographyPreference.toLowerCase();
  }
}

final swipeRepositoryProvider = Provider((ref) => SwipeRepository());
