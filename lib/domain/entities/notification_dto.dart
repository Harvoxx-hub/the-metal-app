/// Notification type enumeration
/// Maps to backend types (profile_liked, melted, sparks_sent, etc.)
enum NotificationType {
  profileLiked,
  melted,
  sparksSent,
  referralJoined,
  unmetalAcceptance,
  unmetalRequiresMoreTime,
  unmetalRequest,
  meltRequest,
  meetupInvite,
  meetupReminder,
  meetupRsvpDeclined,
  meetupRsvpUpdate,
  meetupCreated,
  message,
  promptReaction,
  directMessage,
  comment,
  meetupCapacityReached,
  system;

  // Legacy aliases map to new types
  String get value {
    switch (this) {
      case NotificationType.profileLiked:
        return 'profile_liked';
      case NotificationType.melted:
        return 'melted';
      case NotificationType.sparksSent:
        return 'sparks_sent';
      case NotificationType.referralJoined:
        return 'referral_joined';
      case NotificationType.unmetalAcceptance:
        return 'unmetal_acceptance';
      case NotificationType.unmetalRequiresMoreTime:
        return 'unmetal_requires_more_time';
      case NotificationType.unmetalRequest:
        return 'unmetal_request';
      case NotificationType.meltRequest:
        return 'melt_request';
      case NotificationType.meetupInvite:
        return 'meetup_invite';
      case NotificationType.meetupReminder:
        return 'meetup_reminder';
      case NotificationType.meetupRsvpDeclined:
        return 'meetup_rsvp_declined';
      case NotificationType.meetupRsvpUpdate:
        return 'meetup_rsvp_update';
      case NotificationType.meetupCreated:
        return 'meetup_created';
      case NotificationType.message:
        return 'message';
      case NotificationType.promptReaction:
        return 'prompt_reaction';
      case NotificationType.directMessage:
        return 'direct_message';
      case NotificationType.comment:
        return 'comment';
      case NotificationType.meetupCapacityReached:
        return 'meetup_capacity_reached';
      case NotificationType.system:
        return 'system';
    }
  }

  static NotificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'profile_liked':
      case 'like':
      case 'superlike':
        return NotificationType.profileLiked;
      case 'melted':
      case 'match':
        return NotificationType.melted;
      case 'sparks_sent':
      case 'spark':
        return NotificationType.sparksSent;
      case 'referral_joined':
      case 'referral':
        return NotificationType.referralJoined;
      case 'unmetal_acceptance':
      case 'unmetal_accepted':
        return NotificationType.unmetalAcceptance;
      case 'unmetal_requires_more_time':
        return NotificationType.unmetalRequiresMoreTime;
      case 'unmetal_request':
      case 'unmetal_requested':
        return NotificationType.unmetalRequest;
      case 'melt_request':
        return NotificationType.meltRequest;
      case 'meetup_invite':
        return NotificationType.meetupInvite;
      case 'meetup_reminder':
        return NotificationType.meetupReminder;
      case 'meetup_rsvp_declined':
        return NotificationType.meetupRsvpDeclined;
      case 'meetup_rsvp_update':
        return NotificationType.meetupRsvpUpdate;
      case 'meetup_created':
        return NotificationType.meetupCreated;
      case 'message':
        return NotificationType.message;
      case 'prompt_reaction':
        return NotificationType.promptReaction;
      case 'direct_message':
        return NotificationType.directMessage;
      case 'comment':
        return NotificationType.comment;
      case 'meetup_capacity_reached':
        return NotificationType.meetupCapacityReached;
      default:
        return NotificationType.system;
    }
  }

  bool get isActionable {
    return [
      NotificationType.unmetalAcceptance,
      NotificationType.unmetalRequest,
      NotificationType.meltRequest,
      NotificationType.meetupInvite,
      NotificationType.meetupReminder,
    ].contains(this);
  }
}

/// Notification user (sender)
class NotificationUserDto {
  final String id;
  final String? username;
  final String? avatarUrl;

  NotificationUserDto({
    required this.id,
    this.username,
    this.avatarUrl,
  });

  factory NotificationUserDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return NotificationUserDto(id: '');
    return NotificationUserDto(
      id: json['id'] as String? ?? '',
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
    );
  }
}

/// Inline action in notification content
class NotificationInlineActionDto {
  final String text;
  final String action;

  NotificationInlineActionDto({required this.text, required this.action});

  factory NotificationInlineActionDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return NotificationInlineActionDto(text: '', action: '');
    return NotificationInlineActionDto(
      text: json['text'] as String? ?? '',
      action: json['action'] as String? ?? '',
    );
  }
}

/// Notification content
class NotificationContentDto {
  final String message;
  final String? secondaryMessage;
  final NotificationInlineActionDto? inlineAction;

  NotificationContentDto({
    required this.message,
    this.secondaryMessage,
    this.inlineAction,
  });

  factory NotificationContentDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return NotificationContentDto(message: '');
    return NotificationContentDto(
      message: json['message'] as String? ?? json['body'] as String? ?? json['subTitle'] as String? ?? '',
      secondaryMessage: json['secondaryMessage'] as String? ?? json['subTitle'] as String?,
      inlineAction: json['inlineAction'] != null
          ? NotificationInlineActionDto.fromJson(
              json['inlineAction'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Notification badge
class NotificationBadgeDto {
  final String type;
  final String variant;

  NotificationBadgeDto({required this.type, required this.variant});

  factory NotificationBadgeDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return NotificationBadgeDto(type: 'checkmark', variant: 'success');
    return NotificationBadgeDto(
      type: json['type'] as String? ?? 'checkmark',
      variant: json['variant'] as String? ?? 'success',
    );
  }
}

/// Action button for actionable notifications
class NotificationActionButtonDto {
  final String id;
  final String text;
  final String style;
  final String variant;
  final String action;

  NotificationActionButtonDto({
    required this.id,
    required this.text,
    required this.style,
    required this.variant,
    required this.action,
  });

  factory NotificationActionButtonDto.fromJson(Map<String, dynamic> json) {
    return NotificationActionButtonDto(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      style: json['style'] as String? ?? 'filled',
      variant: json['variant'] as String? ?? 'primary',
      action: json['action'] as String? ?? '',
    );
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
  final String? category;
  final String? notificationType;
  final NotificationUserDto? user;
  final NotificationContentDto? content;
  final NotificationBadgeDto? badge;
  final List<NotificationActionButtonDto>? actions;
  final Map<String, dynamic>? metadata;

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
    this.category,
    this.notificationType,
    this.user,
    this.content,
    this.badge,
    this.actions,
    this.metadata,
  });

  String get displayMessage {
    final fromContent = content?.message;
    if (fromContent != null && fromContent.isNotEmpty) return fromContent;
    if (message.isNotEmpty) return message;
    return title;
  }
  String? get secondaryMessage => content?.secondaryMessage;
  NotificationUserDto? get senderUser => user;
  String get effectiveSenderId => user?.id ?? senderId ?? '';
  String get effectiveSenderName => user?.username ?? senderName ?? 'Someone';
  String? get effectiveSenderPhoto => user?.avatarUrl ?? senderPhoto;

  String? get connectionId => metadata?['connectionId'] as String? ?? data?['connectionId'] as String?;
  String? get meetupId => metadata?['meetupId'] as String? ?? data?['meetupId'] as String?;
  String? get messageId => metadata?['messageId'] as String? ?? data?['messageId'] as String?;

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
      category: category,
      notificationType: notificationType,
      user: user,
      content: content,
      badge: badge,
      actions: actions,
      metadata: metadata,
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
