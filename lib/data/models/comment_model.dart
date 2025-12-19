import 'package:metal/domain/entities/comment_dto.dart';
import 'package:metal/domain/entities/reaction_dto.dart';
import 'package:metal/data/models/reaction_model.dart';

/// Comment response model from API
class CommentModel {
  final String id;
  final String userId;
  final String thoughtId;
  final String content;
  final String createdAt;
  final List<CommentReactionModel> reactions;

  // Reply functionality fields
  final String? replyToCommentId;
  final String? replyToUserId;
  final String? replyToContent;
  final int replyLevel;
  final bool isDeleted;

  CommentModel({
    required this.id,
    required this.userId,
    required this.thoughtId,
    required this.content,
    required this.createdAt,
    this.reactions = const [],
    this.replyToCommentId,
    this.replyToUserId,
    this.replyToContent,
    this.replyLevel = 0,
    this.isDeleted = false,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      thoughtId: json['thoughtId'] as String,
      content: json['content'] as String,
      createdAt: json['createdAt'] as String,
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((r) =>
                  CommentReactionModel.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      replyToCommentId: json['replyToCommentId'] as String?,
      replyToUserId: json['replyToUserId'] as String?,
      replyToContent: json['replyToContent'] as String?,
      replyLevel: json['replyLevel'] as int? ?? 0,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'thoughtId': thoughtId,
      'content': content,
      'createdAt': createdAt,
      'reactions': reactions.map((r) => r.toJson()).toList(),
      if (replyToCommentId != null) 'replyToCommentId': replyToCommentId,
      if (replyToUserId != null) 'replyToUserId': replyToUserId,
      if (replyToContent != null) 'replyToContent': replyToContent,
      'replyLevel': replyLevel,
      'isDeleted': isDeleted,
    };
  }

  /// Convert to domain DTO
  CommentDto toDomain() {
    return CommentDto(
      id: id,
      userId: userId,
      thoughtId: thoughtId,
      content: content,
      createdAt: DateTime.parse(createdAt),
      reactions: reactions.map((r) => r.toDomain()).toList(),
      replyToCommentId: replyToCommentId,
      replyToUserId: replyToUserId,
      replyToContent: replyToContent,
      replyLevel: replyLevel,
      isDeleted: isDeleted,
    );
  }

  /// Check if this comment is a reply to another comment
  bool get isReply => replyToCommentId != null && replyToCommentId!.isNotEmpty;

  /// Check if this comment is a top-level comment
  bool get isTopLevel => replyLevel == 0;

  /// Get truncated reply content for display
  String get truncatedReplyContent {
    if (!isReply || replyToContent == null) return '';

    const maxLength = 50;
    if (replyToContent!.length <= maxLength) {
      return replyToContent!;
    }
    return '${replyToContent!.substring(0, maxLength)}...';
  }

  /// Check if this comment can have replies (max 2 levels)
  bool get canHaveReplies => replyLevel < 2;
}

/// Comment reaction model (simple version for comments)
class CommentReactionModel {
  final String userId;
  final String emoji;

  CommentReactionModel({
    required this.userId,
    required this.emoji,
  });

  factory CommentReactionModel.fromJson(Map<String, dynamic> json) {
    return CommentReactionModel(
      userId: json['userId'] as String,
      emoji: json['emoji'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'emoji': emoji,
    };
  }

  /// Convert to reaction DTO (creates a fake ID and thoughtId)
  ReactionDto toDomain() {
    return ReactionDto(
      id: '', // Comment reactions don't have IDs
      userId: userId,
      thoughtId: '', // Not applicable for comment reactions
      emoji: emoji,
      createdAt: DateTime.now(), // Not stored for comment reactions
    );
  }
}
