import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/core/services/notification_navigation_service.dart';
import 'package:metal/core/services/notification_refresh_signal.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/views/notification/widgets/notification_item_card.dart';
import 'package:metal/presentation/viewmodels/notification/notification_viewmodel.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/state.handler/loading.state.dart';
import 'package:metal/widgets/text_views.dart';

/// Notification View - displays notification list with live updates
class NotificationView extends ConsumerStatefulWidget {
  const NotificationView({super.key});

  @override
  ConsumerState<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends ConsumerState<NotificationView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    NotificationRefreshSignal.instance.addListener(_onPushReceived);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationViewModelProvider.notifier).refreshNotifications();
    });
  }

  @override
  void dispose() {
    NotificationRefreshSignal.instance.removeListener(_onPushReceived);
    _scrollController.dispose();
    super.dispose();
  }

  void _onPushReceived() {
    ref.read(notificationViewModelProvider.notifier).refreshOnPushReceived();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more when 80% scrolled
      ref.read(notificationViewModelProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationViewModelProvider);

    return BaseScreen(
      Header: 'Notifications',
      appBarState: AppBarState.BackWithHeader,
      body: _buildBody(context, notificationState),
    ) ;
  }

  Widget _buildBody(BuildContext context, NotificationState state) {
    // Loading state (initial load)
    if (state.isLoading && state.notifications.isEmpty) {
      return const LoadingState();
    }

    // Error state
    if (state.isError && state.notifications.isEmpty) {
      return ErrorState(
        text: state.errorMessage ?? 'Failed to load notifications',
        retry: () {
          ref.read(notificationViewModelProvider.notifier).refreshNotifications();
        },
      );
    }

    // Empty state
    if (state.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              Assets.icons.notification.path,
              width: 80,
              height: 80,
              colorFilter: ColorFilter.mode(
                Colors.grey.shade300,
                BlendMode.srcIn,
              ),
            ),
            const Gap(24),
            const TextView(
              text: 'No notifications',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            const Gap(8),
            TextView(
              text: 'You\'re all caught up!',
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      );
    }

    // Notification list
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notificationViewModelProvider.notifier).refreshNotifications();
      },
      color: AppColors.metalPinkColour,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemCount: state.notifications.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.notifications.length) {
            // Loading more indicator
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.metalPinkColour,
                ),
              ),
            );
          }

          final notification = state.notifications[index];
          return NotificationItemCard(
            notification: notification,
            onTap: () => _handleNotificationTap(context, notification),
            onAction: (action) => _handleNotificationAction(context, notification, action),
          );
        },
      ),
    );
  }

  Future<void> _handleNotificationAction(
    BuildContext context,
    notification,
    String action,
  ) async {
    final result = await ref
        .read(notificationViewModelProvider.notifier)
        .executeAction(
          notificationId: notification.id,
          action: action,
        );

    if (!context.mounted) return;

    if (result != null) {
      final connectionId = result['connectionId'] as String?;
      final meetupId = result['meetupId'] as String?;

      if (connectionId != null && connectionId.isNotEmpty) {
        Navigator.pushNamed(context, AppRoutes.chatWindowView, arguments: connectionId);
      } else if (meetupId != null && meetupId.isNotEmpty) {
        Navigator.pushNamed(context, AppRoutes.meetupDetails, arguments: meetupId);
      }
    }

    ref.read(notificationViewModelProvider.notifier).refreshNotifications();
  }

  Future<void> _handleNotificationTap(
    BuildContext context,
    notification,
  ) async {
    // Mark as read if unread
    if (!notification.isRead) {
      await ref
          .read(notificationViewModelProvider.notifier)
          .markAsRead(notificationId: notification.id);
    }

    // Navigate based on notification type
    if (mounted) {
      await NotificationNavigationService.instance
          .navigateFromNotification(notification, context);
    }
  }

  Future<void> _handleMarkAllAsRead(BuildContext context) async {
    final success = await ref
        .read(notificationViewModelProvider.notifier)
        .markAllAsRead();

    if (mounted && success) {
      Fluttertoast.showToast(
        msg: 'All notifications marked as read',
        toastLength: Toast.LENGTH_SHORT,
      );
    } else if (mounted) {
      Fluttertoast.showToast(
        msg: 'Failed to mark all as read',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }
}
