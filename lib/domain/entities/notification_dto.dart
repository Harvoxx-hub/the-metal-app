/// Notification type enumeration
enum NotificationType {
  // Profile interactions
  like, // When someone likes your profile
  superlike, // When someone superlikes your profile
  // Melt/Connection
  match, // When you melt with someone (mutual connection)
  meltRequest, // When someone sends you a melt request
  // Unmelt
  unmetalRequested, // When someone requested to get unmetal (reveal identities)
  unmetalAccepted, // When a user accepts your unmetal request
  // Sparks
  spark, // When someone sends you a spark
  // Referral
  referral, // When someone uses your referral code to join
  // Other
  message, // When someone sends you a message
  comment, // When someone comments on your thought
  system; // System notifications

  String get value {
    switch (this) {
      case NotificationType.like:
        return 'like';
      case NotificationType.superlike:
        return 'superlike';
      case NotificationType.match:
        return 'match';
      case NotificationType.meltRequest:
        return 'melt_request';
      case NotificationType.unmetalRequested:
        return 'unmetal_requested';
      case NotificationType.unmetalAccepted:
        return 'unmetal_accepted';
      case NotificationType.spark:
        return 'spark';
      case NotificationType.referral:
        return 'referral';
      case NotificationType.message:
        return 'message';
      case NotificationType.comment:
        return 'comment';
      case NotificationType.system:
        return 'system';
    }
  }

  static NotificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'like':
        return NotificationType.like;
      case 'superlike':
      case 'super_like':
        return NotificationType.superlike;
      case 'match':
        return NotificationType.match;
      case 'melt_request':
      case 'meltrequest':
        return NotificationType.meltRequest;
      case 'unmetal_requested':
      case 'unmetalrequested':
        return NotificationType.unmetalRequested;
      case 'unmetal_accepted':
      case 'unmetalaccepted':
        return NotificationType.unmetalAccepted;
      case 'spark':
        return NotificationType.spark;
      case 'referral':
        return NotificationType.referral;
      case 'message':
        return NotificationType.message;
      case 'comment':
        return NotificationType.comment;
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

  NotificationDto copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    bool? isRead,
    String? senderId,
    String? senderName,
    String? senderPhoto,
    String? relatedId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
  }) {
    return NotificationDto(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderPhoto: senderPhoto ?? this.senderPhoto,
      relatedId: relatedId ?? this.relatedId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Notifications list response DTO
class NotificationsResponseDto {
  final List<NotificationDto> notifications;
  final int total;
  final int unreadCount;
  final bool hasMore;
  final String? nextCursor;
  final int? currentPage;

  NotificationsResponseDto({
    required this.notifications,
    required this.total,
    required this.unreadCount,
    required this.hasMore,
    this.nextCursor,
    this.currentPage,
  });
}

/// Notification settings DTO
class NotificationSettingsDto {
  final bool likeNotifications;
  final bool superlikeNotifications;
  final bool matchNotifications;
  final bool meltRequestNotifications;
  final bool unmetalRequestedNotifications;
  final bool unmetalAcceptedNotifications;
  final bool sparkNotifications;
  final bool referralNotifications;
  final bool messageNotifications;
  final bool commentNotifications;
  final bool emailNotifications;
  final bool pushNotifications;

  NotificationSettingsDto({
    required this.likeNotifications,
    required this.superlikeNotifications,
    required this.matchNotifications,
    required this.meltRequestNotifications,
    required this.unmetalRequestedNotifications,
    required this.unmetalAcceptedNotifications,
    required this.sparkNotifications,
    required this.referralNotifications,
    required this.messageNotifications,
    required this.commentNotifications,
    required this.emailNotifications,
    required this.pushNotifications,
  });

  NotificationSettingsDto copyWith({
    bool? likeNotifications,
    bool? superlikeNotifications,
    bool? matchNotifications,
    bool? meltRequestNotifications,
    bool? unmetalRequestedNotifications,
    bool? unmetalAcceptedNotifications,
    bool? sparkNotifications,
    bool? referralNotifications,
    bool? messageNotifications,
    bool? commentNotifications,
    bool? emailNotifications,
    bool? pushNotifications,
  }) {
    return NotificationSettingsDto(
      likeNotifications: likeNotifications ?? this.likeNotifications,
      superlikeNotifications:
          superlikeNotifications ?? this.superlikeNotifications,
      matchNotifications: matchNotifications ?? this.matchNotifications,
      meltRequestNotifications:
          meltRequestNotifications ?? this.meltRequestNotifications,
      unmetalRequestedNotifications:
          unmetalRequestedNotifications ?? this.unmetalRequestedNotifications,
      unmetalAcceptedNotifications:
          unmetalAcceptedNotifications ?? this.unmetalAcceptedNotifications,
      sparkNotifications: sparkNotifications ?? this.sparkNotifications,
      referralNotifications:
          referralNotifications ?? this.referralNotifications,
      messageNotifications: messageNotifications ?? this.messageNotifications,
      commentNotifications: commentNotifications ?? this.commentNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'likeNotifications': likeNotifications,
      'superlikeNotifications': superlikeNotifications,
      'matchNotifications': matchNotifications,
      'meltRequestNotifications': meltRequestNotifications,
      'unmetalRequestedNotifications': unmetalRequestedNotifications,
      'unmetalAcceptedNotifications': unmetalAcceptedNotifications,
      'sparkNotifications': sparkNotifications,
      'referralNotifications': referralNotifications,
      'messageNotifications': messageNotifications,
      'commentNotifications': commentNotifications,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
    };
  }
}
