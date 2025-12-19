import 'package:metal/domain/entities/notification_dto.dart';

/// Notification model for API responses
class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String? senderId;
  final String? senderName;
  final String? senderPhoto;
  final String? relatedId;
  final Map<String, dynamic>? data;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.senderId,
    this.senderName,
    this.senderPhoto,
    this.relatedId,
    this.data,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'system',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      senderId: json['senderId'] as String?,
      senderName: json['senderName'] as String?,
      senderPhoto: json['senderPhoto'] as String?,
      relatedId: json['relatedId'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  NotificationDto toDomain() {
    return NotificationDto(
      id: id,
      type: NotificationType.fromString(type),
      title: title,
      message: message,
      isRead: isRead,
      senderId: senderId,
      senderName: senderName,
      senderPhoto: senderPhoto,
      relatedId: relatedId,
      data: data,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}

/// Notifications list response model
class NotificationsResponseModel {
  final List<NotificationModel> notifications;
  final int total;
  final int unreadCount;
  final bool hasMore;
  final String? nextCursor;
  final int? currentPage;

  NotificationsResponseModel({
    required this.notifications,
    required this.total,
    required this.unreadCount,
    required this.hasMore,
    this.nextCursor,
    this.currentPage,
  });

  factory NotificationsResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationsResponseModel(
      notifications: (json['notifications'] as List<dynamic>?)
              ?.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      unreadCount: json['unreadCount'] as int? ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
      nextCursor: json['nextCursor'] as String?,
      currentPage: json['currentPage'] as int?,
    );
  }

  NotificationsResponseDto toDomain() {
    return NotificationsResponseDto(
      notifications: notifications.map((e) => e.toDomain()).toList(),
      total: total,
      unreadCount: unreadCount,
      hasMore: hasMore,
      nextCursor: nextCursor,
      currentPage: currentPage,
    );
  }
}

/// Notification settings model
class NotificationSettingsModel {
  final bool matchNotifications;
  final bool messageNotifications;
  final bool likeNotifications;
  final bool commentNotifications;
  final bool sparkNotifications;
  final bool emailNotifications;
  final bool pushNotifications;

  NotificationSettingsModel({
    required this.matchNotifications,
    required this.messageNotifications,
    required this.likeNotifications,
    required this.commentNotifications,
    required this.sparkNotifications,
    required this.emailNotifications,
    required this.pushNotifications,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      matchNotifications: json['matchNotifications'] as bool? ?? true,
      messageNotifications: json['messageNotifications'] as bool? ?? true,
      likeNotifications: json['likeNotifications'] as bool? ?? true,
      commentNotifications: json['commentNotifications'] as bool? ?? true,
      sparkNotifications: json['sparkNotifications'] as bool? ?? true,
      emailNotifications: json['emailNotifications'] as bool? ?? false,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
    );
  }

  NotificationSettingsDto toDomain() {
    return NotificationSettingsDto(
      matchNotifications: matchNotifications,
      messageNotifications: messageNotifications,
      likeNotifications: likeNotifications,
      commentNotifications: commentNotifications,
      sparkNotifications: sparkNotifications,
      emailNotifications: emailNotifications,
      pushNotifications: pushNotifications,
    );
  }
}
