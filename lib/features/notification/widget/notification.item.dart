import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/features/notification/domain/entries/notification.model.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationItem({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFFFEFF5),
        borderRadius: BorderRadius.circular(10),
        border: isRead
            ? null
            : Border.all(
                color: AppColors.metalPinkColour.withOpacity(0.3),
                width: 1,
              ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C076DF3),
            blurRadius: 40,
            offset: Offset(0, 30),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildIconWithBadge(),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                  text: notification.title,
                  fontSize: 14,
                  fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                  color:
                      isRead ? AppColors.metalBlack : AppColors.metalPinkColour,
                ),
                const Gap(4),
                TextView(
                  text: notification.subTitle,
                  fontSize: 12,
                  color: AppColors.metalBlack75,
                ),
              ],
            ),
          ),
          TextView(
            text: formatTime(datetime: notification.timestamp),
            fontSize: 12,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildIconWithBadge() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(_getIconPath()),
        ),
        if (!notification.isRead)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.metalPinkColour,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  String _getIconPath() {
    switch (notification.type) {
      case NotificationType.new_connection:
      case NotificationType.unmetal_request:
        return Assets.images.meltNotifcation.path;
      case NotificationType.new_message:
      case NotificationType.thought_created:
      case NotificationType.thought_reminder:
      case NotificationType.comment:
        return Assets.images.activeMessage.path;
      case NotificationType.reaction_added:
      case NotificationType.comment_reaction:
        return Assets.images.profileNotification.path;
      case NotificationType.sparks_transaction:
        return Assets.images.sparkNotification.path;
    }
  }
}
