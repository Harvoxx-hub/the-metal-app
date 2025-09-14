import 'package:flutter/material.dart';
import 'package:metal/fcm/models/notification_payload_model.dart';
import 'package:metal/fcm/models/push_type.dart';
import 'package:metal/features/notification/domain/entries/notification.model.dart';
import 'package:metal/route/routes.dart';

/// Centralized service for handling notification navigation
/// Follows KISS and DRY principles by providing a single source of truth
/// for all notification navigation logic
class NotificationNavigationService {
  NotificationNavigationService._();
  static final NotificationNavigationService _instance =
      NotificationNavigationService._();
  static NotificationNavigationService get instance => _instance;

  /// Navigate based on notification payload from FCM
  Future<void> navigateFromPayload(
    NotificationPayloadModel payload,
    BuildContext context,
  ) async {
    if (!context.mounted) return;

    final action = payload.action;
    final data = payload.data;

    if (action == null) return;

    switch (action) {
      case PushType.message:
        await _navigateToChat(data, context);
        break;
      case PushType.new_connection:
        await _navigateToMeltMetal(data, context);
        break;
      case PushType.unmetal_request:
        await _navigateToChat(data, context);
        break;
      case PushType.thought_created:
      case PushType.reaction_added:
      case PushType.comment:
      case PushType.comment_reaction:
        await _navigateToThoughtDetails(data, context);
        break;
      case PushType.sparks_transaction:
        await _navigateToSparks(context);
        break;
      case PushType.thought_reminder:
        // Handle thought reminder if needed
        break;
      case PushType.follow:
        await _navigateToHome(context);
        break;
      case PushType.unknown:
        await _navigateToHome(context);
        break;
    }
  }

  /// Navigate based on notification model from database
  Future<void> navigateFromNotification(
    NotificationModel notification,
    BuildContext context,
  ) async {
    if (!context.mounted) return;

    final data = notification.data as Map<String, dynamic>?;

    switch (notification.type) {
      case NotificationType.new_message:
        await _navigateToChat(data, context);
        break;
      case NotificationType.new_connection:
        await _navigateToMeltMetal(data, context);
        break;
      case NotificationType.unmetal_request:
        await _navigateToChat(data, context);
        break;
      case NotificationType.thought_created:
      case NotificationType.reaction_added:
      case NotificationType.comment:
      case NotificationType.comment_reaction:
        await _navigateToThoughtDetails(data, context);
        break;
      case NotificationType.sparks_transaction:
        await _navigateToSparks(context);
        break;
      case NotificationType.thought_reminder:
        // Handle thought reminder if needed
        break;
    }
  }

  /// Navigate to chat window
  Future<void> _navigateToChat(
      Map<String, dynamic>? data, BuildContext context) async {
    final connectionId = data?['connectionId'] as String?;
    final chatId = data?['chatId'] as String?;

    if (connectionId != null || chatId != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.chatWindowsPage,
        arguments: connectionId ?? chatId,
      );
    } else {
      await _navigateToMessages(context);
    }
  }

  /// Navigate to melt metal page
  Future<void> _navigateToMeltMetal(
      Map<String, dynamic>? data, BuildContext context) async {
    final metalId =
        data?['metalId'] as String? ?? data?['otherUserId'] as String?;

    if (metalId != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.meltMetal,
        arguments: metalId,
      );
    } else {
      await _navigateToHome(context);
    }
  }

  /// Navigate to thought details
  Future<void> _navigateToThoughtDetails(
      Map<String, dynamic>? data, BuildContext context) async {
    final thoughtId = data?['thoughtId'] as String?;

    if (thoughtId != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.thoughtDetails,
        arguments: thoughtId,
      );
    } else {
      await _navigateToHome(context);
    }
  }

  /// Navigate to sparks page
  Future<void> _navigateToSparks(BuildContext context) async {
    AppRoutes.navigateToSparks(context);
  }

  /// Navigate to messages tab
  Future<void> _navigateToMessages(BuildContext context) async {
    AppRoutes.navigateToMessages(context);
  }

  /// Navigate to home tab
  Future<void> _navigateToHome(BuildContext context) async {
    AppRoutes.navigateToHome(context);
  }
}
