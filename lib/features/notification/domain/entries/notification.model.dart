import 'dart:convert';

class NotificationModel {
  final List<String> recipientIds; // List of recipient IDs
  final String title; // Notification title
  final String subTitle; // Notification subtitle
  final NotificationType type; // Enum for notification type
  final Map<String, dynamic> data; // Additional data (e.g., connectionId, status)
  final NotificationAndroidNotification androidNotification; // Android-specific notification
  final NotificationIosNotification iosNotification; // iOS-specific notification
  final DateTime timestamp; // When the notification was sent
  final String id; // Unique ID

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
  });

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
    };
  }

  // Convert a JSON map to a NotificationModel instance
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      recipientIds: List<String>.from(json['recipientIds']),
      title: json['title'],
      subTitle: json['subTitle'],
      type: NotificationType.values
          .firstWhere((e) => e.toString().split('.').last == json['type']),
      data: Map<String, dynamic>.from(json['data']),
      androidNotification: NotificationAndroidNotification.fromJson(json['androidNotification']),
      iosNotification: NotificationIosNotification.fromJson(json['iosNotification']),
      timestamp: DateTime.parse(json['timestamp']),
      id: json['id'],
    );
  }
}

enum NotificationType {
  new_connection,
  new_message,
  thought_created,
  reaction_added,
  sparks_transaction

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
