import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/thought/thought_repository.dart';
import 'package:metal/domain/entities/thought_dto.dart';

/// Thought Feed State
class ThoughtFeedState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;
  final List<ThoughtDto> thoughts;
  final bool hasMore;
  final String? nextCursor;

  const ThoughtFeedState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
    this.thoughts = const [],
    this.hasMore = true,
    this.nextCursor,
  });

  /// Initial state
  factory ThoughtFeedState.initial() => const ThoughtFeedState();

  /// Loading state
  factory ThoughtFeedState.loading({
    List<ThoughtDto>? existingThoughts,
  }) =>
      ThoughtFeedState(
        isLoading: true,
        thoughts: existingThoughts ?? [],
      );

  /// Success state
  factory ThoughtFeedState.success(
    List<ThoughtDto> thoughts, {
    bool hasMore = true,
    String? nextCursor,
  }) {
    return ThoughtFeedState(
      isSuccess: true,
      thoughts: thoughts,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }

  /// Error state
  factory ThoughtFeedState.error(
    String message, {
    List<ThoughtDto>? existingThoughts,
  }) =>
      ThoughtFeedState(
        isError: true,
        errorMessage: message,
        thoughts: existingThoughts ?? [],
      );

  /// Copy with
  ThoughtFeedState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
    List<ThoughtDto>? thoughts,
    bool? hasMore,
    String? nextCursor,
  }) {
    return ThoughtFeedState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      thoughts: thoughts ?? this.thoughts,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
    );
  }
}

/// Thought Feed ViewModel
/// Handles loading and managing the thoughts feed
class ThoughtFeedViewModel extends StateNotifier<ThoughtFeedState> {
  final ThoughtRepository _repository;

  ThoughtFeedViewModel({
    required ThoughtRepository repository,
  })  : _repository = repository,
        super(ThoughtFeedState.initial());

  /// Load thoughts
  Future<void> loadThoughts() async {
    if (state.isLoading) return;

    state = ThoughtFeedState.loading();

    final result = await _repository.getThoughts(limit: 20);

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        state = ThoughtFeedState.success(
          result.data!.thoughts,
          hasMore: result.data!.hasMore,
          nextCursor: result.data!.nextCursor,
        );
      } else {
        state = ThoughtFeedState.error(
          result.errorMessage ?? 'Failed to load thoughts',
        );
      }
    }
  }

  /// Load more thoughts (pagination)
  Future<void> loadMoreThoughts() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    final result = await _repository.getThoughts(
      limit: 20,
      cursor: state.nextCursor,
    );

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        final allThoughts = [...state.thoughts, ...result.data!.thoughts];

        state = state.copyWith(
          isLoadingMore: false,
          isSuccess: true,
          thoughts: allThoughts,
          hasMore: result.data!.hasMore,
          nextCursor: result.data!.nextCursor,
        );
      } else {
        state = state.copyWith(
          isLoadingMore: false,
          isError: true,
          errorMessage: result.errorMessage,
        );
      }
    }
  }

  /// Refresh thoughts
  Future<void> refresh() async {
    state = ThoughtFeedState.initial();
    await loadThoughts();
  }

  /// Add a thought to the top of the feed (after creating)
  void addThought(ThoughtDto thought) {
    state = state.copyWith(
      thoughts: [thought, ...state.thoughts],
    );
  }

  /// Update a thought in the feed
  void updateThought(ThoughtDto updatedThought) {
    final index = state.thoughts.indexWhere((t) => t.id == updatedThought.id);
    if (index >= 0) {
      final updatedThoughts = List<ThoughtDto>.from(state.thoughts);
      updatedThoughts[index] = updatedThought;
      state = state.copyWith(thoughts: updatedThoughts);
    }
  }

  /// Remove a thought from the feed
  void removeThought(String thoughtId) {
    state = state.copyWith(
      thoughts: state.thoughts.where((t) => t.id != thoughtId).toList(),
    );
  }

  /// Remove all thoughts from a user from the feed (e.g. after blocking or account deletion)
  void removeThoughtsByUserId(String userId) {
    state = state.copyWith(
      thoughts: state.thoughts.where((t) => t.userId != userId).toList(),
    );
  }

  /// Delete a thought
  Future<bool> deleteThought(String thoughtId) async {
    final result = await _repository.deleteThought(thoughtId);

    if (result.isSuccess) {
      removeThought(thoughtId);
      return true;
    }

    return false;
  }
}
