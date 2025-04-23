import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';

import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/core/utils/constant/firebase.firestore.collection.key.dart';
import 'package:metal/features/settings/domain/entries/block.reason.model.dart';

import '../../domain/repositories/isetting_repository.dart';

class SettingRepository implements ISettingRepository {
  final FirebaseServiceDb _firebaseService = FirebaseServiceDb.instance;

  @override
  Future<Responses> blockUser(String id, String userName) async {
    try {
      final userId = _firebaseService.userId;

      // Create block entry
      await _firebaseService.createDocument(
          documentId: id,
          collectionPath:
              '${FirebaseFirestoreCollectionKeys.users}/$userId/${FirebaseFirestoreCollectionKeys.blocked}',
          data: {
            "id": id,
            "name": userName,
            "blockedAt": DateTime.now().toIso8601String(),
          });

      // Check if a connection exists and update its status
      final connectionPath = '${FirebaseFirestoreCollectionKeys.connections}';

      // Use queryBuilderCollection for more complex queries
      final connections = await _firebaseService.queryBuilderCollection(
        collectionPath: connectionPath,
        queryBuilder: (query) => query
            .where("senderId", isEqualTo: userId)
            .where("receiverId", isEqualTo: id),
      );

      // Update sender's connection if it exists
      if (connections.isNotEmpty) {
        final connectionId = connections[0]['id'];
        await _firebaseService.updateDocument(
          collectionPath: connectionPath,
          documentId: connectionId,
          data: {"status": "blocked"},
        );
      }

      // Also check connection where user is the receiver
      final reverseConnections = await _firebaseService.queryBuilderCollection(
        collectionPath: connectionPath,
        queryBuilder: (query) => query
            .where("receiverId", isEqualTo: userId)
            .where("senderId", isEqualTo: id),
      );

      // Update receiver's connection if it exists
      if (reverseConnections.isNotEmpty) {
        final connectionId = reverseConnections[0]['id'];
        await _firebaseService.updateDocument(
          collectionPath: connectionPath,
          documentId: connectionId,
          data: {"status": "blocked"},
        );
      }

      return Responses(success: true, message: "User successfully blocked.");
    } catch (e) {
      return Responses(success: false, message: "Failed to block user: $e");
    }
  }

  @override
  Future<Responses> blockUserWithReason({
    required String id,
    required String userName,
    required String reasonCode,
    String? customReason,
    bool isReported = false,
    String? reportDetails,
  }) async {
    try {
      final userId = _firebaseService.userId;
      final timestamp = DateTime.now().toIso8601String();

      // First block the user normally
      await blockUser(id, userName);

      // Then add the block reason
      await _firebaseService.createDocument(
        documentId: '${userId}_${id}_$timestamp',
        collectionPath: '${FirebaseFirestoreCollectionKeys.blockReasons}',
        data: {
          "id": '${userId}_${id}_$timestamp',
          "userId": userId,
          "blockedUserId": id,
          "reasonCode": reasonCode,
          "customReason": customReason,
          "isReported": isReported,
          "reportDetails": reportDetails,
          "timestamp": timestamp,
        },
      );

      // If this is also a report, create a separate report entry for moderators
      if (isReported && reportDetails != null) {
        await _firebaseService.createDocument(
          documentId: '${userId}_${id}_$timestamp',
          collectionPath: '${FirebaseFirestoreCollectionKeys.reports}',
          data: {
            "id": '${userId}_${id}_$timestamp',
            "reporterId": userId,
            "reportedUserId": id,
            "reasonCode": reasonCode,
            "customReason": customReason,
            "reportDetails": reportDetails,
            "status": "pending",
            "timestamp": timestamp,
          },
        );
      }

      return Responses(
          success: true,
          message: isReported
              ? "User successfully blocked and reported."
              : "User successfully blocked.");
    } catch (e) {
      return Responses(
          success: false, message: "Failed to block user with reason: $e");
    }
  }

  @override
  Future<Responses> getBlockReasons(String blockedUserId) async {
    try {
      final userId = _firebaseService.userId;
      final reasons = await _firebaseService.queryBuilderCollection(
        collectionPath: '${FirebaseFirestoreCollectionKeys.blockReasons}',
        queryBuilder: (query) => query
            .where("userId", isEqualTo: userId)
            .where("blockedUserId", isEqualTo: blockedUserId)
            .orderBy("timestamp", descending: true),
      );
      return Responses(success: true, data: reasons);
    } catch (e) {
      return Responses(
          success: false, message: "Failed to fetch block reasons: $e");
    }
  }

