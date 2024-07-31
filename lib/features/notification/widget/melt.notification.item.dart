import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/features/notification/base.item.dart';
import 'package:metal/features/notification/domain/entries/notification.model.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/text_views.dart';
 

class MeltNotificationItem extends BaseNotificationItem {
  const MeltNotificationItem({super.key, required NotificationModel notificationModel})
      : super(notificationModel: notificationModel);

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                    text: notificationModel.body ?? '',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  Row(
                    children:   [
                      Spacer(),
                      TextView(
                        text: formatDateDDMMYY(notificationModel.created_at!),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Create other specific notification item widgets for SPARK, REFER, MESSAGE, UNMELT in a similar manner
