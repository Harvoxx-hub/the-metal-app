// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversations.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationsModel _$ConversationsModelFromJson(Map<String, dynamic> json) =>
    ConversationsModel(
      documentId: json['documentId'] as String,
      initiatedAt:
          const TimestampConverter().fromJson(json['initiatedAt'] as Timestamp),
      lastMessage: json['lastMessage'] as String,
      lastUpdatedAt: const TimestampConverter()
          .fromJson(json['lastUpdatedAt'] as Timestamp),
      participantIds: (json['participantIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ConversationsModelToJson(ConversationsModel instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'initiatedAt': const TimestampConverter().toJson(instance.initiatedAt),
      'lastMessage': instance.lastMessage,
      'lastUpdatedAt':
          const TimestampConverter().toJson(instance.lastUpdatedAt),
      'participantIds': instance.participantIds,
    };
