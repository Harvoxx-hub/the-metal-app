import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/core/utils/metal.helper.dart';
import 'package:metal/features/notification/domain/entries/notification.model.dart';
import 'package:metal/features/notification/provider/notification.notifier.dart';
 
import 'package:metal/features/notification/widget/melt.notification.item.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
 

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});
  static const name = 'notificationPage';
  static const route = name;

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  // Store notification IDs for marking as read on exit

  @override
  void initState() {
    super.initState();
    // Fetch notifications when page loads
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return BaseScreen(
      appBarState: AppBarState.BackWithHeader,
      Header: "Notifications",
      floatingActionButton: unreadCount > 0
          ? FloatingActionButton(
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
              },
              tooltip: 'Mark all as read',
              child: const Icon(Icons.done_all),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 53,
            width: double.infinity,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.00, -1.00),
                  end: Alignment(0, 1),
                  colors: [Color(0xFFDB217A), Color(0xFFF00E3E)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                )),
          ),
          Expanded(
            child: _buildNotificationsList(notifications),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    if (notifications.isEmpty) {
      return const EmptyState(text: "You have no notifications yet");
    }

    // Group notifications by type
    final Map<String, List<NotificationModel>> groupedNotifications = {};

    for (final notification in notifications) {
      final String type =
          notification.type != null ? notification.type.toString() : 'other';
      if (!groupedNotifications.containsKey(type)) {
        groupedNotifications[type] = [];
      }
      groupedNotifications[type]!.add(notification);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notificationProvider.notifier).fetchNotifications();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: notifications.length,
        itemBuilder: (BuildContext context, int index) {
          final notification = notifications[index];
          return Dismissible(
            key: Key(notification.id ?? 'notification-$index'),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (_) {
              ref.read(notificationProvider.notifier).deleteNotification(
                    notification.id ?? '',
                  );
            },
            child: InkWell(
              onTap: () {
                if (!notification.isRead) {
                  ref.read(notificationProvider.notifier).markAsRead(
                        notification.id ?? '',
                      );
                }

                // Handle navigation based on notification type
                _handleNotificationNavigation(context, notification);
              },
              child: MeltNotificationItem(
                notificationModel: notification,
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleNotificationNavigation(
      BuildContext context, NotificationModel notification) {
    switch (notification.type) {
      case NotificationType.new_connection:
        final metalId = MetalHelper.getOtherUserId(notification.recipientIds);
        if (metalId != null && metalId.isNotEmpty) {
          Navigator.pushNamed(context, AppRoutes.meltMetal, arguments: metalId);
        }
        break;

      case NotificationType.new_message:
        final senderId = notification.data["senderId"];
        if (senderId != null) {
          Navigator.pushNamed(context, AppRoutes.chatWindowsPage,
              arguments: senderId);
        } else {
          // Navigate to messages tab if no specific chat
          AppRoutes.navigateToMessages(context);
        }
        break;

      case NotificationType.reaction_added:
        // Navigate to the thought that received a reaction
        final thoughtId = notification.data["thoughtId"];
        if (thoughtId != null) {
          Navigator.pushNamed(context, AppRoutes.thoughtDetails,
              arguments: thoughtId);
        } else {
          // Navigate to home tab if no specific thought
          AppRoutes.navigateToHome(context);
        }
        break;

      case NotificationType.thought_created:
        final userId = notification.data["userId"];
        final thoughtId = notification.data["thoughtId"];
        if (userId != null && thoughtId != null) {
          Navigator.pushNamed(context, AppRoutes.thoughtDetails,
              arguments: thoughtId);
        } else {
          // Navigate to home tab if no specific thought
          AppRoutes.navigateToHome(context);
        }
        break;

      case NotificationType.sparks_transaction:
        // Navigate to sparks tab for transactions
        AppRoutes.navigateToSparks(context);
        break;

      default:
        // For unknown types, just stay on notification page
        break;
    }
  }
}
