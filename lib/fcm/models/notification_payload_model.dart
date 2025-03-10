import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:metal/fcm/models/push_type.dart';

class NotificationPayloadModel {
  final String? title;
  final String? body;
  final PushType? action;
  final Map<String, dynamic>? data;
  final String? id;

  NotificationPayloadModel({
    this.title,
    this.body,
    this.action,
    this.data,
    this.id,
  });

  factory NotificationPayloadModel.fromRemoteMessage(RemoteMessage message) {
    return NotificationPayloadModel(
      title: message.notification?.title,
      body: message.notification?.body,
      action: _parseAction(message.data['action'] as String?),
      data: message.data,
      id: message.messageId,
    );
  }

  factory NotificationPayloadModel.fromJson(String json) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(
      json as Map<String, dynamic>,
    );
    return NotificationPayloadModel(
      title: data['title'] as String?,
      body: data['body'] as String?,
      action: _parseAction(data['action'] as String?),
      data: data['data'] as Map<String, dynamic>?,
      id: data['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'action': action?.name,
      'data': data,
      'id': id,
    };
  }

  static PushType? _parseAction(String? action) {
    if (action == null) return null;
    return PushType.values.firstWhere(
      (type) => type.name == action,
      orElse: () => PushType.unknown,
    );
  }

  @override
  String toString() {
    return 'NotificationPayloadModel(title: $title, body: $body, action: $action, data: $data, id: $id)';
  }
}
