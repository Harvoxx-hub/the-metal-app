import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'push_type.dart';
 

class NotificationPayloadModel {
  NotificationPayloadModel({
    this.action,
    required this.id,
    this.payload,
    this.badge,
  });

  factory NotificationPayloadModel.fromJson(String data) {
    final map = jsonDecode(data) as Map<String, dynamic>;

    return NotificationPayloadModel(
      action: PushType.valueOf(map['action'] as String?),
      id: map['id'],
      payload: map['payload'],
      badge: map['badge'],
    );
  }
  @override
  String toString() {
    return 'NotificationPayloadModel{action: $action, id: $id, payload: $payload, badge: $badge}';
  }

  factory NotificationPayloadModel.fromRemoteMessage(RemoteMessage message) {
    return NotificationPayloadModel(
      action: PushType.valueOf(message.data['type'] as String?),
      id:  message.data['Id'],
      payload: jsonDecode(message.data['payload'] ?? "{}"),
    );
  }

  final PushType? action;
  final String id;
  final Map<String, dynamic>? payload;
  final int? badge;

  String toJson() {
    final data = <String, dynamic>{};

    data['id'] = id;
    data['action'] = action?.toString();
    data['payload'] = payload;
    data['badge'] = badge?.toString();

    return jsonEncode(data);
  }
}
