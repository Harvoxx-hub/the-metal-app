// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReactionModel _$ReactionModelFromJson(Map<String, dynamic> json) =>
    ReactionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      thoughtId: json['thoughtId'] as String,
      emoji: json['emoji'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$ReactionModelToJson(ReactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'thoughtId': instance.thoughtId,
      'emoji': instance.emoji,
      'createdAt': instance.createdAt,
    };
