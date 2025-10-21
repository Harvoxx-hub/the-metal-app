// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentModel _$CommentModelFromJson(Map<String, dynamic> json) => CommentModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      thoughtId: json['thoughtId'] as String,
      content: json['content'] as String,
      createdAt: json['createdAt'] as String,
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => ReactionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      replyToCommentId: json['replyToCommentId'] as String?,
      replyToUserId: json['replyToUserId'] as String?,
      replyToContent: json['replyToContent'] as String?,
      replyLevel: (json['replyLevel'] as num?)?.toInt() ?? 0,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$CommentModelToJson(CommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'thoughtId': instance.thoughtId,
      'content': instance.content,
      'createdAt': instance.createdAt,
      'reactions': instance.reactions.map((e) => e.toJson()).toList(),
      'replyToCommentId': instance.replyToCommentId,
      'replyToUserId': instance.replyToUserId,
      'replyToContent': instance.replyToContent,
      'replyLevel': instance.replyLevel,
      'isDeleted': instance.isDeleted,
    };

ReactionModel _$ReactionModelFromJson(Map<String, dynamic> json) =>
    ReactionModel(
      userId: json['userId'] as String,
      emoji: json['emoji'] as String,
    );

Map<String, dynamic> _$ReactionModelToJson(ReactionModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'emoji': instance.emoji,
    };
