// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
      message: json['message'] as String,
      recipientId: json['recipientId'] as String,
      senderId: json['senderId'] as String,
      type: $enumDecode(_$MessageTypeEnumMap, json['type']),
      content: json['content'] as String?,
      userName: json['userName'] as String?,
      fcmToken: json['fcmToken'] as String?,
      timestamp:
          const TimestampConverter().fromJson(json['timestamp'] as Timestamp),
      state: $enumDecode(_$MessageStateEnumMap, json['state']),
    );

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'message': instance.message,
      'senderId': instance.senderId,
      'recipientId': instance.recipientId,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'content': instance.content,
      'userName': instance.userName,
      'fcmToken': instance.fcmToken,
      'timestamp': const TimestampConverter().toJson(instance.timestamp),
      'state': _$MessageStateEnumMap[instance.state]!,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.audio: 'audio',
};

const _$MessageStateEnumMap = {
  MessageState.sending: 'sending',
  MessageState.sent: 'sent',
  MessageState.read: 'read',
  MessageState.error: 'error',
};
