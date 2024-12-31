import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/features/notification/base.item.dart';
import 'package:metal/features/notification/domain/entries/notification.model.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/text_views.dart';

class MeltNotificationItem extends BaseNotificationItem {
  const MeltNotificationItem({
    super.key,
    required NotificationModel notificationModel,
  }) : super(notificationModel: notificationModel);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseServiceDb.instance.userId;

    return GestureDetector(
      onTap: () => _handleNotificationTap(context, userId!),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x0C076DF3),
                blurRadius: 40,
                offset: Offset(0, 30),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildIcon(),
              const Gap(18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: notificationModel.title ?? '',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    TextView(
                      text: notificationModel.subTitle ?? '',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
              TextView(
                text: formatTime(datetime: notificationModel.timestamp),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, String userId) {
    switch (notificationModel.type) {
      case NotificationType.new_connection:
        _navigateTo(context, AppRoutes.meltMetal, userId);
        break;
      case NotificationType.new_message:
        _navigateTo(context, AppRoutes.chatWindowsPage, userId);
        break;
      case NotificationType.reaction_added:
        // Handle reaction notification
        break;
      case NotificationType.thought_created:
        // Handle thought creation notification
        break;
      default:
        // Handle other notification types
        break;
    }
  }

  void _navigateTo(BuildContext context, String route, String userId) {
    final metalId = notificationModel.recipientIds.firstWhere(
      (user) => user != userId,
      orElse: () => "", // Handle cases where all user IDs match the current user
    );

    Navigator.pushNamed(context, route, arguments: metalId);
  }

  Widget _buildIcon() {
    String iconPath;

    switch (notificationModel.type) {
      case NotificationType.new_connection:
        iconPath = Assets.images.meltNotifcation.path;
        break;
      case NotificationType.new_message:
        iconPath = Assets.images.activeMessage.path;
        break;
      case NotificationType.reaction_added:
        iconPath = Assets.images.profileNotification.path;
        break;
      case NotificationType.thought_created:
        iconPath = Assets.images.activeMessage.path;
        break;
       case NotificationType.sparks_transaction:
        iconPath = Assets.images.sparkNotification.path;
        break;
      default:
        iconPath = Assets.images.notification.path;
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset(iconPath),
    );
  }
}
