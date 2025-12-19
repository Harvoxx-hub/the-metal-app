import 'package:metal/data/models/spark_model.dart';
import 'package:metal/domain/entities/notification_dto.dart';

/// Notifications response model from API
class NotificationsResponseModel {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final PaginationModel? pagination;

  NotificationsResponseModel({
    required this.notifications,
    required this.unreadCount,
    this.pagination,
  });

  factory NotificationsResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationsResponseModel(
      notifications: (json['notifications'] as List<dynamic>?)
              ?.map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
              .toList() ??
          [],
      unreadCount: json['unreadCount'] as int? ?? 0,
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert to domain DTO
  NotificationsResponseDto toDomain() {
    return NotificationsResponseDto(
      notifications: notifications.map((n) => n.toDomain()).toList(),
      unreadCount: unreadCount,
      hasMore: pagination?.hasMore ?? false,
      currentPage: pagination?.currentPage,
      totalPages: pagination?.totalPages,
    );
  }
}

/// Notification model
class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final String? senderId;
  final String? senderName;
  final String? senderPhoto;
  final String? targetId;
  final Map<String, dynamic>? metadata;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    this.senderId,
    this.senderName,
    this.senderPhoto,
    this.targetId,
    this.metadata,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      isRead: json['isRead'] as bool? ?? false,
      senderId: json['senderId'] as String?,
      senderName: json['senderName'] as String?,
      senderPhoto: json['senderPhoto'] as String?,
      targetId: json['targetId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] as String,
    );
  }

  /// Convert to domain DTO
  NotificationDto toDomain() {
    return NotificationDto(
      id: id,
      type: _parseNotificationType(type),
      title: title,
      body: body,
      isRead: isRead,
      senderId: senderId,
      senderName: senderName,
      senderPhoto: senderPhoto,
      targetId: targetId,
      metadata: metadata,
      createdAt: DateTime.parse(createdAt),
    );
  }

  NotificationType _parseNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'melt':
        return NotificationType.melt;
      case 'unmelt':
        return NotificationType.unmelt;
      case 'message':
        return NotificationType.message;
      case 'thought':
        return NotificationType.thought;
      case 'reaction':
        return NotificationType.reaction;
      case 'comment':
        return NotificationType.comment;
      case 'spark':
        return NotificationType.spark;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }
}

/// Notification settings model
class NotificationSettingsModel {
  final bool pushEnabled;
  final bool meltNotifications;
  final bool messageNotifications;
  final bool thoughtNotifications;
  final bool sparkNotifications;

  NotificationSettingsModel({
    required this.pushEnabled,
    required this.meltNotifications,
    required this.messageNotifications,
    required this.thoughtNotifications,
    required this.sparkNotifications,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      meltNotifications: json['meltNotifications'] as bool? ?? true,
      messageNotifications: json['messageNotifications'] as bool? ?? true,
      thoughtNotifications: json['thoughtNotifications'] as bool? ?? true,
      sparkNotifications: json['sparkNotifications'] as bool? ?? true,
    );
  }

  /// Convert to domain DTO
  NotificationSettingsDto toDomain() {
    return NotificationSettingsDto(
      pushEnabled: pushEnabled,
      meltNotifications: meltNotifications,
      messageNotifications: messageNotifications,
      thoughtNotifications: thoughtNotifications,
      sparkNotifications: sparkNotifications,
    );
  }
}
