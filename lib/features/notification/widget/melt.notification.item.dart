import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/features/notification/base.item.dart';
import 'package:metal/features/notification/domain/entries/notification.model.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/text_views.dart';

class MeltNotificationItem extends BaseNotificationItem {
  const MeltNotificationItem(
      {super.key, required NotificationModel notificationModel})
      : super(notificationModel: notificationModel);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        switch (notificationModel.type) {
          case NotificationType.MELT:
            {
                Navigator.pushNamed(
            context,
            AppRoutes.meltMetal,
            arguments: notificationModel.sender,
          );
            }
            break;
          case NotificationType.SPARK:
            // Navigate or handle SPARK notification action
            break;
          case NotificationType.REFER:
            // Navigate or handle REFER notification action
            break;
          case NotificationType.MESSAGE:
            // Navigate or handle MESSAGE notification action
            break;
          case NotificationType.UNMELT:
            // Navigate or handle UNMELT notification action
            break;
          default:
            // Handle any other notification types if applicable
            break;
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.only(top: 16, bottom: 16),
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
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(Assets.images.profileNotification.path),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Image.asset(Assets.images.meltNotifcation.path),
                  ),
                ],
              ),
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
                      text: notificationModel.body ?? '',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
              TextView(
                text: formatToWhatsAppChatTime(notificationModel.created_at!),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
