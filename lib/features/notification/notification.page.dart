 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/core/services/notification_handler.dart';
import 'package:metal/core/services/notification_state_service.dart';
import 'package:metal/features/notification/domain/entries/notification.model.dart';
import 'package:metal/features/notification/widget/notification.item.dart';
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
                onPressed: () =>
                    NotificationStateService.instance.markAllAsRead(),
                tooltip: 'Mark all as read',
                child: const Icon(Icons.done_all),
              )
            : null,
        loading: () => null,
        error: (_, __) => null,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: notificationsAsync.when(
              data: (notifications) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(filteredNotificationsStreamProvider);
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

  Widget _buildHeader() {
    return Container(
      height: 53,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.00, -1.00),
          end: Alignment(0, 1),
          colors: [Color(0xFFDB217A), Color(0xFFF00E3E)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    if (notifications.isEmpty) {
      return const EmptyState(text: "You have no notifications");
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Dismissible(
          key: Key(notification.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _deleteNotification(notification),
          child: InkWell(
            onTap: () => _handleNotificationTap(notification),
            child: NotificationItem(notification: notification),
          ),
        );
      },
    );
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    await NotificationStateService.instance.deleteNotification(notification.id);
  }

  Future<void> _handleNotificationTap(NotificationModel notification) async {
    if (!notification.isRead) {
      await NotificationStateService.instance.markAsRead(notification.id);
    }
    await NotificationHandlerService.instance
        .handleInAppNotification(notification);
  }
}
