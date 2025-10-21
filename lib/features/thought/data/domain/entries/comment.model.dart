import 'package:json_annotation/json_annotation.dart';

part 'comment.model.g.dart';

@JsonSerializable(explicitToJson: true)
class CommentModel {
  final String id;
  final String userId;
  final String thoughtId;
  final String content;
  final String createdAt;
  final List<ReactionModel> reactions;

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

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ReactionModel {
  final String userId;
  final String emoji;

  ReactionModel({
    required this.userId,
    required this.emoji,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) =>
      _$ReactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReactionModelToJson(this);
}

// Extension methods for CommentModel
extension CommentModelExtension on CommentModel {
  /// Check if this comment is a reply to another comment
  bool get isReply => replyToCommentId != null && replyToCommentId!.isNotEmpty;

  /// Check if this comment is a top-level comment
  bool get isTopLevel => replyLevel == 0;

  /// Get truncated reply content for display
  String get truncatedReplyContent {
    if (!isReply || replyToContent == null) return '';

    const maxLength = 50; // Truncate to 50 characters
    if (replyToContent!.length <= maxLength) {
      return replyToContent!;
    }
    return '${replyToContent!.substring(0, maxLength)}...';
  }

  /// Get display text for reply preview
  String get replyPreviewText {
    if (!isReply) return '';
    return truncatedReplyContent;
  }

  /// Check if this comment can have replies (max 2 levels)
  bool get canHaveReplies => replyLevel < 2;
}
