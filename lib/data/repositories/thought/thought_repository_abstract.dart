import 'package:metal/core/state/base.state.dart';
import 'package:metal/domain/entities/thought_dto.dart';
import 'package:metal/domain/entities/comment_dto.dart';
import 'package:metal/domain/entities/reaction_dto.dart';

/// Abstract repository interface for thought operations
/// Defines the contract for thought data access
abstract class ThoughtRepositoryAbstract {
  // ============ Thought Methods ============

  /// Get thoughts feed (paginated)
  /// [userId] - Optional filter to get thoughts by a specific user
  Future<BaseState<ThoughtsResponseDto>> getThoughts({
    int limit = 20,
    String? cursor,
    String? userId,
  });

  /// Get a single thought by ID
  Future<BaseState<ThoughtDto>> getThoughtById(String thoughtId);

  /// Create a new thought
  /// content can be null for voice-only thoughts
  Future<BaseState<ThoughtDto>> createThought({
    String? content,
    String type = 'text',
    String? audioUrl,
    int? audioDuration,
    bool connectionOnly = false,
    Map<String, dynamic>? communityMetadata,
    String? originalThoughtId,
  });

  /// Update a thought
  Future<BaseState<ThoughtDto>> updateThought({
    required String thoughtId,
    String? content,
    bool? connectionOnly,
  });

  /// Delete a thought
  Future<BaseState<void>> deleteThought(String thoughtId);

  // ============ Reaction Methods ============

  /// Get reactions for a thought
  Future<BaseState<ReactionsResponseDto>> getReactions(String thoughtId);

  /// Add or toggle a reaction on a thought
  Future<BaseState<ReactionDto>> addReaction({
    required String thoughtId,
    required String emoji,
  });

  // ============ Comment Methods ============

  /// Get comments for a thought (paginated)
  Future<BaseState<CommentsResponseDto>> getComments(
    String thoughtId, {
    int limit = 50,
    String? cursor,
  });

  /// Add a comment to a thought
  Future<BaseState<CommentDto>> addComment({
    required String thoughtId,
    required String content,
    String? replyToCommentId,
  });

  /// Delete a comment
  Future<BaseState<void>> deleteComment({
    required String thoughtId,
    required String commentId,
  });

  /// React to a comment
  Future<BaseState<void>> reactToComment({
    required String thoughtId,
    required String commentId,
    required String emoji,
  });
}

/// DTO for thoughts response with pagination
class ThoughtsResponseDto {
  final List<ThoughtDto> thoughts;
  final bool hasMore;
  final String? nextCursor;

  ThoughtsResponseDto({
    required this.thoughts,
    required this.hasMore,
    this.nextCursor,
  });
}

/// DTO for comments response with pagination
class CommentsResponseDto {
  final List<CommentDto> comments;
  final bool hasMore;
  final String? nextCursor;

  CommentsResponseDto({
    required this.comments,
    required this.hasMore,
    this.nextCursor,
  });
}

/// DTO for reactions response
class ReactionsResponseDto {
  final List<ReactionDto> reactions;

  ReactionsResponseDto({
    required this.reactions,
  });
}
