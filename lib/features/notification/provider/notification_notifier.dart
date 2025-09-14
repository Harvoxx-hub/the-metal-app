import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/base.state.dart';
import '../data/repositories/notification_repository.dart';
import '../domain/entries/notification.model.dart';

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier(this.ref) : super(NotificationState.initial()) {
    _repository = NotificationRepository();
  }

  final Ref ref;
  late final NotificationRepository _repository;

  /// Get notifications
  Future<void> getNotifications() async {
    state = NotificationState.loading();

    try {
      final response = await _repository.getNotifications();

      if (response.success!) {
        final notifications = (response.data as List)
            .map((data) => NotificationModel.fromJson(data))
            .toList();
        state = NotificationState.success(notifications);
      } else {
        state = NotificationState.error(
            response.message ?? 'Failed to fetch notifications');
      }
    } catch (e) {
      state = NotificationState.error(
          'Failed to fetch notifications: ${e.toString()}');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await _repository.markAsRead(notificationId);
      if (success && state.isSuccess) {
        // Update the notification in the current state
        final notifications = List<NotificationModel>.from(state.data!);
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(isRead: true);
          state = NotificationState.success(notifications);
        }
      }
    } catch (e) {
      state = NotificationState.error(
          'Failed to mark notification as read: ${e.toString()}');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final success = await _repository.markAllAsRead();
      if (success && state.isSuccess) {
        // Update all notifications in the current state
        final notifications =
            state.data!.map((n) => n.copyWith(isRead: true)).toList();
        state = NotificationState.success(notifications);
      }
    } catch (e) {
      state = NotificationState.error(
          'Failed to mark all notifications as read: ${e.toString()}');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final success = await _repository.deleteNotification(notificationId);
      if (success && state.isSuccess) {
        // Remove the notification from the current state
        final notifications =
            state.data!.where((n) => n.id != notificationId).toList();
        state = NotificationState.success(notifications);
      }
    } catch (e) {
      state = NotificationState.error(
          'Failed to delete notification: ${e.toString()}');
    }
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    try {
      final success = await _repository.deleteAllNotifications();
      if (success) {
        state = NotificationState.success([]);
      }
    } catch (e) {
      state = NotificationState.error(
          'Failed to delete all notifications: ${e.toString()}');
    }
  }

  /// Clear error
  void clearError() {
    state = NotificationState.initial();
  }
}

typedef NotificationState = BaseState<List<NotificationModel>>;

final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref);
});

/// Provider for notifications stream
final notificationsStreamProvider =
    StreamProvider<List<NotificationModel>>((ref) {
  final repository = NotificationRepository();
  return repository.getNotificationsStream();
});

/// Provider for unread count stream
final unreadCountStreamProvider = StreamProvider<int>((ref) {
  final repository = NotificationRepository();
  return repository.getUnreadCountStream();
});
