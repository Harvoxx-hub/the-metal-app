import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/core/utils/constant/firebase.firestore.collection.key.dart';
import 'package:metal/features/notification/domain/entries/notification.model.dart';

class NotificationRepository {
  final FirebaseServiceDb _firebaseService = FirebaseServiceDb.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user's notification collection path
  String? get _userNotificationPath {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    return '${FirebaseFirestoreCollectionKeys.users}/$userId/${FirebaseFirestoreCollectionKeys.notification}';
  }

  /// Get all notifications for current user
  Future<Responses> getNotifications() async {
    try {
      final path = _userNotificationPath;
      if (path == null) {
        return Responses(
          success: false,
          message: "User not authenticated",
          data: [],
        );
      }

      final notifications = await _firebaseService.queryBuilderCollection(
        collectionPath: path,
        queryBuilder: (query) => query.orderBy('timestamp', descending: true),
      );

      return Responses(
        success: true,
        message: "Notifications fetched successfully",
        data: notifications,
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Failed to fetch notifications: ${e.toString()}",
        data: [],
      );
    }
  }

  /// Get notifications stream for real-time updates
  Stream<List<NotificationModel>> getNotificationsStream() {
    final path = _userNotificationPath;
    if (path == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection(path)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id;
              return NotificationModel.fromJson(data);
            } catch (e) {
              print('Error parsing notification: $e');
              return null;
            }
          })
          .where((notification) => notification != null)
          .cast<NotificationModel>()
          .toList();
    });
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final path = _userNotificationPath;
      if (path == null) return 0;

      final snapshot = await FirebaseFirestore.instance
          .collection(path)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  /// Get unread count stream for real-time updates
  Stream<int> getUnreadCountStream() {
    final path = _userNotificationPath;
    if (path == null) {
      return Stream.value(0);
    }

    return FirebaseFirestore.instance
        .collection(path)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final path = _userNotificationPath;
      if (path == null) return false;

      await _firebaseService.updateDocument(
        collectionPath: path,
        documentId: notificationId,
        data: {'isRead': true},
      );
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final path = _userNotificationPath;
      if (path == null) return false;

      final snapshot = await FirebaseFirestore.instance
          .collection(path)
          .where('isRead', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) return true;

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final path = _userNotificationPath;
      if (path == null) return false;

      await _firebaseService.deleteDocument(
        collectionPath: path,
        documentId: notificationId,
      );
      return true;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  /// Delete all notifications
  Future<bool> deleteAllNotifications() async {
    try {
      final path = _userNotificationPath;
      if (path == null) return false;

      final snapshot = await FirebaseFirestore.instance.collection(path).get();
      if (snapshot.docs.isEmpty) return true;

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error deleting all notifications: $e');
      return false;
    }
  }
}
