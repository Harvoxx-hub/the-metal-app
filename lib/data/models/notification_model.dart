import 'package:metal/domain/entities/notification_dto.dart';

/// Notification model for API responses (user, content, badge, actions, title, message, senderId)
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
  final String? category;
  final String? notificationType;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? content;
  final Map<String, dynamic>? badge;
  final List<dynamic>? actions;
  final Map<String, dynamic>? metadata;

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
    this.category,
    this.notificationType,
    this.user,
    this.content,
    this.badge,
    this.actions,
    this.metadata,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final contentObj = json['content'];
    String message = json['message'] as String? ??
        json['body'] as String? ??
        json['subTitle'] as String? ??
        '';
    if (contentObj is Map<String, dynamic>) {
      final contentMsg =
          contentObj['message'] as String? ?? contentObj['body'] as String?;
      if (contentMsg != null) message = contentMsg;
    }
    final isRead = json['isRead'] as bool? ?? false;
    final actionsData = json['actions'];
    List<dynamic>? actionsList;
    if (actionsData is Map && actionsData['buttons'] != null) {
      actionsList = (actionsData['buttons'] as List?)?.cast<dynamic>();
    }

    // Single time field: createdAt only
    final createdAtRaw = json['createdAt'];
    final createdAt = _parseCreatedAt(createdAtRaw);

    // Map melt-like notifications to melted type (handles metal-function new_connection and system)
    final rawType = json['type'] as String? ?? 'system';
    final title = (json['title'] as String? ?? '').toLowerCase();
    final msg = message.toLowerCase();
    final isMeltLike = title.contains('melt') ||
        title.contains('match') ||
        msg.contains('melt') ||
        msg.contains('match');
    final type =
        ((rawType == 'system' || rawType == 'new_connection') && isMeltLike)
            ? 'melted'
            : rawType;

    return NotificationModel(
      id: json['id'] as String? ?? '',
      type: type,
      title: json['title'] as String? ?? '',
      message: message,
      isRead: isRead,
      senderId: json['senderId'] as String?,
      senderName: json['senderName'] as String?,
      senderPhoto: json['senderPhoto'] as String?,
      relatedId: json['relatedId'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: createdAt,
      category: json['category'] as String?,
      notificationType: json['notificationType'] as String?,
      user: json['user'] as Map<String, dynamic>?,
      content: contentObj as Map<String, dynamic>?,
      badge: json['badge'] as Map<String, dynamic>?,
      actions: actionsList,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  static String _parseCreatedAt(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) {
      final secs = value['_seconds'] as int? ?? value['seconds'] as int?;
      final nsecs =
          value['_nanoseconds'] as int? ?? value['nanoseconds'] as int? ?? 0;
      if (secs != null) {
        return DateTime.fromMillisecondsSinceEpoch(
          secs * 1000 + (nsecs / 1e6).round(),
        ).toIso8601String();
      }
    }
    return value.toString();
  }

  NotificationDto toDomain() {
    NotificationUserDto? userDto;
    final userId = user?['id']?.toString().trim() ?? '';
    if (user != null && userId.isNotEmpty) {
      userDto = NotificationUserDto.fromJson(user);
    }

    NotificationContentDto? contentDto;
    if (content != null) {
      contentDto = NotificationContentDto.fromJson(content);
    } else {
      contentDto = NotificationContentDto(message: message);
    }

    NotificationBadgeDto? badgeDto;
    if (badge != null) {
      badgeDto = NotificationBadgeDto.fromJson(badge);
    }

    List<NotificationActionButtonDto>? actionButtons;
    if (actions != null && actions!.isNotEmpty) {
      actionButtons = actions!
          .map((e) =>
              NotificationActionButtonDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final mergedMetadata = <String, dynamic>{
      ...?data,
      ...?metadata,
      if (relatedId != null) 'relatedId': relatedId,
      if (senderId != null) 'senderId': senderId,
    };

    return NotificationDto(
      id: id,
      type: NotificationType.fromString(type),
      title: title,
      message: contentDto.message,
      isRead: isRead,
      senderId: userDto?.id ?? senderId,
      senderName: userDto?.username ?? senderName,
      senderPhoto: userDto?.avatarUrl ?? senderPhoto,
      relatedId: relatedId,
      data: data,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      category: category,
      notificationType: notificationType,
      user: userDto,
      content: contentDto,
      badge: badgeDto,
      actions: actionButtons,
      metadata: mergedMetadata.isNotEmpty ? mergedMetadata : null,
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
    final pagination = json['pagination'] as Map<String, dynamic>?;
    final total = pagination?['total'] as int? ?? json['total'] as int? ?? 0;
    final page = pagination?['page'] as int? ?? 1;
    final totalPages = pagination?['totalPages'] as int? ?? 1;

    return NotificationsResponseModel(
      notifications: (json['notifications'] as List<dynamic>?)
              ?.map(
                  (e) => NotificationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: total,
      unreadCount: json['unreadCount'] as int? ?? 0,
      hasMore: page < totalPages,
      nextCursor: json['nextCursor'] as String?,
      currentPage: page,
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

  NotificationSettingsModel({
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

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      likeNotifications: json['likeNotifications'] as bool? ?? true,
      superlikeNotifications: json['superlikeNotifications'] as bool? ?? true,
      matchNotifications: json['matchNotifications'] as bool? ?? true,
      meltRequestNotifications:
          json['meltRequestNotifications'] as bool? ?? true,
      unmetalRequestedNotifications:
          json['unmetalRequestedNotifications'] as bool? ?? true,
      unmetalAcceptedNotifications:
          json['unmetalAcceptedNotifications'] as bool? ?? true,
      sparkNotifications: json['sparkNotifications'] as bool? ?? true,
      referralNotifications: json['referralNotifications'] as bool? ?? true,
      messageNotifications: json['messageNotifications'] as bool? ?? true,
      commentNotifications: json['commentNotifications'] as bool? ?? true,
      emailNotifications: json['emailNotifications'] as bool? ?? false,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
    );
  }

  NotificationSettingsDto toDomain() {
    return NotificationSettingsDto(
      likeNotifications: likeNotifications,
      superlikeNotifications: superlikeNotifications,
      matchNotifications: matchNotifications,
      meltRequestNotifications: meltRequestNotifications,
      unmetalRequestedNotifications: unmetalRequestedNotifications,
      unmetalAcceptedNotifications: unmetalAcceptedNotifications,
      sparkNotifications: sparkNotifications,
      referralNotifications: referralNotifications,
      messageNotifications: messageNotifications,
      commentNotifications: commentNotifications,
      emailNotifications: emailNotifications,
      pushNotifications: pushNotifications,
    );
  }
}
