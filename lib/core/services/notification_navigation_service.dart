import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:metal/fcm/models/notification_payload_model.dart';
import 'package:metal/fcm/models/push_type.dart';
import 'package:metal/features/notification/domain/entries/notification.model.dart';
import 'package:metal/features/community/data/domain/entries/community.model.dart';
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
    NotificationModel notification,
    BuildContext context,
  ) async {
    if (!context.mounted) return;

    final data = notification.data as Map<String, dynamic>?;
    final pushType = _mapNotificationTypeToPushType(notification.type);

    await _handleNavigation(pushType, data, context);
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
        await _navigateToChat(data, context);
        break;
      case PushType.unmetal_request:
        await _navigateToChat(data, context);
        break;
      case PushType.new_connection:
        await _navigateToMeltMetal(data, context);
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
    }
  }

  /// Map NotificationType to PushType
  PushType? _mapNotificationTypeToPushType(NotificationType type) {
    switch (type) {
      case NotificationType.new_message:
        return PushType.message;
      case NotificationType.new_connection:
        return PushType.new_connection;
      case NotificationType.unmetal_request:
        return PushType.unmetal_request;
      case NotificationType.thought_created:
        return PushType.thought_created;
      case NotificationType.reaction_added:
        return PushType.reaction_added;
      case NotificationType.comment:
        return PushType.comment;
      case NotificationType.comment_reaction:
        return PushType.comment_reaction;
      case NotificationType.sparks_transaction:
        return PushType.sparks_transaction;
      case NotificationType.thought_reminder:
        return PushType.thought_reminder;
      case NotificationType.community_post:
        return PushType.community_post;
      case NotificationType.community_join:
        return PushType.community_join;
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
        AppRoutes.chatWindowsPage,
        connectionId ?? chatId,
        _navigateToMessages,
      );
    } else {
      await _navigateToMessages(context);
    }
  }

  /// Navigate to melt metal page
  Future<void> _navigateToMeltMetal(
      Map<String, dynamic>? data, BuildContext context) async {
    final metadata = _parseMetadata(data);
    final connectionId = metadata?['connectionId'] ??
        data?['connectionId'] as String? ??
        data?['otherUserId'] as String?;

    if (connectionId != null && connectionId.isNotEmpty) {
      await _safeNavigate(
        context,
        AppRoutes.meltMetal,
        connectionId,
        _navigateToHome,
      );
    } else {
      await _navigateToHome(context);
    }
  }

  /// Navigate to thought details
  Future<void> _navigateToThoughtDetails(
      Map<String, dynamic>? data, BuildContext context) async {
    final metadata = _parseMetadata(data);
    final thoughtId = metadata?['thoughtId'] ?? data?['thoughtId'] as String?;

    if (thoughtId != null && thoughtId.isNotEmpty) {
      await _safeNavigate(
        context,
        AppRoutes.thoughtDetails,
        thoughtId,
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
    final communityId =
        metadata?['communityId'] ?? data?['communityId'] as String?;
    final thoughtId = metadata?['thoughtId'] ?? data?['thoughtId'] as String?;

    if (communityId != null && communityId.isNotEmpty) {
      // Navigate to community profile which shows the feed
      await _safeNavigate(
        context,
        AppRoutes.communityProfile,
        CommunityModel(
          id: communityId,
          name: metadata?['communityName'] ??
              data?['communityName'] ??
              'Community',
          description: '',
          creatorId: '',
          creatorName: '',
          memberCount: 0,
          isPublic: true,
          tags: [],
          createdAt: '',
        ),
        _navigateToHome,
      );
    } else if (thoughtId != null && thoughtId.isNotEmpty) {
      // Fallback: navigate to thought details if communityId is missing
      await _navigateToThoughtDetails(data, context);
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
      // Navigate to community profile
      await _safeNavigate(
        context,
        AppRoutes.communityProfile,
        CommunityModel(
          id: communityId,
          name: metadata?['communityName'] ??
              data?['communityName'] ??
              'Community',
          description: '',
          creatorId: '',
          creatorName: '',
          memberCount: 0,
          isPublic: true,
          tags: [],
          createdAt: '',
        ),
        _navigateToHome,
      );
    } else {
      await _navigateToHome(context);
    }
  }
}
