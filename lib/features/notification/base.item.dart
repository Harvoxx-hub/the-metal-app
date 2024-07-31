import 'package:flutter/material.dart';
import 'package:metal/features/notification/domain/entries/notification.model.dart';

abstract class BaseNotificationItem extends StatelessWidget {
  final NotificationModel notificationModel;

  const BaseNotificationItem({super.key, required this.notificationModel});

  @override
  Widget build(BuildContext context) {
    return Container(); // This will be overridden by specific notification widgets
  }
}
