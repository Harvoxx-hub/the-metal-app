import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/core/utils/constant/firebase.firestore.collection.key.dart';
import 'package:metal/features/notification/domain/entries/notification.model.dart';

class NotificationService {
  final FirebaseServiceDb _firebaseService = FirebaseServiceDb.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user notifications
  Future<List<NotificationModel>> getNotifications() async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final notificationsData = await _firebaseService.queryBuilderCollection(
      collectionPath:
          '${FirebaseFirestoreCollectionKeys.users}/$userId/${FirebaseFirestoreCollectionKeys.notification}',
      queryBuilder: (query) => query.orderBy('timestamp', descending: true),
    );

    return notificationsData
        .map((data) => NotificationModel.fromJson(data))
        .toList();
  }

  // Get unread notification count
  Future<int> getUnreadCount() async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) return 0;

    final unreadCount = await _firebaseService.queryBuilderCollection(
      collectionPath:
          '${FirebaseFirestoreCollectionKeys.users}/$userId/${FirebaseFirestoreCollectionKeys.notification}',
      queryBuilder: (query) => query.where('isRead', isEqualTo: false),
    );

    return unreadCount.length;
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firebaseService.updateDocument(
      collectionPath:
          '${FirebaseFirestoreCollectionKeys.users}/$userId/${FirebaseFirestoreCollectionKeys.notification}',
      documentId: notificationId,
      data: {'isRead': true},
    );
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final batch = FirebaseFirestore.instance.batch();
    final notifications = await _firebaseService.queryBuilderCollection(
      collectionPath:
          '${FirebaseFirestoreCollectionKeys.users}/$userId/${FirebaseFirestoreCollectionKeys.notification}',
      queryBuilder: (query) => query.where('isRead', isEqualTo: false),
    );

    for (final notification in notifications) {
      final docRef = FirebaseFirestore.instance
          .collection(
              '${FirebaseFirestoreCollectionKeys.users}/$userId/${FirebaseFirestoreCollectionKeys.notification}')
          .doc(notification['id']);

      batch.update(docRef, {'isRead': true});
    }

    await batch.commit();
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firebaseService.deleteDocument(
      collectionPath:
          '${FirebaseFirestoreCollectionKeys.users}/$userId/${FirebaseFirestoreCollectionKeys.notification}',
      documentId: notificationId,
    );
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
