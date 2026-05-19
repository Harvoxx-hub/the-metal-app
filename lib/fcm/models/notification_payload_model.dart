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

  /// Accepts a JSON string or a decoded [Map] (e.g. from [jsonDecode] or prefs).
  factory NotificationPayloadModel.fromJson(dynamic json) {
    final Map<String, dynamic> map = switch (json) {
      final String s => jsonDecode(s) as Map<String, dynamic>,
      final Map<String, dynamic> m => m,
      final Map m => Map<String, dynamic>.from(m),
      _ => throw const FormatException(
          'NotificationPayloadModel.fromJson: expected String or Map',
        ),
    };

    Map<String, dynamic>? dataMap;
    final raw = map['data'];
    if (raw is Map) {
      dataMap = Map<String, dynamic>.from(raw);
    }

    return NotificationPayloadModel(
      title: map['title'] as String?,
      body: map['body'] as String?,
      action: _parseAction(map['action'] as String?),
      data: dataMap,
      id: map['id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'action': action?.value,
      'data': data,
      'id': id,
    };
  }

  static PushType? _parseAction(String? action) {
    if (action == null) return null;
    for (final type in PushType.values) {
      if (type.value == action || type.name == action) return type;
    }
    return PushType.unknown;
  }

  @override
  String toString() {
    return 'NotificationPayloadModel(title: $title, body: $body, action: $action, data: $data, id: $id)';
  }
}
