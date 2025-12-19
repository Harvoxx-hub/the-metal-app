/// Notification type enumeration
enum NotificationType {
  match,
  message,
  like,
  comment,
  spark,
  system;

  String get value {
    switch (this) {
      case NotificationType.match:
        return 'match';
      case NotificationType.message:
        return 'message';
      case NotificationType.like:
        return 'like';
      case NotificationType.comment:
        return 'comment';
      case NotificationType.spark:
        return 'spark';
      case NotificationType.system:
        return 'system';
    }
  }

  static NotificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'match':
        return NotificationType.match;
      case 'message':
        return NotificationType.message;
      case 'like':
        return NotificationType.like;
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

/// Notification DTO
class NotificationDto {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final bool isRead;
  final String? senderId;
  final String? senderName;
  final String? senderPhoto;
  final String? relatedId;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  NotificationDto({
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
}

/// Notifications list response DTO
class NotificationsResponseDto {
  final List<NotificationDto> notifications;
  final int total;
  final int unreadCount;
  final bool hasMore;
  final String? nextCursor;

  NotificationsResponseDto({
    required this.notifications,
    required this.total,
    required this.unreadCount,
    required this.hasMore,
    this.nextCursor,
  });
}

/// Notification settings DTO
class NotificationSettingsDto {
  final bool matchNotifications;
  final bool messageNotifications;
  final bool likeNotifications;
  final bool commentNotifications;
  final bool sparkNotifications;
  final bool emailNotifications;
  final bool pushNotifications;

  NotificationSettingsDto({
    required this.matchNotifications,
    required this.messageNotifications,
    required this.likeNotifications,
    required this.commentNotifications,
    required this.sparkNotifications,
    required this.emailNotifications,
    required this.pushNotifications,
  });

  NotificationSettingsDto copyWith({
    bool? matchNotifications,
    bool? messageNotifications,
    bool? likeNotifications,
    bool? commentNotifications,
    bool? sparkNotifications,
    bool? emailNotifications,
    bool? pushNotifications,
  }) {
    return NotificationSettingsDto(
      matchNotifications: matchNotifications ?? this.matchNotifications,
      messageNotifications: messageNotifications ?? this.messageNotifications,
      likeNotifications: likeNotifications ?? this.likeNotifications,
      commentNotifications: commentNotifications ?? this.commentNotifications,
      sparkNotifications: sparkNotifications ?? this.sparkNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchNotifications': matchNotifications,
      'messageNotifications': messageNotifications,
      'likeNotifications': likeNotifications,
      'commentNotifications': commentNotifications,
      'sparkNotifications': sparkNotifications,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
    };
  }
}
