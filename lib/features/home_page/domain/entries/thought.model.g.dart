// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thought.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ThoughtModelImpl _$$ThoughtModelImplFromJson(Map<String, dynamic> json) =>
    _$ThoughtModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      createdAt: json['createdAt'] as String,
      connectionOnly: json['connectionOnly'] as bool? ?? false,
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => ReactionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ThoughtModelImplToJson(_$ThoughtModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'content': instance.content,
      'createdAt': instance.createdAt,
      'connectionOnly': instance.connectionOnly,
      'reactions': instance.reactions,
    };

_$ReactionModelImpl _$$ReactionModelImplFromJson(Map<String, dynamic> json) =>
    _$ReactionModelImpl(
      userId: json['userId'] as String,
      emoji: json['emoji'] as String,
    );

Map<String, dynamic> _$$ReactionModelImplToJson(_$ReactionModelImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'emoji': instance.emoji,
    };
