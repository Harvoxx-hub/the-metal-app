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
    int limit = 30,
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
      int fetchLimit = limit * 3; // Fetch 3x more to account for filtering

      var query = _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.users)
          .where('id', isNotEqualTo: currentUserId)
          .where('isDeleted', isEqualTo: false)
          .where('showMyProfile', isEqualTo: true)
          .limit(fetchLimit);

      // Apply gender preference filter if set
      if (currentUserData.connectWith != null &&
          currentUserData.connectWith!.isNotEmpty) {
        // Handle multiple gender preferences (e.g., "Female,Others,Male")
        final genderPreferences =
            _parseGenderPreferences(currentUserData.connectWith!);

        if (genderPreferences.length == 1) {
          // Single gender preference - use exact match
          query = query.where('gender', isEqualTo: genderPreferences.first);
        } else if (genderPreferences.length > 1) {
          // Multiple gender preferences - use 'in' operator
          query = query.where('gender', whereIn: genderPreferences);
        }
      }

      // Apply age range filter if available
      if (currentUserData.preferences?.ageRange != null) {
        // Note: This would need to be implemented based on your age calculation logic
        // For now, we'll skip age filtering
      }

      final querySnapshot = await query.get();
      final allUsers = querySnapshot.docs.map((doc) => doc.data()).toList();

      // Filter out blocked, swiped, and connected users
      // add that metal is not null
      // add that profile is completed
      // a
      final filteredUsers = allUsers.where((user) {
        final userId = user['id'] as String?;
        return userId != null &&
            !blockedUserIds.contains(userId) &&
            !swipedUserIds.contains(userId) &&
            !connectedUserIds.contains(userId) &&
            user['metal'] != null &&
            user['completedProfile'] == true;
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
      if (swipeUsers.isEmpty && fetchLimit < 50) {
        // Try with a larger batch
        return await getSwipeUsers(limit: 50);
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

      // Filter out blocked, swiped, and connected users
      final filteredUsers = allUsers.where((user) {
        final userId = user['id'] as String?;
        return userId != null &&
            !blockedUserIds.contains(userId) &&
            !swipedUserIds.contains(userId) &&
            !connectedUserIds.contains(userId) &&
            user['metal'] != null &&
            user['completedProfile'] == true;
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
}

final swipeRepositoryProvider = Provider((ref) => SwipeRepository());
