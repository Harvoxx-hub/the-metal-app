// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: (json['id'] as num?)?.toInt(),
      created_at: json['created_at'] as String?,
      type: $enumDecodeNullable(_$NotificationTypeEnumMap, json['type']),
      fcmToken: json['fcmToken'] as String?,
      title: json['title'] as String?,
      body: json['body'] as String?,
      sender: json['sender'] as String?,
      receiver: json['receiver'] as String?,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.created_at,
      'type': _$NotificationTypeEnumMap[instance.type],
      'fcmToken': instance.fcmToken,
      'title': instance.title,
      'body': instance.body,
      'sender': instance.sender,
      'receiver': instance.receiver,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.MELT: 'MELT',
  NotificationType.SPARK: 'SPARK',
  NotificationType.REFER: 'REFER',
  NotificationType.MESSAGE: 'MESSAGE',
  NotificationType.UNMELT: 'UNMELT',
  NotificationType.THOUGHTREACTION: 'THOUGHTREACTION',
  NotificationType.THOUGHT: 'THOUGHT',
};
