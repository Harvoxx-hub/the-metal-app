import 'package:metal/domain/entities/base_entity.dart';
import 'package:metal/domain/entities/reaction_dto.dart';

/// Comment domain entity (DTO)
class CommentDto extends BaseEntity {
  final String id;
  final String userId;
  final String thoughtId;
  final String content;
  final DateTime createdAt;
  final List<ReactionDto> reactions;

  // Reply functionality fields
  final String? replyToCommentId;
  final String? replyToUserId;
  final String? replyToContent;
  final int replyLevel;
  final bool isDeleted;

  const CommentDto({
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

  CommentDto copyWith({
    String? id,
    String? userId,
    String? thoughtId,
    String? content,
    DateTime? createdAt,
    List<ReactionDto>? reactions,
    String? replyToCommentId,
    String? replyToUserId,
    String? replyToContent,
    int? replyLevel,
    bool? isDeleted,
  }) {
    return CommentDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      thoughtId: thoughtId ?? this.thoughtId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      reactions: reactions ?? this.reactions,
      replyToCommentId: replyToCommentId ?? this.replyToCommentId,
      replyToUserId: replyToUserId ?? this.replyToUserId,
      replyToContent: replyToContent ?? this.replyToContent,
      replyLevel: replyLevel ?? this.replyLevel,
      isDeleted: isDeleted ?? this.isDeleted,
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
