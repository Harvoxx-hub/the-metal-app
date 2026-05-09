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
    final data = message.data;
    final typeStr = data['type'] as String? ?? data['action'] as String?;
    final nTitle = message.notification?.title?.trim();
    final nBody = message.notification?.body?.trim();
    final dTitle = (data['title'] as String?)?.trim();
    final dBody = (data['body'] as String?)?.trim();
    return NotificationPayloadModel(
      title: (nTitle != null && nTitle.isNotEmpty) ? nTitle : dTitle,
      body: (nBody != null && nBody.isNotEmpty) ? nBody : dBody,
      action: _parseAction(typeStr),
      data: data,
      id: message.messageId,
    );
  }

  factory NotificationPayloadModel.fromJson(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
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
    for (final type in PushType.values) {
      if (type.value == action) return type;
    }
    return PushType.unknown;
  }

  @override
  String toString() {
    return 'NotificationPayloadModel(title: $title, body: $body, action: $action, data: $data, id: $id)';
  }
}
