import 'package:metal/core/error_handling/error_handler.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/datasources/remote/thought_remote_data_source.dart';
import 'package:metal/data/repositories/thought/thought_repository_abstract.dart';
import 'package:metal/features/thought/data/domain/entries/thought.model.dart';
import 'package:metal/features/thought/data/domain/entries/comment.model.dart';

/// Implementation of thought repository
/// Coordinates data sources and handles error mapping
class ThoughtRepository implements ThoughtRepositoryAbstract {
  final ThoughtRemoteDataSource _remoteDataSource;

  ThoughtRepository({
    required ThoughtRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  // ============ Thought Methods ============

  @override
  Future<BaseState<ThoughtsResponseDto>> getThoughts({
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final response = await _remoteDataSource.getThoughts(
        limit: limit,
        cursor: cursor,
      );

      return BaseState.success(ThoughtsResponseDto(
        thoughts: response.thoughts,
        hasMore: response.pagination.hasMore,
        nextCursor: response.pagination.nextCursor,
      ));
    } catch (e) {
      return ErrorHandler.handleError<ThoughtsResponseDto>(e);
    }
  }

  @override
  Future<BaseState<ThoughtModel>> getThoughtById(String thoughtId) async {
    try {
      final response = await _remoteDataSource.getThoughtById(thoughtId);
      return BaseState.success(response);
    } catch (e) {
      return ErrorHandler.handleError<ThoughtModel>(e);
    }
  }

  @override
  Future<BaseState<ThoughtModel>> createThought({
    required String content,
    String type = 'text',
    String? audioUrl,
    int? audioDuration,
    bool connectionOnly = false,
    Map<String, dynamic>? communityMetadata,
    String? originalThoughtId,
  }) async {
    try {
      final response = await _remoteDataSource.createThought(
        content: content,
        type: type,
        audioUrl: audioUrl,
        audioDuration: audioDuration,
        connectionOnly: connectionOnly,
        communityMetadata: communityMetadata,
        originalThoughtId: originalThoughtId,
      );
      return BaseState.success(response);
    } catch (e) {
      return ErrorHandler.handleError<ThoughtModel>(e);
    }
  }

  @override
  Future<BaseState<ThoughtModel>> updateThought({
    required String thoughtId,
    String? content,
    bool? connectionOnly,
  }) async {
    try {
      final response = await _remoteDataSource.updateThought(
        thoughtId: thoughtId,
        content: content,
        connectionOnly: connectionOnly,
      );
      return BaseState.success(response);
    } catch (e) {
      return ErrorHandler.handleError<ThoughtModel>(e);
    }
  }

  @override
  Future<BaseState<void>> deleteThought(String thoughtId) async {
    try {
      await _remoteDataSource.deleteThought(thoughtId);
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  // ============ Reaction Methods ============

  @override
  Future<BaseState<ReactionsResponseModel>> getReactions(
    String thoughtId,
  ) async {
    try {
      final response = await _remoteDataSource.getReactions(thoughtId);
      return BaseState.success(response);
    } catch (e) {
      return ErrorHandler.handleError<ReactionsResponseModel>(e);
    }
  }

  @override
  Future<BaseState<ReactionResponseModel>> addReaction({
    required String thoughtId,
    required String emoji,
  }) async {
    try {
      final response = await _remoteDataSource.addReaction(
        thoughtId: thoughtId,
        emoji: emoji,
      );
      return BaseState.success(response);
    } catch (e) {
      return ErrorHandler.handleError<ReactionResponseModel>(e);
    }
  }

  // ============ Comment Methods ============

  @override
  Future<BaseState<CommentsResponseDto>> getComments(
    String thoughtId, {
    int limit = 50,
    String? cursor,
  }) async {
    try {
      final response = await _remoteDataSource.getComments(
        thoughtId,
        limit: limit,
        cursor: cursor,
      );

      return BaseState.success(CommentsResponseDto(
        comments: response.comments,
        hasMore: response.pagination.hasMore,
        nextCursor: response.pagination.nextCursor,
      ));
    } catch (e) {
      return ErrorHandler.handleError<CommentsResponseDto>(e);
    }
  }

  @override
  Future<BaseState<CommentModel>> addComment({
    required String thoughtId,
    required String content,
    String? replyToCommentId,
  }) async {
    try {
      final response = await _remoteDataSource.addComment(
        thoughtId: thoughtId,
        content: content,
        replyToCommentId: replyToCommentId,
      );
      return BaseState.success(response);
    } catch (e) {
      return ErrorHandler.handleError<CommentModel>(e);
    }
  }

  @override
  Future<BaseState<void>> deleteComment({
    required String thoughtId,
    required String commentId,
  }) async {
    try {
      await _remoteDataSource.deleteComment(
        thoughtId: thoughtId,
        commentId: commentId,
      );
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  @override
  Future<BaseState<void>> reactToComment({
    required String thoughtId,
    required String commentId,
    required String emoji,
  }) async {
    try {
      await _remoteDataSource.reactToComment(
        thoughtId: thoughtId,
        commentId: commentId,
        emoji: emoji,
      );
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }
}
