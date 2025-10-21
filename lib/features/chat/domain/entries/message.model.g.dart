// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
      message: json['message'] as String,
      senderId: json['senderId'] as String,
      type: $enumDecode(_$MessageTypeEnumMap, json['type']),
      content: json['content'] as String?,
      id: json['id'] as String?,
      timestamp: json['timestamp'] as String,
      isRead: json['isRead'] as bool,
      replyToMessageId: json['replyToMessageId'] as String?,
      replyToMessageText: json['replyToMessageText'] as String?,
      replyToSenderId: json['replyToSenderId'] as String?,
      replyToMessageType: json['replyToMessageType'] as String?,
    );

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'message': instance.message,
      'senderId': instance.senderId,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'content': instance.content,
      'id': instance.id,
      'timestamp': instance.timestamp,
      'isRead': instance.isRead,
      'replyToMessageId': instance.replyToMessageId,
      'replyToMessageText': instance.replyToMessageText,
      'replyToSenderId': instance.replyToSenderId,
      'replyToMessageType': instance.replyToMessageType,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.audio: 'audio',
  MessageType.un_melt: 'un_melt',
  MessageType.calls: 'calls',
};
