import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/core/services/notification_navigation_service.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/notification/notification_viewmodel.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/state.handler/loading.state.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:timeago/timeago.dart' as timeago;

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
    // Setup scroll listener for pagination
    // Note: Notifications are auto-loaded by the viewmodel provider
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      floatingActionButton: notificationState.unreadCount > 0
          ? FloatingActionButton.extended(
              onPressed: () => _handleMarkAllAsRead(context),
              backgroundColor: AppColors.metalPinkColour,
              icon: const Icon(Icons.done_all, color: Colors.white),
              label: const TextView(
                text: 'Mark all as read',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            )
          : null,
    );
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
          return _buildNotificationCard(context, notification, state);
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    notification,
    NotificationState state,
  ) {
    final isUnread = !notification.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnread
            ? AppColors.metalPinkColour.withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread
              ? AppColors.metalPinkColour.withOpacity(0.2)
              : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleNotificationTap(context, notification),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification icon
                _buildNotificationIcon(notification.type, isUnread),
                const Gap(16),
                // Notification content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Row(
                        children: [
                          Expanded(
                            child: TextView(
                              text: notification.title,
                              fontSize: 15,
                              fontWeight: isUnread
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.metalPinkColour,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const Gap(6),
                      // Message
                      TextView(
                        text: notification.message,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade700,
                        maxLines: 2,
                        textOverflow: TextOverflow.ellipsis,
                      ),
                      const Gap(8),
                      // Time ago
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const Gap(4),
                          TextView(
                            text: timeago.format(notification.createdAt),
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Sender photo (if available)
                if (notification.senderPhoto != null) ...[
                  const Gap(12),
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: notification.senderPhoto!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.metalPinkColour,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(notificationType, bool isUnread) {
    Color iconColor = isUnread
        ? AppColors.metalPinkColour
        : Colors.grey.shade600;

    Widget iconWidget;

    switch (notificationType.toString().split('.').last) {
      // Profile interactions
      case 'like':
        iconWidget = Image.asset(
          Assets.images.likeNotification.path,
          width: 32,
          height: 32,
          color: iconColor,
        );
        break;
      case 'superlike':
        iconWidget = Icon(
          Icons.favorite,
          size: 32,
          color: iconColor,
        );
        break;
      // Melt/Connection
      case 'match':
        iconWidget = SvgPicture.asset(
          Assets.icons.meltNotification.path,
          width: 32,
          height: 32,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        );
        break;
      case 'meltRequest':
      case 'melt_request':
        iconWidget = SvgPicture.asset(
          Assets.icons.meltNotification.path,
          width: 32,
          height: 32,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        );
        break;
      // Unmelt
      case 'unmetalRequested':
      case 'unmetal_requested':
        iconWidget = Icon(
          Icons.visibility,
          size: 32,
          color: iconColor,
        );
        break;
      case 'unmetalAccepted':
      case 'unmetal_accepted':
        iconWidget = Icon(
          Icons.check_circle,
          size: 32,
          color: iconColor,
        );
        break;
      // Sparks
      case 'spark':
        iconWidget = Icon(
          Icons.bolt_rounded,
          size: 32,
          color: iconColor,
        );
        break;
      // Referral
      case 'referral':
        iconWidget = Icon(
          Icons.person_add,
          size: 32,
          color: iconColor,
        );
        break;
      // Other
      case 'message':
        iconWidget = Icon(
          Icons.message_rounded,
          size: 32,
          color: iconColor,
        );
        break;
      case 'comment':
        iconWidget = Icon(
          Icons.comment_rounded,
          size: 32,
          color: iconColor,
        );
        break;
      default:
        iconWidget = SvgPicture.asset(
          Assets.icons.notification.path,
          width: 32,
          height: 32,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(child: iconWidget),
    );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          backgroundColor: AppColors.metalPinkColour,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to mark all as read'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
