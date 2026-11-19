import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/thought/thought_repository.dart';
import 'package:metal/domain/entities/comment_dto.dart';
import 'package:metal/presentation/viewmodels/thought/thought_providers.dart';

/// Keep first occurrence of each non-empty comment id (preserves API order).
List<CommentDto> _dedupeCommentsById(List<CommentDto> input) {
  final seen = <String>{};
  final out = <CommentDto>[];
  for (final c in input) {
    if (c.id.isEmpty) {
      out.add(c);
      continue;
    }
    if (seen.contains(c.id)) continue;
    seen.add(c.id);
    out.add(c);
  }
  return out;
}

/// State for comment management
class CommentViewState {
  final List<CommentDto> comments;
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
    List<CommentDto> comments, {
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
    List<CommentDto>? comments,
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
  bool _addCommentInFlight = false;

  CommentViewModel({
    required ThoughtRepository repository,
    required this.thoughtId,
  })  : _repository = repository,
        super(CommentViewState.initial()) {
    loadComments();
  }

  /// Load comments for the thought
  Future<void> loadComments() async {
    if (!mounted) return;
    state = CommentViewState.loading();

    final result = await _repository.getComments(thoughtId);

    if (!mounted) return;

    if (result.isSuccess && result.data != null) {
      // BUG-023: Don't show deleted comments — filter them out
      final visible = _dedupeCommentsById(
        result.data!.comments.where((c) => !c.isDeleted).toList(),
      );
      state = CommentViewState.success(
        visible,
        hasMore: result.data!.hasMore,
        nextCursor: result.data!.nextCursor,
      );
    } else if (result.isError) {
      state = CommentViewState.error(
          result.errorMessage ?? 'Failed to load comments');
    } else {
      state = CommentViewState.success([]);
    }
  }

  /// Load more comments (pagination)
  Future<void> loadMoreComments() async {
    if (!mounted ||
        state.isLoadingMore ||
        !state.hasMore ||
        state.nextCursor == null) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    final result = await _repository.getComments(
      thoughtId,
      cursor: state.nextCursor,
    );

    if (!mounted) return;

    if (result.isSuccess && result.data != null) {
      final newBatch = _dedupeCommentsById(
        result.data!.comments.where((c) => !c.isDeleted).toList(),
      );
      final newComments =
          _dedupeCommentsById([...state.comments, ...newBatch]);
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
    if (!mounted || _addCommentInFlight) return;
    _addCommentInFlight = true;

    try {
      final result = await _repository.addComment(
        thoughtId: thoughtId,
        content: content,
        replyToCommentId: replyToCommentId,
      );

      if (!mounted) return;

      if (result.isSuccess && result.data != null) {
        // Add the new comment; deduplicate by id (double-submit / id mismatch from API)
        final added = result.data!;
        final rest = state.comments.where((c) => c.id != added.id).toList();
        state = state.copyWith(
          comments: _dedupeCommentsById([added, ...rest]),
        );
      }
    } finally {
      _addCommentInFlight = false;
    }
  }

  /// Delete a comment
  Future<void> deleteComment(String commentId) async {
    if (!mounted) return;

    final result = await _repository.deleteComment(
      thoughtId: thoughtId,
      commentId: commentId,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      // Remove the comment from the list optimistically
      final newComments =
          state.comments.where((c) => c.id != commentId).toList();
      state = state.copyWith(comments: newComments);
    }
  }

  /// React to a comment
  Future<void> reactToComment(String commentId, String emoji) async {
    if (!mounted) return;

    await _repository.reactToComment(
      thoughtId: thoughtId,
      commentId: commentId,
      emoji: emoji,
    );

    if (!mounted) return;

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