  @override
  Future<Responses> updateBlockStatus({
    required String blockedUserId,
    required bool isTemporary,
    String? expiryDate,
  }) async {
    try {
      final userId = _firebaseService.userId;

      // Update block status in the blocked collection
      await _firebaseService.updateDocument(
        collectionPath:
            '${FirebaseFirestoreCollectionKeys.users}/$userId/${FirebaseFirestoreCollectionKeys.blocked}',
        documentId: blockedUserId,
        data: {
          "isTemporary": isTemporary,
          "expiryDate": expiryDate,
          "updatedAt": DateTime.now().toIso8601String(),
        },
      );

      return Responses(
          success: true, message: "Block status updated successfully.");
    } catch (e) {
      return Responses(
          success: false, message: "Failed to update block status: $e");
    }
  }

  @override
  Future<Responses> updateBlockPrivacySettings({
    required String blockedUserId,
    required Map<String, bool> privacySettings,
  }) async {
    try {
      final userId = _firebaseService.userId;

      await _firebaseService.updateDocument(
        collectionPath:
            '${FirebaseFirestoreCollectionKeys.users}/$userId/${FirebaseFirestoreCollectionKeys.blocked}',
        documentId: blockedUserId,
        data: {
          "privacySettings": privacySettings,
          "updatedAt": DateTime.now().toIso8601String(),
        },
      );

      return Responses(
          success: true,
          message: "Block privacy settings updated successfully.");
    } catch (e) {
      return Responses(
          success: false,
          message: "Failed to update block privacy settings: $e");
    }
  }

  @override
  Future<Responses> getBlockedUsers() async {
    try {
      final userId = _firebaseService.userId;
      final blockedUsers = await _firebaseService.readCollection(
        collectionPath:
            '${FirebaseFirestoreCollectionKeys.users}/$userId/${FirebaseFirestoreCollectionKeys.blocked}',
      );
      return Responses(success: true, data: blockedUsers);
    } catch (e) {
      return Responses(
          success: false, message: "Failed to fetch blocked users: $e");
    }
  }

  @override
  Future<Responses> unBlockUser(String id) async {
    try {
      final userId = _firebaseService.userId;

      // Delete the block document
      await _firebaseService.deleteDocument(
          collectionPath:
              '${FirebaseFirestoreCollectionKeys.users}/$userId/${FirebaseFirestoreCollectionKeys.blocked}',
          documentId: id);

      // Reset connection status if exists
      final connectionPath = '${FirebaseFirestoreCollectionKeys.connections}';

      // Check both directions of the connection
      final connections = await _firebaseService.queryBuilderCollection(
        collectionPath: connectionPath,
        queryBuilder: (query) => query
            .where("senderId", isEqualTo: userId)
            .where("receiverId", isEqualTo: id)
            .where("status", isEqualTo: "blocked"),
      );

      // Update sender's connection if it exists
      if (connections.isNotEmpty) {
        final connectionId = connections[0]['id'];
        await _firebaseService.updateDocument(
          collectionPath: connectionPath,
          documentId: connectionId,
          data: {"status": "accepted"},
        );
      }

      // Check reverse connection
      final reverseConnections = await _firebaseService.queryBuilderCollection(
        collectionPath: connectionPath,
        queryBuilder: (query) => query
            .where("receiverId", isEqualTo: userId)
            .where("senderId", isEqualTo: id)
            .where("status", isEqualTo: "blocked"),
      );

      // Update receiver's connection if it exists
      if (reverseConnections.isNotEmpty) {
        final connectionId = reverseConnections[0]['id'];
        await _firebaseService.updateDocument(
          collectionPath: connectionPath,
          documentId: connectionId,
          data: {"status": "accepted"},
        );
      }

      return Responses(success: true, message: "User successfully unblocked.");
    } catch (e) {
      return Responses(success: false, message: "Failed to unblock user: $e");
    }
  }
}

final settingRepositoryProvider = Provider((ref) {
  return SettingRepository();
});
