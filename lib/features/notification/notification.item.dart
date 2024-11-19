import 'package:flutter/material.dart';
import 'package:metal/features/notification/base.item.dart';
import 'package:metal/features/notification/domain/entries/notification.model.dart';
import 'package:metal/features/notification/widget/melt.notification.item.dart';

class NotificationItemFactory {
  static BaseNotificationItem create(NotificationModel notificationModel) {
    switch (notificationModel.type) {
      case NotificationType.MELT:
        return MeltNotificationItem(notificationModel: notificationModel);
      // Add cases for other notification types here
      case NotificationType.MESSAGE:
        return MeltNotificationItem(notificationModel: notificationModel);
      case NotificationType.REFER:
        return MeltNotificationItem(notificationModel: notificationModel);
      case NotificationType.SPARK:
        return MeltNotificationItem(notificationModel: notificationModel);
      case NotificationType.UNMELT:
      default:
        return MeltNotificationItem(
            notificationModel: notificationModel); // Default case
    }
  }
}
