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
      case NotificationType.like:
      case NotificationType.superlike:
        // Navigate to sender's profile
        if (notification.senderId != null) {
          await _navigateToUserProfile(notification.senderId!, context);
        } else {
          await _navigateToHome(context);
        }
        return;
      case NotificationType.meltRequest:
        // Navigate to sender's profile or pending melt requests
        if (notification.senderId != null) {
          await _navigateToUserProfile(notification.senderId!, context);
        } else {
          await _navigateToHome(context);
        }
        return;
      case NotificationType.referral:
        // Navigate to referral page or profile
        await _navigateToReferral(context);
        return;
      default:
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
      case NotificationType.like:
      case NotificationType.superlike:
        return PushType.reaction_added; // Navigate to profile or discovery
      case NotificationType.match:
        return PushType.new_connection; // Navigate to melt screen
      case NotificationType.meltRequest:
        return PushType.new_connection; // Navigate to user profile or pending requests
      case NotificationType.unmetalRequested:
      case NotificationType.unmetalAccepted:
        return PushType.unmetal_request; // Navigate to chat
      case NotificationType.spark:
        return PushType.sparks_transaction; // Navigate to sparks page
      case NotificationType.referral:
        return null; // Navigate to referral/profile page
      case NotificationType.message:
        return PushType.message; // Navigate to chat
      case NotificationType.comment:
        return PushType.comment; // Navigate to thought details
      case NotificationType.system:
        return null; // Navigate to home
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
    final communityId = metadata?['communityId'] ?? data?['communityId'] as String?;

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
    final communityId = metadata?['communityId'] ?? data?['communityId'] as String?;

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
  Future<void> _navigateToUserProfile(String userId, BuildContext context) async {
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
}
