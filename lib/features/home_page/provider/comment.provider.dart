import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/home_page/domain/entries/comment.model.dart';
import 'package:metal/features/home_page/data/repositories/comment.repository.dart';

class CommentNotifier extends StateNotifier<CommentState> {
  CommentNotifier(this.ref, this.thoughtId) : super(CommentState.initial()) {
    getComments();
  }

  final Ref ref;
  final String thoughtId;

  Future<void> getComments() async {
    try {
      state = CommentState.loading();

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

  Future<void> addComment(String content) async {
    try {
      final repository = ref.read(commentRepositoryProvider);
      final response = await repository.addComment(thoughtId, content);

      if (response.success != true) {
        state = CommentState.error(response.message ?? 'Failed to add comment');
        return;
      }

      await getComments(); // Refresh comments list
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

      await getComments(); // Refresh comments list
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

      await getComments(); // Refresh comments list
    } catch (e) {
      state = CommentState.error('Failed to add reaction: $e');
    }
  }
}

typedef CommentState = BaseState<List<CommentModel>>;

final commentProvider =
    StateNotifierProvider.family<CommentNotifier, CommentState, String>(
  (ref, thoughtId) => CommentNotifier(ref, thoughtId),
);
