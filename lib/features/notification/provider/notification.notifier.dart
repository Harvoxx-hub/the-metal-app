import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/utils/constant/firebase.firestore.collection.key.dart';
import 'package:metal/features/notification/domain/entries/notification.model.dart';
import 'package:metal/features/notification/services/notification_service.dart';

class NotificationNotifier extends StateNotifier<List<NotificationModel>> {
  final NotificationService _notificationService;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot>? _notificationSubscription;

  NotificationNotifier(this._notificationService) : super([]) {
    _initializeNotificationListener();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  // Initialize real-time listener for notifications
  void _initializeNotificationListener() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _notificationSubscription?.cancel();

    final path =
        '${FirebaseFirestoreCollectionKeys.users}/$userId/${FirebaseFirestoreCollectionKeys.notification}';
    _notificationSubscription = FirebaseFirestore.instance
        .collection(path)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      final notifications = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return NotificationModel.fromJson(data);
      }).toList();
      state = notifications;
    });
  }

  // Fetch notifications when needed
  Future<void> fetchNotifications() async {
    final notifications = await _notificationService.getNotifications();
    state = notifications;
  }

  // Get unread notifications
  List<NotificationModel> get unreadNotifications =>
      state.where((notification) => !notification.isRead).toList();

  // Get unread count
  int get unreadCount => unreadNotifications.length;

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
    state = state.map((notification) {
      if (notification.id == notificationId) {
        return notification.markAsRead();
      }
      return notification;
    }).toList();
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
    state = state.map((notification) => notification.markAsRead()).toList();
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _notificationService.deleteNotification(notificationId);
    state = state
        .where((notification) => notification.id != notificationId)
        .toList();
  }

  // Handle user sign-in/sign-out
  void onAuthStateChanged(User? user) {
    if (user != null) {
      _initializeNotificationListener();
    } else {
      _notificationSubscription?.cancel();
      _notificationSubscription = null;
      state = [];
    }
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationModel>>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationNotifier(notificationService);
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationProvider);
  return notifications.where((notification) => !notification.isRead).length;
});
