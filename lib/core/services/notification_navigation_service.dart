import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:metal/fcm/models/notification_payload_model.dart';
import 'package:metal/fcm/models/push_type.dart';
import 'package:metal/domain/entities/notification_dto.dart';
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

    final data = payload.data;
    final pushType = PushType.valueOf(data?["type"]);

    try {
      await _handleNavigation(pushType, data, context);
    } catch (e, stackTrace) {
      print('Navigation error: $e');
      print(stackTrace);
      rethrow;
    }
  }

  /// Navigate based on notification model from database
  Future<void> navigateFromNotification(
    NotificationDto notification,
    BuildContext context,
  ) async {
    if (!context.mounted) return;

    final data = notification.data;

    // Handle notification types that need special navigation
    switch (notification.type) {
      case NotificationType.profileLiked:
        if (notification.effectiveSenderId.isNotEmpty) {
          await _navigateToUserProfile(notification.effectiveSenderId, context);
        } else {
          await _navigateToHome(context);
        }
        return;
      case NotificationType.meltRequest:
        if (notification.effectiveSenderId.isNotEmpty) {
          await _navigateToUserProfile(notification.effectiveSenderId, context);
        } else {
          await _navigateToHome(context);
        }
        return;
      case NotificationType.referralJoined:
        await _navigateToReferral(context);
        return;
      case NotificationType.melted:
        // Take user to the profile of the person they melted with
        final meltedUserId = notification.effectiveSenderId.isNotEmpty
            ? notification.effectiveSenderId
            : (notification.data?['senderId'] as String? ??
                notification.metadata?['senderId'] as String? ??
                '');
        if (meltedUserId.isNotEmpty) {
          await _navigateToUserProfile(meltedUserId, context);
        } else {
          await _navigateToHome(context);
        }
        return;
      case NotificationType.sparksSent:
        await _navigateToSparks(context);
        return;
      case NotificationType.unmetalRequiresMoreTime:
      case NotificationType.message:
      case NotificationType.promptReaction:
      case NotificationType.directMessage:
        if (notification.connectionId != null) {
          await _navigateToChat(
              {'connectionId': notification.connectionId}, context);
        } else {
          await _navigateToMessages(context);
        }
        return;
      case NotificationType.meetupRsvpDeclined:
        if (notification.connectionId != null) {
          await _navigateToChat(
              {'connectionId': notification.connectionId}, context);
        } else {
          await _navigateToMessages(context);
        }
        return;
      case NotificationType.meetupCreated:
      case NotificationType.meetupInvite:
      case NotificationType.meetupReminder:
      case NotificationType.meetupRsvpUpdate:
      case NotificationType.meetupCapacityReached:
        if (notification.meetupId != null) {
          await _navigateToMeetup({'meetupId': notification.meetupId}, context);
        } else if (notification.relatedId != null) {
          await _navigateToMeetup(
              {'meetupId': notification.relatedId}, context);
        } else {
          await _navigateToHome(context);
        }
        return;
      case NotificationType.unmetalAcceptance:
      case NotificationType.unmetalRequest:
        await _navigateToChat(
            notification.metadata ?? notification.data ?? {}, context);
        return;
      case NotificationType.thoughtReminder:
        await _navigateToPostThought(context);
        return;
      case NotificationType.thoughtReaction:
      case NotificationType.thoughtComment:
      case NotificationType.thoughtRepost:
      case NotificationType.thoughtCreated:
      case NotificationType.communityPost:
        final payload = <String, dynamic>{
          ...?notification.data,
          if (notification.metadata != null) 'metadata': notification.metadata,
        };
        final thoughtId = notification.metadata?['thoughtId'] as String? ??
            notification.data?['thoughtId'] as String?;
        if (thoughtId != null && thoughtId.isNotEmpty) {
          payload['thoughtId'] = thoughtId;
        }
        await _navigateToThoughtDetails(payload, context);
        return;
      default:
        // "Share your Thought!" system notification -> go to post thought page
        final title = notification.title.toLowerCase();
        final message = (notification.displayMessage).toLowerCase();
        if (title.contains('share your thought') ||
            message.contains('share your thought') ||
            title.contains('post a thought') ||
            message.contains('post a thought')) {
          await _navigateToPostThought(context);
          return;
        }
        // "You have a new Melt!" coming as system -> go to profile of person they melted with
        if (title.contains('melt') ||
            message.contains('melt') ||
            title.contains('match') ||
            message.contains('match')) {
          final meltedUserId = notification.effectiveSenderId.isNotEmpty
              ? notification.effectiveSenderId
              : (notification.data?['senderId'] as String? ??
                  notification.metadata?['senderId'] as String? ??
                  '');
          if (meltedUserId.isNotEmpty) {
            await _navigateToUserProfile(meltedUserId, context);
          } else {
            await _navigateToHome(context);
          }
          return;
        }
        // If notification has thoughtId (e.g. "new thought shared"), go to thought details
        final thoughtId = notification.metadata?['thoughtId'] as String? ??
            notification.data?['thoughtId'] as String?;
        if (thoughtId != null && thoughtId.isNotEmpty) {
          final payload = <String, dynamic>{
            ...?notification.data,
            if (notification.metadata != null)
              'metadata': notification.metadata,
            'thoughtId': thoughtId,
          };
          await _navigateToThoughtDetails(payload, context);
          return;
        }
        // Use push type mapping for other types
        final pushType = _mapNotificationTypeToPushType(notification.type);
        await _handleNavigation(pushType, data, context);
    }
  }

  /// Centralized navigation handler
  Future<void> _handleNavigation(
    PushType? pushType,
    Map<String, dynamic>? data,
    BuildContext context,
  ) async {
    switch (pushType) {
      case null:
      case PushType.follow:
      case PushType.unknown:
        await _navigateToHome(context);
        break;
      case PushType.message:
      case PushType.messageDirect:
      case PushType.unmetalRequest:
      case PushType.unmetalAcceptance:
      case PushType.unmetalRequiresMoreTime:
        await _navigateToChat(data, context);
        break;
      case PushType.new_connection:
      case PushType.match:
      case PushType.melted:
        {
          // Take user to the profile of the person they melted with
          final metadata = _parseMetadata(data);
          final userId = metadata?['userId'] as String? ??
              data?['userId'] as String? ??
              metadata?['senderId'] as String? ??
              data?['senderId'] as String?;
          if (userId != null && userId.isNotEmpty) {
            await _navigateToUserProfile(userId, context);
          } else {
            await _navigateToMeltMetal(data, context);
          }
          break;
        }
      case PushType.profileLiked:
      case PushType.meltRequest:
        final senderId = data?['senderId'] as String?;
        if (senderId != null && senderId.isNotEmpty) {
          await _navigateToUserProfile(senderId, context);
        } else {
          await _navigateToHome(context);
        }
        break;
      case PushType.sparksSent:
        await _navigateToSparks(context);
        break;
      case PushType.referralJoined:
        await _navigateToReferral(context);
        break;
      case PushType.thought_created:
      case PushType.reaction_added:
      case PushType.comment:
      case PushType.comment_reaction:
        await _navigateToThoughtDetails(data, context);
        break;
      case PushType.community_post:
        await _navigateToCommunityPost(data, context);
        break;
      case PushType.community_join:
        await _navigateToCommunity(data, context);
        break;
      case PushType.sparks_transaction:
        await _navigateToSparks(context);
        break;
      case PushType.thought_reminder:
        await _navigateToPostThought(context);
        break;
      case PushType.meetup_created:
      case PushType.meetup_invite:
      case PushType.meetup_reminder:
      case PushType.meetup_rsvp_update:
      case PushType.meetup_capacity_reached:
      case PushType.meetupRsvpDeclined:
        await _navigateToMeetup(data, context);
        break;
      case PushType.promptReaction:
      case PushType.directMessage:
        await _navigateToChat(data, context);
        break;
    }
  }

  /// Map NotificationType to PushType
  PushType? _mapNotificationTypeToPushType(NotificationType type) {
    switch (type) {
      case NotificationType.profileLiked:
        return PushType.reaction_added;
      case NotificationType.melted:
        return PushType.new_connection;
      case NotificationType.meltRequest:
        return PushType.new_connection;
      case NotificationType.unmetalRequest:
      case NotificationType.unmetalAcceptance:
        return PushType.unmetalRequest;
      case NotificationType.sparksSent:
        return PushType.sparks_transaction;
      case NotificationType.referralJoined:
        return null;
      case NotificationType.message:
      case NotificationType.promptReaction:
      case NotificationType.directMessage:
        return PushType.message;
      case NotificationType.comment:
      case NotificationType.thoughtReaction:
      case NotificationType.thoughtComment:
      case NotificationType.thoughtRepost:
        return PushType.comment;
      case NotificationType.thoughtCreated:
        return PushType.thought_created;
      case NotificationType.communityPost:
        return PushType.community_post;
      case NotificationType.meetupCreated:
        return PushType.meetup_created;
      case NotificationType.meetupInvite:
        return PushType.meetup_invite;
      case NotificationType.meetupReminder:
        return PushType.meetup_reminder;
      case NotificationType.meetupRsvpUpdate:
      case NotificationType.meetupRsvpDeclined:
        return PushType.meetup_rsvp_update;
      case NotificationType.meetupCapacityReached:
        return PushType.meetup_capacity_reached;
      case NotificationType.unmetalRequiresMoreTime:
        return PushType.unmetalRequest;
      case NotificationType.thoughtReminder:
        return PushType.thought_reminder;
      case NotificationType.system:
        return null;
    }
  }

  /// Parse metadata from data (handles both String and Map)
  Map<String, dynamic>? _parseMetadata(Map<String, dynamic>? data) {
    final metadata = data?["metadata"];
    if (metadata is String) {
      try {
        return jsonDecode(metadata) as Map<String, dynamic>?;
      } catch (e) {
        return null;
      }
    } else if (metadata is Map<String, dynamic>) {
      return metadata;
    }
    return null;
  }

  /// Safe navigation with fallback
  Future<void> _safeNavigate(
    BuildContext context,
    String routeName,
    dynamic arguments,
    Future<void> Function(BuildContext) fallback,
  ) async {
    try {
      Navigator.pushNamed(context, routeName, arguments: arguments);
    } catch (e) {
      await fallback(context);
    }
  }

  /// Navigate to chat window
  Future<void> _navigateToChat(
      Map<String, dynamic>? data, BuildContext context) async {
    final metadata = _parseMetadata(data);
    final connectionId =
        metadata?['connectionId'] ?? data?['connectionId'] as String?;
    final chatId = data?['chatId'] as String?;

    if (connectionId != null || chatId != null) {
      await _safeNavigate(
        context,
        AppRoutes.chatWindowView,
        connectionId ?? chatId,
        _navigateToMessages,
      );
    } else {
      await _navigateToMessages(context);
    }
  }

  /// Navigate to melt metal page
  /// Requires userId (other user) for display; connectionId for chat navigation.
  /// When userId is missing, falls back to chat (connection shows other user's name).
  Future<void> _navigateToMeltMetal(
      Map<String, dynamic>? data, BuildContext context) async {
    final metadata = _parseMetadata(data);
    final connectionId = metadata?['connectionId'] ??
        data?['connectionId'] as String? ??
        data?['otherUserId'] as String?;
    final userId = metadata?['userId'] as String? ??
        data?['userId'] as String? ??
        metadata?['senderId'] as String? ??
        data?['senderId'] as String?;

    if (connectionId != null && connectionId.isNotEmpty) {
      if (userId != null && userId.isNotEmpty) {
        await _safeNavigate(
          context,
          AppRoutes.meltMetal,
          {'userId': userId, 'connectionId': connectionId},
          _navigateToHome,
        );
      } else {
        await _navigateToChat(data, context);
      }
    } else {
      await _navigateToHome(context);
    }
  }

  /// Navigate to thought details
  Future<void> _navigateToThoughtDetails(
      Map<String, dynamic>? data, BuildContext context) async {
    final metadata = _parseMetadata(data);
    final thoughtId = metadata?['thoughtId'] ?? data?['thoughtId'] as String?;
    final commentId = metadata?['commentId'] ?? data?['commentId'] as String?;

    if (thoughtId != null && thoughtId.isNotEmpty) {
      // Create navigation arguments that include comment info
      final navigationArgs = {
        'thoughtId': thoughtId,
        'commentId': commentId,
        'openComments':
            commentId != null, // Open comments if there's a specific comment
      };

      await _safeNavigate(
        context,
        AppRoutes.thoughtDetails,
        navigationArgs,
        _navigateToHome,
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

  /// navigate to post thought page
  Future<void> _navigateToPostThought(BuildContext context) async {
    Navigator.pushNamed(context, AppRoutes.postThought);
  }

  /// Navigate to community post (community feed)
  Future<void> _navigateToCommunityPost(
      Map<String, dynamic>? data, BuildContext context) async {
    final metadata = _parseMetadata(data);
    final thoughtId = metadata?['thoughtId'] ?? data?['thoughtId'] as String?;
    final communityId =
        metadata?['communityId'] ?? data?['communityId'] as String?;

    if (thoughtId != null && thoughtId.isNotEmpty) {
      // Navigate to thought details
      await _navigateToThoughtDetails(data, context);
    } else if (communityId != null && communityId.isNotEmpty) {
      // Navigate to community details
      await _safeNavigate(
        context,
        AppRoutes.communityDetails,
        communityId,
        _navigateToHome,
      );
    } else {
      await _navigateToHome(context);
    }
  }

  /// Navigate to community (community profile)
  Future<void> _navigateToCommunity(
      Map<String, dynamic>? data, BuildContext context) async {
    final metadata = _parseMetadata(data);
    final communityId =
        metadata?['communityId'] ?? data?['communityId'] as String?;

    if (communityId != null && communityId.isNotEmpty) {
      await _safeNavigate(
        context,
        AppRoutes.communityDetails,
        communityId,
        _navigateToHome,
      );
    } else {
      await _navigateToHome(context);
    }
  }

  /// Navigate to user profile
  Future<void> _navigateToUserProfile(
      String userId, BuildContext context) async {
    if (userId.isNotEmpty) {
      await _safeNavigate(
        context,
        AppRoutes.userProfile,
        userId,
        _navigateToHome,
      );
    } else {
      await _navigateToHome(context);
    }
  }

  /// Navigate to referral page
  Future<void> _navigateToReferral(BuildContext context) async {
    await _safeNavigate(
      context,
      AppRoutes.referEarn,
      null,
      _navigateToHome,
    );
  }

  /// Navigate to meetup details
  Future<void> _navigateToMeetup(
      Map<String, dynamic>? data, BuildContext context) async {
    final metadata = _parseMetadata(data);
    final meetupId = metadata?['meetupId'] ?? data?['meetupId'] as String?;

    if (meetupId != null && meetupId.isNotEmpty) {
      await _safeNavigate(
        context,
        AppRoutes.meetupDetails,
        meetupId,
        _navigateToHome,
      );
    } else {
      await _navigateToHome(context);
    }
  }
}
