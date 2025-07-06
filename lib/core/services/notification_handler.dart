import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:metal/core/utils/connection_helper.dart';
import 'package:metal/fcm/models/notification_payload_model.dart';
import 'package:metal/fcm/models/push_type.dart';
import 'package:metal/features/notification/domain/entries/notification.model.dart';
import 'package:metal/main.dart';
import 'package:metal/route/routes.dart';

/// Abstract base class for notification handlers
abstract class NotificationHandler {
  Future<void> handle(BuildContext context, Map<String, dynamic> data);
}

/// Handler for message notifications
class MessageNotificationHandler extends NotificationHandler {
  @override
  Future<void> handle(BuildContext context, Map<String, dynamic> data) async {
    final chatId = data['chatId'] as String?;
    final senderId = data['senderId'] as String?;

    if (chatId != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.chatWindowsPage,
        arguments: chatId,
      );
    } else if (senderId != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.chatWindowsPage,
        arguments: senderId,
      );
    } else {
      // Fallback to notification page if no chatId or senderId
      Navigator.pushNamed(context, AppRoutes.notificationPage);
    }
  }
}

/// Handler for new connection notifications
class NewConnectionNotificationHandler extends NotificationHandler {
  @override
  Future<void> handle(BuildContext context, Map<String, dynamic> data) async {
    final metalId =
        data['metalId'] as String? ?? data['otherUserId'] as String?;
    final connectionId = data['connectionId'] as String?;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    String? resolvedMetalId = metalId;
    if (resolvedMetalId == null &&
        connectionId != null &&
        currentUserId != null) {
      resolvedMetalId = ConnectionHelper.getOtherUserIdFromConnectionId(
          connectionId, currentUserId);
    }

    if (resolvedMetalId != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.meltMetal,
        arguments: resolvedMetalId,
      );
    } else {
      // Fallback to home tab
      AppRoutes.navigateToHome(context);
    }
  }
}

/// Handler for thought-related notifications
class ThoughtNotificationHandler extends NotificationHandler {
  @override
  Future<void> handle(BuildContext context, Map<String, dynamic> data) async {
    final thoughtId = data['thoughtId'] as String?;

    if (thoughtId != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.thoughtDetails,
        arguments: thoughtId,
      );
    } else {
      // Fallback to home tab
      AppRoutes.navigateToHome(context);
    }
  }
}

/// Handler for reaction notifications
class ReactionNotificationHandler extends NotificationHandler {
  @override
  Future<void> handle(BuildContext context, Map<String, dynamic> data) async {
    final thoughtId = data['thoughtId'] as String?;

    if (thoughtId != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.thoughtDetails,
        arguments: thoughtId,
      );
    } else {
      // Fallback to home tab
      AppRoutes.navigateToHome(context);
    }
  }
}

/// Handler for sparks transaction notifications
class SparksTransactionNotificationHandler extends NotificationHandler {
  @override
  Future<void> handle(BuildContext context, Map<String, dynamic> data) async {
    // Navigate to sparks tab
    AppRoutes.navigateToSparks(context);
  }
}

/// Handler for unmetal request notifications
class UnmetalRequestNotificationHandler extends NotificationHandler {
  @override
  Future<void> handle(BuildContext context, Map<String, dynamic> data) async {
    final connectionId = data['connectionId'] as String?;
    final chatId = data['chatId'] as String?;
    final senderId = data['senderId'] as String?;

    if (connectionId != null || chatId != null || senderId != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.chatWindowsPage,
        arguments: senderId,
      );
    } else {
      // Fallback to messages tab
      AppRoutes.navigateToMessages(context);
    }
  }
}

/// Handler for thought reminder notifications
class ThoughtReminderNotificationHandler extends NotificationHandler {
  @override
  Future<void> handle(BuildContext context, Map<String, dynamic> data) async {
    // Navigate to home tab where users can create thoughts
    AppRoutes.navigateToHome(context);
  }
}

/// Handler for comment notifications
class CommentNotificationHandler extends NotificationHandler {
  @override
  Future<void> handle(BuildContext context, Map<String, dynamic> data) async {
    final thoughtId = data['thoughtId'] as String?;

    if (thoughtId != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.thoughtDetails,
        arguments: thoughtId,
      );
    } else {
      // Fallback to home tab
      AppRoutes.navigateToHome(context);
    }
  }
}

