import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/presentation/viewmodels/notification/notification_viewmodel.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Notification View - displays notification list with polling
class NotificationView extends ConsumerWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.metalWhite,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextView(
              text: "Notifications",
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            if (notificationState.unreadCount > 0)
              TextView(
                text: '${notificationState.unreadCount} unread',
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
          ],
        ),
        backgroundColor: AppColors.metalWhite,
        elevation: 0,
        actions: [
          if (notificationState.unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: () {
                ref.read(notificationViewModelProvider.notifier).markAllAsRead();
              },
            ),
          IconButton(
            icon: Icon(
              notificationState.showUnreadOnly == true
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
            ),
            onPressed: () {
              ref.read(notificationViewModelProvider.notifier).toggleUnreadOnly();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(notificationViewModelProvider.notifier).refreshNotifications();
        },
        child: _buildBody(context, ref, notificationState),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, NotificationState state) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.metalPinkColour));
    }

    if (state.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            const Gap(16),
            const TextView(text: 'No notifications', fontSize: 16, fontWeight: FontWeight.w600),
            const Gap(8),
            TextView(text: 'You\'re all caught up!', fontSize: 14, color: Colors.grey.shade600),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.notifications.length,
      itemBuilder: (context, index) {
        final notification = state.notifications[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          color: notification.isRead ? null : AppColors.metalPinkColour.withValues(alpha: 0.05),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getNotificationColor(notification.type).withValues(alpha: 0.2),
              child: Icon(_getNotificationIcon(notification.type), color: _getNotificationColor(notification.type)),
            ),
            title: TextView(text: notification.title, fontSize: 14, fontWeight: FontWeight.w600),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(text: notification.message, fontSize: 12, color: Colors.grey.shade700),
                const Gap(4),
                TextView(text: timeago.format(notification.createdAt), fontSize: 11, color: Colors.grey.shade500),
              ],
            ),
            trailing: !notification.isRead
                ? IconButton(
                    icon: const Icon(Icons.mark_email_read_outlined, size: 20),
                    onPressed: () {
                      ref.read(notificationViewModelProvider.notifier).markAsRead(notificationId: notification.id);
                    },
                  )
                : null,
            onTap: () {
              if (!notification.isRead) {
                ref.read(notificationViewModelProvider.notifier).markAsRead(notificationId: notification.id);
              }
              // TODO: Navigate to notification target (thought, message, etc.)
            },
          ),
        );
      },
    );
  }

  IconData _getNotificationIcon(type) {
    switch (type.toString().split('.').last) {
      case 'melt': return Icons.favorite;
      case 'message': return Icons.message;
      case 'thought': return Icons.lightbulb;
      case 'reaction': return Icons.thumb_up;
      case 'comment': return Icons.comment;
      case 'spark': return Icons.bolt;
      default: return Icons.notifications;
    }
  }

  Color _getNotificationColor(type) {
    switch (type.toString().split('.').last) {
      case 'melt': return Colors.pink;
      case 'message': return Colors.blue;
      case 'thought': return Colors.purple;
      case 'reaction': return Colors.orange;
      case 'comment': return Colors.green;
      case 'spark': return Colors.amber;
      default: return Colors.grey;
    }
  }
}
