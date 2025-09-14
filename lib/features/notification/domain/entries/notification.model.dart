class NotificationModel {
  final List<String> recipientIds; // List of recipient IDs
  final String title; // Notification title
  final String subTitle; // Notification subtitle

  final NotificationType type; // Enum for notification type
  var data; // Additional data (e.g., connectionId, status)
  final NotificationAndroidNotification
      androidNotification; // Android-specific notification
  final NotificationIosNotification
      iosNotification; // iOS-specific notification
  final DateTime timestamp; // When the notification was sent
  final String id; // Unique ID
  final bool isRead; // New field to track read status

  NotificationModel({
    required this.recipientIds,
    required this.title,
    required this.subTitle,
    required this.type,
    required this.data,
    required this.androidNotification,
    required this.iosNotification,
    required this.timestamp,
    required this.id,
    this.isRead = false, // Default to unread
  });

  // CopyWith method for updating notification properties
  NotificationModel copyWith({
    List<String>? recipientIds,
    String? title,
    String? subTitle,
    NotificationType? type,
    dynamic data,
    NotificationAndroidNotification? androidNotification,
    NotificationIosNotification? iosNotification,
    DateTime? timestamp,
    String? id,
    bool? isRead,
  }) {
    return NotificationModel(
      recipientIds: recipientIds ?? this.recipientIds,
      title: title ?? this.title,
      subTitle: subTitle ?? this.subTitle,
      type: type ?? this.type,
      data: data ?? this.data,
      androidNotification: androidNotification ?? this.androidNotification,
      iosNotification: iosNotification ?? this.iosNotification,
      timestamp: timestamp ?? this.timestamp,
      id: id ?? this.id,
      isRead: isRead ?? this.isRead,
    );
  }

  // Convert a NotificationModel instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'recipientIds': recipientIds,
      'title': title,
      'subTitle': subTitle,
      'type': type.toString().split('.').last, // Serialize enum to string
      'data': data,
      'androidNotification': androidNotification.toJson(),
      'iosNotification': iosNotification.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'id': id,
      'isRead': isRead,
    };
  }

  // Convert a JSON map to a NotificationModel instance
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      recipientIds: List<String>.from(json['recipientIds']),
      title: json['title'],
      subTitle: json['subTitle'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotificationType.new_message, // Default type if not found
      ),
      data: json['data'],
      androidNotification:
          NotificationAndroidNotification.fromJson(json['androidNotification']),
      iosNotification:
          NotificationIosNotification.fromJson(json['iosNotification']),
      timestamp: DateTime.parse(json['timestamp']),
      id: json['id'],
      isRead: json['isRead'] ?? false,
    );
  }

  // Add a method to create a read version of this notification
  NotificationModel markAsRead() {
    return NotificationModel(
      recipientIds: recipientIds,
      title: title,
      subTitle: subTitle,
      type: type,
      data: data,
      androidNotification: androidNotification,
      iosNotification: iosNotification,
      timestamp: timestamp,
      id: id,
      isRead: true,
    );
  }
}

enum NotificationType {
  new_connection,
  new_message,
  unmetal_request,
  thought_created,
  reaction_added,
  sparks_transaction,
  thought_reminder,
  comment,
  comment_reaction
}

class NotificationAndroidNotification {
  final String priority;

  NotificationAndroidNotification({
    required this.priority,
  });

  // Convert a NotificationAndroidNotification instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'priority': priority,
    };
  }

  // Convert a JSON map to a NotificationAndroidNotification instance
  factory NotificationAndroidNotification.fromJson(Map<String, dynamic> json) {
    return NotificationAndroidNotification(
      priority: json['priority'],
    );
  }
}

class NotificationIosNotification {
  final Map<String, String> headers;

  NotificationIosNotification({
    required this.headers,
  });

  // Convert a NotificationIosNotification instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'headers': headers,
    };
  }

  // Convert a JSON map to a NotificationIosNotification instance
  factory NotificationIosNotification.fromJson(Map<String, dynamic> json) {
    return NotificationIosNotification(
      headers: Map<String, String>.from(json['headers']),
    );
  }
}
