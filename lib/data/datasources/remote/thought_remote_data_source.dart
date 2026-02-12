import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/network/dio_client.dart';
import 'package:metal/data/models/thought_model.dart';
import 'package:metal/data/models/comment_model.dart';
import 'package:metal/data/models/reaction_model.dart';

/// Remote data source for thought operations
/// Handles API communication for thoughts feed
class ThoughtRemoteDataSource {
  final DioClient _client;

  ThoughtRemoteDataSource(this._client);

  // ============ Thought Methods ============

  /// Get thoughts feed with pagination
  /// [userId] - Optional filter to get thoughts by a specific user
  Future<ThoughtsResponseModel> getThoughts({
    int limit = 20,
    String? cursor,
    String? userId,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      if (cursor != null) 'cursor': cursor,
      if (userId != null) 'userId': userId,
    };

    final response = await _client.get(
      ApiRoutes.buildPath(ApiRoutes.thoughts),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return ThoughtsResponseModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to get thoughts');
  }

  /// Get a single thought by ID
  Future<ThoughtModel> getThoughtById(String thoughtId) async {
    final response = await _client.get(
      '${ApiRoutes.buildPath(ApiRoutes.thoughtById)}/$thoughtId',
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return ThoughtModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to get thought');
  }

  /// Create a new thought
  /// content can be null for voice-only thoughts
  Future<ThoughtModel> createThought({
    String? content,
    String type = 'text',
    String? audioUrl,
    int? audioDuration,
    bool connectionOnly = false,
    Map<String, dynamic>? communityMetadata,
    String? originalThoughtId, // For reposts
  }) async {
    final data = <String, dynamic>{
      if (content != null && content.isNotEmpty) 'content': content,
      'type': type,
      'connectionOnly': connectionOnly,
      if (audioUrl != null) 'audioUrl': audioUrl,
      if (audioDuration != null) 'audioDuration': audioDuration,
      if (communityMetadata != null) 'communityMetadata': communityMetadata,
      if (originalThoughtId != null) 'originalThoughtId': originalThoughtId,
    };

    final response = await _client.post(
      ApiRoutes.buildPath(ApiRoutes.thoughts),
      data: data,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data != null) {
        final responseData = response.data['data'] as Map<String, dynamic>? ?? response.data;
        return ThoughtModel.fromJson(responseData);
      }
    }

    throw Exception(response.data?['error'] ?? 'Failed to create thought');
  }

  /// Update a thought
  Future<ThoughtModel> updateThought({
    required String thoughtId,
    String? content,
    bool? connectionOnly,
  }) async {
    final data = <String, dynamic>{
      if (content != null) 'content': content,
      if (connectionOnly != null) 'connectionOnly': connectionOnly,
    };

    final response = await _client.put(
      '${ApiRoutes.buildPath(ApiRoutes.thoughtById)}/$thoughtId',
      data: data,
    );

    if (response.statusCode == 200 && response.data != null) {
      final responseData = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return ThoughtModel.fromJson(responseData);
    }

    throw Exception(response.data?['error'] ?? 'Failed to update thought');
  }

  /// Delete a thought
  Future<void> deleteThought(String thoughtId) async {
    final response = await _client.delete(
      '${ApiRoutes.buildPath(ApiRoutes.thoughtById)}/$thoughtId',
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to delete thought');
    }
  }

  // ============ Reaction Methods ============

  /// Get reactions for a thought
  Future<ReactionsResponseModel> getReactions(String thoughtId) async {
    final response = await _client.get(
      '${ApiRoutes.buildPath(ApiRoutes.thoughtReactions)}/$thoughtId/reactions',
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return ReactionsResponseModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to get reactions');
  }

  /// Add or toggle a reaction on a thought
  Future<ReactionResponseModel> addReaction({
    required String thoughtId,
    required String emoji,
  }) async {
    final response = await _client.post(
      '${ApiRoutes.buildPath(ApiRoutes.thoughtReactions)}/$thoughtId/reactions',
      data: {'emoji': emoji},
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return ReactionResponseModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to add reaction');
  }

  // ============ Comment Methods ============

  /// Get comments for a thought
  Future<CommentsResponseModel> getComments(
    String thoughtId, {
    int limit = 50,
    String? cursor,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      if (cursor != null) 'cursor': cursor,
    };

    final response = await _client.get(
      '${ApiRoutes.buildPath(ApiRoutes.thoughtComments)}/$thoughtId/comments',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return CommentsResponseModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to get comments');
  }

  /// Add a comment to a thought
  Future<CommentModel> addComment({
    required String thoughtId,
    required String content,
    String? replyToCommentId,
  }) async {
    final data = <String, dynamic>{
      'content': content,
      if (replyToCommentId != null) 'replyToCommentId': replyToCommentId,
    };

    final response = await _client.post(
      '${ApiRoutes.buildPath(ApiRoutes.thoughtComments)}/$thoughtId/comments',
      data: data,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data != null) {
        final responseData = response.data['data'] as Map<String, dynamic>? ?? response.data;
        return CommentModel.fromJson(responseData);
      }
    }

    throw Exception(response.data?['error'] ?? 'Failed to add comment');
  }

  /// Delete a comment
  Future<void> deleteComment({
    required String thoughtId,
    required String commentId,
  }) async {
    final response = await _client.delete(
      '${ApiRoutes.buildPath(ApiRoutes.deleteComment)}/$thoughtId/comments/$commentId',
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to delete comment');
    }
  }

  /// React to a comment
  Future<void> reactToComment({
    required String thoughtId,
    required String commentId,
    required String emoji,
  }) async {
    final response = await _client.post(
      '${ApiRoutes.buildPath(ApiRoutes.commentReaction)}/$thoughtId/comments/$commentId/reactions',
      data: {'emoji': emoji},
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to react to comment');
    }
  }
}

// ============ Response Models ============

/// Response model for thoughts list
class ThoughtsResponseModel {
  final List<ThoughtModel> thoughts;
  final PaginationModel pagination;

  ThoughtsResponseModel({
    required this.thoughts,
    required this.pagination,
  });

  factory ThoughtsResponseModel.fromJson(Map<String, dynamic> json) {
    final thoughtsJson = json['thoughts'] as List<dynamic>? ?? [];
    return ThoughtsResponseModel(
      thoughts: thoughtsJson
          .map((t) => ThoughtModel.fromJson(t as Map<String, dynamic>))
          .toList(),
      pagination: PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

/// Response model for reactions
class ReactionsResponseModel {
  final List<ReactionModel> reactions;
  final Map<String, int> counts;
  final int total;

  ReactionsResponseModel({
    required this.reactions,
    required this.counts,
    required this.total,
  });

  factory ReactionsResponseModel.fromJson(Map<String, dynamic> json) {
    final reactionsJson = json['reactions'] as List<dynamic>? ?? [];
    final countsJson = json['counts'] as Map<String, dynamic>? ?? {};

    return ReactionsResponseModel(
      reactions: reactionsJson
          .map((r) => ReactionModel.fromJson(r as Map<String, dynamic>))
          .toList(),
      counts: countsJson.map((k, v) => MapEntry(k, v as int)),
      total: json['total'] as int? ?? 0,
    );
  }
}

/// Response model for single reaction action
class ReactionResponseModel {
  final String? id;
  final String thoughtId;
  final String emoji;
  final bool removed;
  final bool updated;

  ReactionResponseModel({
    this.id,
    required this.thoughtId,
    required this.emoji,
    this.removed = false,
    this.updated = false,
  });

  factory ReactionResponseModel.fromJson(Map<String, dynamic> json) {
    return ReactionResponseModel(
      id: json['id'] as String?,
      thoughtId: json['thoughtId'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '',
      removed: json['removed'] as bool? ?? false,
      updated: json['updated'] as bool? ?? false,
    );
  }
}

/// Response model for comments list
class CommentsResponseModel {
  final List<CommentModel> comments;
  final PaginationModel pagination;

  CommentsResponseModel({
    required this.comments,
    required this.pagination,
  });

  factory CommentsResponseModel.fromJson(Map<String, dynamic> json) {
    final commentsJson = json['comments'] as List<dynamic>? ?? [];
    return CommentsResponseModel(
      comments: commentsJson
          .map((c) => CommentModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      pagination: PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

/// Pagination model
class PaginationModel {
  final bool hasMore;
  final String? nextCursor;

  PaginationModel({
    required this.hasMore,
    this.nextCursor,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      hasMore: json['hasMore'] as bool? ?? false,
      nextCursor: json['nextCursor'] as String?,
    );
  }
}
