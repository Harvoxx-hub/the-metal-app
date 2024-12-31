import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/core/utils/constant/firebase.firestore.collection.key.dart';

import '../../domain/repositories/inotification_repository.dart';

class NotificationRepository implements INotificationRepository {
  final FirebaseServiceDb _firebaseService = FirebaseServiceDb.instance;

  @override
  Future<Responses> getNotification() async {
    try {
      User? user = _firebaseService.auth.currentUser;

      if (user == null) {
        // Handle the case when the user is not logged in
        return Responses(
          success: false,
          message: "User not authenticated.",
          data: [],
        );
      }

      String userId = user.uid;

      // Fetch notifications from the subcollection `notifications` under the user's document
      final notifications = await _firebaseService.readCollection(
        collectionPath:
            '${FirebaseFirestoreCollectionKeys.users}/$userId/${FirebaseFirestoreCollectionKeys.notification}',
      );

      if (notifications.isNotEmpty) {
        return Responses(
          success: true,
          message: "Notifications fetched successfully.",
          data: notifications,
        );
      } else {
        return Responses(
          success: true,
          message: "No notifications found.",
          data: [],
        );
      }
    } catch (e) {
      // Handle errors and return a meaningful response
      return Responses(
        success: false,
        message: "Failed to fetch notifications: ${e.toString()}",
        data: [],
      );
    }
  }
}

final notificationRepositoryProvider = Provider((ref) {
  return NotificationRepository();
});
