import 'package:metal/domain/entities/base_entity.dart';

/// Notification types
enum NotificationType {
  melt,
  unmelt,
  message,
  thought,
  reaction,
  comment,
  spark,
  system,
}

/// Notification domain entity (DTO)
class NotificationDto extends BaseEntity {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final String? senderId;
  final String? senderName;
  final String? senderPhoto;
  final String? targetId; // ID of thought, message, connection, etc.
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const NotificationDto({
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

  NotificationDto copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    bool? isRead,
    String? senderId,
    String? senderName,
    String? senderPhoto,
    String? targetId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return NotificationDto(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderPhoto: senderPhoto ?? this.senderPhoto,
      targetId: targetId ?? this.targetId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Notifications list response DTO
class NotificationsResponseDto extends BaseEntity {
  final List<NotificationDto> notifications;
  final int unreadCount;
  final bool hasMore;
  final int? currentPage;
  final int? totalPages;

  const NotificationsResponseDto({
    required this.notifications,
    required this.unreadCount,
    required this.hasMore,
    this.currentPage,
    this.totalPages,
  });
}

/// Notification settings DTO
class NotificationSettingsDto extends BaseEntity {
  final bool pushEnabled;
  final bool meltNotifications;
  final bool messageNotifications;
  final bool thoughtNotifications;
  final bool sparkNotifications;

  const NotificationSettingsDto({
    required this.pushEnabled,
    required this.meltNotifications,
    required this.messageNotifications,
    required this.thoughtNotifications,
    required this.sparkNotifications,
  });

  NotificationSettingsDto copyWith({
    bool? pushEnabled,
    bool? meltNotifications,
    bool? messageNotifications,
    bool? thoughtNotifications,
    bool? sparkNotifications,
  }) {
    return NotificationSettingsDto(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      meltNotifications: meltNotifications ?? this.meltNotifications,
      messageNotifications: messageNotifications ?? this.messageNotifications,
      thoughtNotifications: thoughtNotifications ?? this.thoughtNotifications,
      sparkNotifications: sparkNotifications ?? this.sparkNotifications,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushEnabled': pushEnabled,
      'meltNotifications': meltNotifications,
      'messageNotifications': messageNotifications,
      'thoughtNotifications': thoughtNotifications,
      'sparkNotifications': sparkNotifications,
    };
  }
}
