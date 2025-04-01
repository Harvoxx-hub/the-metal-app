import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/core/utils/metal.helper.dart';
import 'package:metal/features/notification/base.item.dart';
import 'package:metal/features/notification/domain/entries/notification.model.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/text_views.dart';

class MeltNotificationItem extends BaseNotificationItem {
  const MeltNotificationItem({
    super.key,
    required NotificationModel notificationModel,
  }) : super(notificationModel: notificationModel);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: ShapeDecoration(
          color:
              notificationModel.isRead ? Colors.white : const Color(0xFFFFEFF5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: notificationModel.isRead
                  ? Colors.transparent
                  : AppColors.metalPinkColour.withOpacity(0.3),
              width: 1,
            ),
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
            Stack(
              children: [
                _buildIcon(),
                if (!notificationModel.isRead)
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
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    text: notificationModel.title ?? '',
                    fontSize: 14,
                    fontWeight: notificationModel.isRead
                        ? FontWeight.w500
                        : FontWeight.w600,
                    color: notificationModel.isRead
                        ? AppColors.metalBlack
                        : AppColors.metalPinkColour,
                  ),
                  const Gap(4),
                  TextView(
                    text: notificationModel.subTitle ?? '',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.metalBlack75,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextView(
                  text: formatTime(datetime: notificationModel.timestamp),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // This method is kept for reference but no longer used directly by this widget
  // The parent widget now handles navigation
  static void handleNotificationTap(
      BuildContext context, NotificationModel notificationModel) {
    switch (notificationModel.type) {
      case NotificationType.new_connection:
        final metalId =
            MetalHelper.getOtherUserId(notificationModel.recipientIds);
        _navigateTo(context, AppRoutes.meltMetal, metalId);
        break;
      case NotificationType.new_message:
        final metalId = notificationModel.data["senderId"];
        _navigateTo(context, AppRoutes.chatWindowsPage, metalId);
        break;
      case NotificationType.reaction_added:
        // Handle reaction notification
        break;
      case NotificationType.thought_created:
        _navigateTo(context, AppRoutes.myMeltedUser, {
          "metalId": notificationModel.data["userId"],
          "toughtId": notificationModel.data["thoughtId"]
        });
        break;
      default:
        // Handle other notification types
        break;
    }
  }

  static void _navigateTo(BuildContext context, String route, var userId) {
    Navigator.pushNamed(context, route, arguments: userId);
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
