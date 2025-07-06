import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/core/utils/constant/firebase.firestore.collection.key.dart';
import 'package:metal/features/notification/domain/entries/notification.model.dart';

/// Centralized service for notification state management
class NotificationStateService {
  static final NotificationStateService _instance =
      NotificationStateService._();
  static NotificationStateService get instance => _instance;

  NotificationStateService._();

  final FirebaseServiceDb _firebaseService = FirebaseServiceDb.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user's notification collection path
  String? get _userNotificationPath {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    return '${FirebaseFirestoreCollectionKeys.users}/$userId/${FirebaseFirestoreCollectionKeys.notification}';
  }

  /// Mark a single notification as read
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

  /// Mark multiple notifications as read
  Future<bool> markMultipleAsRead(List<String> notificationIds) async {
    try {
      final path = _userNotificationPath;
      if (path == null) return false;

      final batch = FirebaseFirestore.instance.batch();

      for (final id in notificationIds) {
        final docRef = FirebaseFirestore.instance.collection(path).doc(id);
        batch.update(docRef, {'isRead': true});
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error marking multiple notifications as read: $e');
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

  /// Delete a single notification
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

  /// Delete multiple notifications
  Future<bool> deleteMultipleNotifications(List<String> notificationIds) async {
    try {
      final path = _userNotificationPath;
      if (path == null) return false;

      final batch = FirebaseFirestore.instance.batch();

      for (final id in notificationIds) {
        final docRef = FirebaseFirestore.instance.collection(path).doc(id);
        batch.delete(docRef);
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error deleting multiple notifications: $e');
      return false;
    }
  }

  /// Clear all notifications
  Future<bool> clearAllNotifications() async {
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
      print('Error clearing all notifications: $e');
      return false;
    }
  }

  /// Get blocked users list for filtering
  Future<List<Map<String, dynamic>>> getBlockedUsers() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final blockedData = await _firebaseService.readCollection(
        collectionPath:
            '${FirebaseFirestoreCollectionKeys.users}/$userId/blocked',
      );

      return List<Map<String, dynamic>>.from(blockedData);
    } catch (e) {
      print('Error getting blocked users: $e');
      return [];
    }
  }

  /// Filter notifications to exclude blocked users
  List<NotificationModel> filterNotificationsFromBlockedUsers(
    List<NotificationModel> notifications,
    List<Map<String, dynamic>> blockedUsers,
  ) {
    if (blockedUsers.isEmpty) return notifications;

    final blockedUserIds = blockedUsers
        .map((user) => user['id'] as String?)
        .where((id) => id != null)
        .cast<String>()
        .toSet();

    return notifications.where((notification) {
      // For notifications that have a sender ID in the data
      if (notification.data != null && notification.data is Map) {
        final data = notification.data as Map;
        final senderId = data['senderId'] ?? data['userId'];
        if (senderId != null) {
          return !blockedUserIds.contains(senderId);
        }
      }
      return true; // Keep notifications without sender IDs
    }).toList();
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

  /// Create a real-time stream for notifications
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
              data['id'] = doc.id; // Ensure ID is set
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

  /// Get notifications with automatic filtering of blocked users
  Future<List<NotificationModel>> getFilteredNotifications() async {
    try {
      final notificationsStream = getNotificationsStream();
      final notifications = await notificationsStream.first;

      final blockedUsers = await getBlockedUsers();
      return filterNotificationsFromBlockedUsers(notifications, blockedUsers);
    } catch (e) {
      print('Error getting filtered notifications: $e');
      return [];
    }
  }
}

/// Provider for the notification state service
final notificationStateServiceProvider =
    Provider<NotificationStateService>((ref) {
  return NotificationStateService.instance;
});

/// Provider for unread notification count stream
final unreadNotificationCountStreamProvider = StreamProvider<int>((ref) async* {
  final service = ref.read(notificationStateServiceProvider);
  final path = service._userNotificationPath;

  if (path == null) {
    yield 0;
    return;
  }

  yield* FirebaseFirestore.instance
      .collection(path)
      .where('isRead', isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

/// Provider for notifications stream with blocked user filtering
final filteredNotificationsStreamProvider =
    StreamProvider<List<NotificationModel>>((ref) async* {
  final service = ref.read(notificationStateServiceProvider);

  await for (final notifications in service.getNotificationsStream()) {
    final blockedUsers = await service.getBlockedUsers();
    final filtered = service.filterNotificationsFromBlockedUsers(
        notifications, blockedUsers);
    yield filtered;
  }
});
