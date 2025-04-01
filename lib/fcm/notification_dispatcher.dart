import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/home_page/domain/entries/thought.model.dart';
import 'package:metal/fcm/abstract_notification_dispatcher.dart';
import 'package:metal/fcm/models/notification_payload_model.dart';
import 'package:metal/fcm/models/push_type.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/main.dart';

class NotificationDispatcher extends AbstractNotificationDispatcher {
  NotificationDispatcher._();
  static final NotificationDispatcher _instance = NotificationDispatcher._();
  static NotificationDispatcher get instance => _instance;

  @override
  Future<void> dispatchNotification(
    NotificationPayloadModel? model, {
    bool removeUntil = false,
  }) async {
    if (model == null) return;

    // Get navigator
    final navigator = navKey.currentState;
    if (navigator == null) return;
    final context = navigator.context;

    // Navigate to dashboard first if needed
    if (removeUntil) {
      navigator.pushNamedAndRemoveUntil(
        AppRoutes.dashboardPage,
        (route) => false,
      );
      // Wait for navigation to complete
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // Handle based on notification type
    switch (model.action) {
      case PushType.message:
        final chatId = model.data?['chatId'] as String?;
        if (chatId != null) {
          navigator.pushNamed(
            AppRoutes.chatWindowsPage,
            arguments: {'chatId': chatId},
          );
        } else {
          // Navigate to messages tab if no specific chat
          AppRoutes.navigateToMessages(context);
        }
        break;

      case PushType.new_connection:
        final metalId = model.data?['metalId'] as String?;
        if (metalId != null) {
          navigator.pushNamed(
            AppRoutes.meltMetal,
            arguments: {'metalId': metalId},
          );
        } else {
          // Navigate to home tab for connections
          AppRoutes.navigateToHome(context);
        }
        break;

      case PushType.thought_created:
        final thoughtId = model.data?['thoughtId'] as String?;
        if (thoughtId != null) {
          // Get thought data or navigate directly
          navigator.pushNamed(
            AppRoutes.thoughtDetails,
            arguments: thoughtId,
          );
        } else {
          // Navigate to home tab for general thoughts
          AppRoutes.navigateToHome(context);
        }
        break;

      case PushType.reaction_added:
        final thoughtId = model.data?['thoughtId'] as String?;
        if (thoughtId != null) {
          navigator.pushNamed(
            AppRoutes.thoughtDetails,
            arguments: thoughtId,
          );
        } else {
          // Navigate to home tab for reactions
          AppRoutes.navigateToHome(context);
        }
        break;

      case PushType.sparks_transaction:
        // Navigate to sparks tab for transactions
        AppRoutes.navigateToSparks(context);
        break;

      default:
        // For unknown types, take user to the notification page
        navigator.pushNamed(AppRoutes.notificationPage);
        break;
    }
  }
}
