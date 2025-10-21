import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/utils/uuid_center.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/features/thought/data/domain/entries/comment.model.dart';
import 'package:metal/features/thought/repositories/comment.repository.dart';

class ReplyNotifier extends StateNotifier<BaseState<String>> {
  ReplyNotifier(super.state, this.ref);
  final Ref ref;

  /// Add a reply to a comment
  Future<void> addReply({
    required String thoughtId,
    required String replyToCommentId,
    required String replyToUserId,
    required String replyToContent,
    required String content,
    required int replyLevel,
  }) async {
    try {
      state = BaseState.loading();

      final userData = ref.read(userStateProvider).data;
      if (userData == null) {
        state = BaseState.error("User not authenticated");
        return;
      }

      final commentRepository = ref.read(commentRepositoryProvider);

      final replyComment = CommentModel(
        id: UUIDCenter.uuid,
        userId: userData.id!,
        thoughtId: thoughtId,
        content: content,
        createdAt: DateTime.now().toIso8601String(),
        reactions: [],
        replyToCommentId: replyToCommentId,
        replyToUserId: replyToUserId,
        replyToContent: replyToContent,
        replyLevel: replyLevel + 1,
        isDeleted: false,
      );

      await commentRepository.addComment(replyComment);

      state = BaseState.success("Reply added successfully");
    } catch (e, stackTrace) {
      state = BaseState.error(e.toString(), stackTrace: stackTrace);
    }
  }

  /// Delete a reply comment
  Future<void> deleteReply({
    required String thoughtId,
    required String commentId,
  }) async {
    try {
      state = BaseState.loading();

      final commentRepository = ref.read(commentRepositoryProvider);
      await commentRepository.deleteComment(thoughtId, commentId);

      state = BaseState.success("Reply deleted successfully");
    } catch (e, stackTrace) {
      state = BaseState.error(e.toString(), stackTrace: stackTrace);
    }
  }

  /// Get replies for a specific comment
  Future<List<CommentModel>> getReplies({
    required String thoughtId,
    required String commentId,
  }) async {
    try {
      final commentRepository = ref.read(commentRepositoryProvider);
      final response = await commentRepository.getComments(thoughtId);

      if (response.success != true || response.data == null) {
        return [];
      }

      // Convert response data to CommentModel list
      final allComments = (response.data as List)
          .map((commentData) => CommentModel.fromJson(commentData))
          .toList();

      // Filter comments that are replies to the specified comment
      return allComments
          .where((comment) =>
              comment.replyToCommentId == commentId && !comment.isDeleted)
          .toList();
    } catch (e) {
      return [];
    }
  }
}

// Provider for reply operations
final replyProvider =
    StateNotifierProvider.autoDispose<ReplyNotifier, BaseState<String>>(
  (ref) => ReplyNotifier(BaseState.initial(), ref),
);

// Provider for getting replies to a specific comment
final commentRepliesProvider =
    FutureProvider.family<List<CommentModel>, Map<String, String>>(
  (ref, params) async {
    final replyNotifier = ref.read(replyProvider.notifier);
    return await replyNotifier.getReplies(
      thoughtId: params['thoughtId']!,
      commentId: params['commentId']!,
    );
  },
);
