import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/features/thought/data/domain/entries/comment.model.dart';
import 'package:metal/features/thought/repositories/comment.repository.dart';

class CommentNotifier extends StateNotifier<CommentState> {
  CommentNotifier(this.ref, this.thoughtId) : super(CommentState.initial()) {
    _startListening();
  }

  final Ref ref;
  final String thoughtId;
  StreamSubscription<List<CommentModel>>? _commentSubscription;

  @override
  void dispose() {
    _commentSubscription?.cancel();
    super.dispose();
  }

  /// Start listening to real-time comment updates
  void _startListening() {
    try {
      state = CommentState.loading();

      final repository = ref.read(commentRepositoryProvider);
      _commentSubscription = repository.getCommentsStream(thoughtId).listen(
        (comments) {
          if (mounted) {
            state = CommentState.success(comments);
          }
        },
        onError: (error) {
          if (mounted) {
            state = CommentState.error('Failed to load comments: $error');
          }
        },
      );
    } catch (e) {
      state = CommentState.error('Failed to initialize comments: $e');
    }
  }

  /// Manually refresh comments (for pull-to-refresh)
  Future<void> getComments() async {
    try {
      final repository = ref.read(commentRepositoryProvider);
      final response = await repository.getComments(thoughtId);

      if (response.success != true) {
        state =
            CommentState.error(response.message ?? 'Failed to load comments');
        return;
      }

      final data = response.data;
      if (data == null) {
        state = CommentState.success([]);
        return;
      }

      final commentsList =
          (data as List).map((json) => CommentModel.fromJson(json)).toList();
      state = CommentState.success(commentsList);
    } catch (e) {
      state = CommentState.error('Failed to load comments: $e');
    }
  }

  Future<void> addComment(CommentModel comment) async {
    try {
      final repository = ref.read(commentRepositoryProvider);
      final userData = ref.read(userStateProvider).data;

      if (userData == null) {
        state = CommentState.error('User not authenticated');
        return;
      }

      final response = await repository.addComment(comment);

      if (response.success != true) {
        state = CommentState.error(response.message ?? 'Failed to add comment');
        return;
      }

      // No need to manually refresh - the stream will automatically update
    } catch (e) {
      state = CommentState.error('Failed to add comment: $e');
    }
  }

  Future<void> addCommentFromText(String content) async {
    try {
      final repository = ref.read(commentRepositoryProvider);
      final userData = ref.read(userStateProvider).data;

      if (userData == null) {
        state = CommentState.error('User not authenticated');
        return;
      }

      final comment = CommentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userData.id!,
        thoughtId: thoughtId,
        content: content,
        createdAt: DateTime.now().toIso8601String(),
        reactions: [],
        replyLevel: 0,
        isDeleted: false,
      );

      final response = await repository.addComment(comment);

      if (response.success != true) {
        state = CommentState.error(response.message ?? 'Failed to add comment');
        return;
      }

      // No need to manually refresh - the stream will automatically update
    } catch (e) {
      state = CommentState.error('Failed to add comment: $e');
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      final repository = ref.read(commentRepositoryProvider);
      final response = await repository.deleteComment(thoughtId, commentId);

      if (response.success != true) {
        state =
            CommentState.error(response.message ?? 'Failed to delete comment');
        return;
      }

      // No need to manually refresh - the stream will automatically update
    } catch (e) {
      state = CommentState.error('Failed to delete comment: $e');
    }
  }

  Future<void> reactToComment(String commentId, String emoji) async {
    try {
      final repository = ref.read(commentRepositoryProvider);
      final response =
          await repository.reactToComment(thoughtId, commentId, emoji);

      if (response.success != true) {
        state =
            CommentState.error(response.message ?? 'Failed to add reaction');
        return;
      }

      // No need to manually refresh - the stream will automatically update
    } catch (e) {
      state = CommentState.error('Failed to add reaction: $e');
    }
  }

  /// Restart the stream listener (useful for pull-to-refresh)
  void refreshStream() {
    _commentSubscription?.cancel();
    _startListening();
  }
}

typedef CommentState = BaseState<List<CommentModel>>;

final commentProvider =
    StateNotifierProvider.family<CommentNotifier, CommentState, String>(
  (ref, thoughtId) => CommentNotifier(ref, thoughtId),
);
