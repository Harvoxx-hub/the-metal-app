import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/core/services/notification_handler.dart';
import 'package:metal/core/services/notification_state_service.dart';
import 'package:metal/features/notification/domain/entries/notification.model.dart';
import 'package:metal/features/notification/widget/melt.notification.item.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});
  static const name = 'notificationPage';
  static const route = name;

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(filteredNotificationsStreamProvider);
    final unreadCountAsync = ref.watch(unreadNotificationCountStreamProvider);

    return BaseScreen(
      appBarState: AppBarState.BackWithHeader,
      Header: "Notifications",
      floatingActionButton: unreadCountAsync.when(
        data: (count) => count > 0
            ? FloatingActionButton(
                onPressed: () async {
                  await NotificationStateService.instance.markAllAsRead();
                },
                tooltip: 'Mark all as read',
                child: const Icon(Icons.done_all),
              )
            : null,
        loading: () => null,
        error: (_, __) => null,
      ),
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
            child: notificationsAsync.when(
              data: (notifications) => RefreshIndicator(
                onRefresh: () async {
                  ref.refresh(filteredNotificationsStreamProvider);
                  // Wait a short moment to allow the stream to update
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: _buildNotificationsList(notifications),
              ),
              loading: () =>
                  const Center(child: CircularProgressIndicator.adaptive()),
              error: (error, stack) => Center(
                child: Text('Error loading notifications: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    if (notifications.isEmpty) {
      return const EmptyState(
        text: "You have no notifications",
      );
    }

    return ListView.builder(
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
          onDismissed: (_) async {
            await NotificationStateService.instance.deleteNotification(
              notification.id ?? '',
            );
          },
          child: InkWell(
            onTap: () async {
              // Mark as read if not already read
              if (!notification.isRead) {
                await NotificationStateService.instance.markAsRead(
                  notification.id ?? '',
                );
              }

              // Handle navigation using centralized handler
              await NotificationHandlerService.instance
                  .handleInAppNotification(notification);
            },
            child: MeltNotificationItem(
              notificationModel: notification,
            ),
          ),
        );
      },
    );
  }
}