/// Handler for comment reaction notifications
class CommentReactionNotificationHandler extends NotificationHandler {
  @override
  Future<void> handle(BuildContext context, Map<String, dynamic> data) async {
    final thoughtId = data['thoughtId'] as String?;
    final commentId = data['commentId'] as String?;

    if (thoughtId != null) {
      // Navigate to thought details where comments are shown
      Navigator.pushNamed(
        context,
        AppRoutes.thoughtDetails,
        arguments: thoughtId,
      );
    } else {
      // Fallback to home tab
      AppRoutes.navigateToHome(context);
    }
  }
}

/// Default handler for unknown notification types
class DefaultNotificationHandler extends NotificationHandler {
  @override
  Future<void> handle(BuildContext context, Map<String, dynamic> data) async {
    // Navigate to notification page for unknown types
    Navigator.pushNamed(context, AppRoutes.notificationPage);
  }
}

/// Centralized notification service
class NotificationHandlerService {
  static final NotificationHandlerService _instance =
      NotificationHandlerService._();
  static NotificationHandlerService get instance => _instance;

  NotificationHandlerService._();

  /// Map of notification types to their handlers
  final Map<String, NotificationHandler> _handlers = {
    // FCM/Push notification types
    PushType.message.value: MessageNotificationHandler(),
    PushType.new_connection.value: NewConnectionNotificationHandler(),
    PushType.unmetal_request.value: UnmetalRequestNotificationHandler(),
    PushType.thought_created.value: ThoughtNotificationHandler(),
    PushType.reaction_added.value: ReactionNotificationHandler(),
    PushType.sparks_transaction.value: SparksTransactionNotificationHandler(),
    PushType.thought_reminder.value: ThoughtReminderNotificationHandler(),
    PushType.comment.value: CommentNotificationHandler(),
    PushType.comment_reaction.value: CommentReactionNotificationHandler(),

    // In-app notification types (NotificationType enum)
    'new_message': MessageNotificationHandler(),
    'new_connection': NewConnectionNotificationHandler(),
    'unmetal_request': UnmetalRequestNotificationHandler(),
    'thought_created': ThoughtNotificationHandler(),
    'reaction_added': ReactionNotificationHandler(),
    'sparks_transaction': SparksTransactionNotificationHandler(),
    'thought_reminder': ThoughtReminderNotificationHandler(),
    'comment': CommentNotificationHandler(),
    'comment_reaction': CommentReactionNotificationHandler(),
  };

  /// Handle notification from FCM payload
  Future<void> handleFCMNotification(
    NotificationPayloadModel payload, {
    bool removeUntil = false,
  }) async {
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

    final actionKey = payload.action?.value ?? 'unknown';
    final handler = _handlers[actionKey] ?? DefaultNotificationHandler();

    await handler.handle(context, payload.data ?? {});
  }

  /// Handle notification from NotificationModel (in-app)
  Future<void> handleInAppNotification(NotificationModel notification) async {
    final navigator = navKey.currentState;
    if (navigator == null) return;

    final context = navigator.context;
    final typeKey = notification.type.toString().split('.').last;
    final handler = _handlers[typeKey] ?? DefaultNotificationHandler();

    await handler.handle(context, notification.data ?? {});
  }

  /// Handle notification tap with generic data
  Future<void> handleNotificationTap({
    required String type,
    required Map<String, dynamic> data,
    bool removeUntil = false,
  }) async {
    final navigator = navKey.currentState;
    if (navigator == null) return;

    final context = navigator.context;

    // Navigate to dashboard first if needed
    if (removeUntil) {
      navigator.pushNamedAndRemoveUntil(
        AppRoutes.dashboardPage,
        (route) => false,
      );
      await Future.delayed(const Duration(milliseconds: 300));
    }

    final handler = _handlers[type] ?? DefaultNotificationHandler();
    await handler.handle(context, data);
  }

  /// Register a custom handler for a notification type
  void registerHandler(String type, NotificationHandler handler) {
    _handlers[type] = handler;
  }

  /// Get all registered notification types
  List<String> get supportedTypes => _handlers.keys.toList();
}
