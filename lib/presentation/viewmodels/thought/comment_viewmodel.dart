import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/thought/thought_repository.dart';
import 'package:metal/features/thought/data/domain/entries/comment.model.dart';
import 'package:metal/presentation/viewmodels/thought/thought_providers.dart';

/// State for comment management
class CommentViewState {
  final List<CommentModel> comments;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isError;
  final String? errorMessage;
  final bool hasMore;
  final String? nextCursor;

  const CommentViewState({
    this.comments = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isError = false,
    this.errorMessage,
    this.hasMore = false,
    this.nextCursor,
  });

  factory CommentViewState.initial() => const CommentViewState();

  factory CommentViewState.loading() => const CommentViewState(isLoading: true);

  factory CommentViewState.success(
    List<CommentModel> comments, {
    bool hasMore = false,
    String? nextCursor,
  }) =>
      CommentViewState(
        comments: comments,
        hasMore: hasMore,
        nextCursor: nextCursor,
      );

  factory CommentViewState.error(String message) =>
      CommentViewState(isError: true, errorMessage: message);

  CommentViewState copyWith({
    List<CommentModel>? comments,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isError,
    String? errorMessage,
    bool? hasMore,
    String? nextCursor,
  }) {
    return CommentViewState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor,
    );
  }
}

/// ViewModel for managing comments on a thought
class CommentViewModel extends StateNotifier<CommentViewState> {
  final ThoughtRepository _repository;
  final String thoughtId;

  CommentViewModel({
    required ThoughtRepository repository,
    required this.thoughtId,
  })  : _repository = repository,
        super(CommentViewState.initial()) {
    loadComments();
  }

  /// Load comments for the thought
  Future<void> loadComments() async {
    state = CommentViewState.loading();

    final result = await _repository.getComments(thoughtId);

    if (result.isSuccess && result.data != null) {
      state = CommentViewState.success(
        result.data!.comments,
        hasMore: result.data!.hasMore,
        nextCursor: result.data!.nextCursor,
      );
    } else if (result.isError) {
      state = CommentViewState.error(result.errorMessage ?? 'Failed to load comments');
    } else {
      state = CommentViewState.success([]);
    }
  }

  /// Load more comments (pagination)
  Future<void> loadMoreComments() async {
    if (state.isLoadingMore || !state.hasMore || state.nextCursor == null) return;

    state = state.copyWith(isLoadingMore: true);

    final result = await _repository.getComments(
      thoughtId,
      cursor: state.nextCursor,
    );

    if (result.isSuccess && result.data != null) {
      final newComments = [...state.comments, ...result.data!.comments];
      state = state.copyWith(
        comments: newComments,
        isLoadingMore: false,
        hasMore: result.data!.hasMore,
        nextCursor: result.data!.nextCursor,
      );
    } else {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Add a comment
  Future<void> addComment(String content, {String? replyToCommentId}) async {
    final result = await _repository.addComment(
      thoughtId: thoughtId,
      content: content,
      replyToCommentId: replyToCommentId,
    );

    if (result.isSuccess && result.data != null) {
      // Add the new comment to the list optimistically
      final newComments = [result.data!, ...state.comments];
      state = state.copyWith(comments: newComments);
    }
  }

  /// Delete a comment
  Future<void> deleteComment(String commentId) async {
    final result = await _repository.deleteComment(
      thoughtId: thoughtId,
      commentId: commentId,
    );

    if (result.isSuccess) {
      // Remove the comment from the list optimistically
      final newComments = state.comments.where((c) => c.id != commentId).toList();
      state = state.copyWith(comments: newComments);
    }
  }

  /// React to a comment
  Future<void> reactToComment(String commentId, String emoji) async {
    await _repository.reactToComment(
      thoughtId: thoughtId,
      commentId: commentId,
      emoji: emoji,
    );

    // Reload comments to get updated reaction counts
    await loadComments();
  }

  /// Refresh comments
  Future<void> refresh() async {
    await loadComments();
  }
}

/// Provider for CommentViewModel - keyed by thoughtId
final commentViewModelProvider = StateNotifierProvider.autoDispose
    .family<CommentViewModel, CommentViewState, String>((ref, thoughtId) {
  final repository = ref.watch(thoughtRepositoryProvider);
  return CommentViewModel(
    repository: repository,
    thoughtId: thoughtId,
  );
});
