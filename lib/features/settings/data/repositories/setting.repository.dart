import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';

import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/core/utils/constant/firebase.firestore.collection.key.dart';

import '../../domain/repositories/isetting_repository.dart';

class SettingRepository implements ISettingRepository {
  final FirebaseServiceDb _firebaseService = FirebaseServiceDb.instance;

  @override
  Future<Responses> blockUser(String id, String userName) async {
    try {
      final userId = _firebaseService.userId;
      await _firebaseService.createDocument(
          documentId: id,
          collectionPath:
              '${FirebaseFirestoreCollectionKeys.users}/$userId/${FirebaseFirestoreCollectionKeys.blocked}',
          data: {
            "id": id,
            "name": userName,
            "blockedAt": DateTime.now().toIso8601String(),
          });

      return Responses(success: true, message: "User successfully blocked.");
    } catch (e) {
      return Responses(success: false, message: "Failed to block user: $e");
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
      await _firebaseService.deleteDocument(
          collectionPath:
              '${FirebaseFirestoreCollectionKeys.users}/$userId/${FirebaseFirestoreCollectionKeys.blocked}',
          documentId: id);

      return Responses(success: true, message: "User successfully unblocked.");
    } catch (e) {
      return Responses(success: false, message: "Failed to unblock user: $e");
    }
  }
}

final settingRepositoryProvider = Provider((ref) {
  return SettingRepository();
});
