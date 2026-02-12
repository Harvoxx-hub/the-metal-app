import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/thought/thought_repository.dart';
import 'package:metal/domain/entities/reaction_dto.dart';
import 'package:metal/presentation/viewmodels/thought/thought_providers.dart';

/// State for reaction management
class ReactionViewState {
  final List<ReactionDto> reactions;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  const ReactionViewState({
    this.reactions = const [],
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
  });

  factory ReactionViewState.initial() => const ReactionViewState();

  factory ReactionViewState.loading() =>
      const ReactionViewState(isLoading: true);

  factory ReactionViewState.success(List<ReactionDto> reactions) =>
      ReactionViewState(reactions: reactions);

  factory ReactionViewState.error(String message) =>
      ReactionViewState(isError: true, errorMessage: message);

  ReactionViewState copyWith({
    List<ReactionDto>? reactions,
    bool? isLoading,
    bool? isError,
    String? errorMessage,
  }) {
    return ReactionViewState(
      reactions: reactions ?? this.reactions,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// ViewModel for managing reactions on a thought
class ReactionViewModel extends StateNotifier<ReactionViewState> {
  final ThoughtRepository _repository;
  final String thoughtId;

  ReactionViewModel({
    required ThoughtRepository repository,
    required this.thoughtId,
  })  : _repository = repository,
        super(ReactionViewState.initial()) {
    loadReactions();
  }

  /// Load reactions for the thought
  Future<void> loadReactions() async {
    if (!mounted) return;
    state = ReactionViewState.loading();

    final result = await _repository.getReactions(thoughtId);

    if (!mounted) return;

    if (result.isSuccess && result.data != null) {
      state = ReactionViewState.success(result.data!.reactions);
    } else if (result.isError) {
      state = ReactionViewState.error(
          result.errorMessage ?? 'Failed to load reactions');
    } else {
      state = ReactionViewState.success([]);
    }
  }

  /// Add or toggle a reaction on the thought.
  /// If [currentUserId] is provided, updates state optimistically before the API call.
  /// If user already has a reaction with the same emoji, it will be removed.
  /// If user has a different emoji, it will be updated.
  Future<void> addReaction(String emoji, {String? currentUserId}) async {
    if (!mounted) return;

    final previousReactions = List<ReactionDto>.from(state.reactions);

    if (currentUserId != null && currentUserId.isNotEmpty) {
      // Optimistic update: apply locally first
      final withoutMine =
          state.reactions.where((r) => r.userId != currentUserId).toList();
      final existingMine =
          state.reactions.where((r) => r.userId == currentUserId).firstOrNull;
      final isToggleOff = existingMine?.emoji == emoji;

      final newReactions = isToggleOff
          ? withoutMine
          : [
              ...withoutMine,
              ReactionDto(
                id: 'pending-${DateTime.now().millisecondsSinceEpoch}',
                userId: currentUserId,
                thoughtId: thoughtId,
                emoji: emoji,
                createdAt: DateTime.now(),
              ),
            ];

      state = state.copyWith(
        reactions: newReactions,
        isError: false,
        errorMessage: null,
      );
    }

    final result = await _repository.addReaction(
      thoughtId: thoughtId,
      emoji: emoji,
    );

    if (!mounted) return;

    if (result.isSuccess && result.data != null) {
      // Sync with server to get canonical list (ids, etc.)
      await loadReactions();
    } else {
      // Revert on failure
      if (currentUserId != null && currentUserId.isNotEmpty) {
        state = state.copyWith(
          reactions: previousReactions,
          isError: true,
          errorMessage: result.errorMessage ?? 'Failed to add reaction',
        );
      }
    }
  }

  /// Refresh reactions
  Future<void> refresh() async {
    await loadReactions();
  }

  /// Find user's current reaction
  ReactionDto? getUserReaction(String userId) {
    try {
      return state.reactions.firstWhere((r) => r.userId == userId);
    } catch (_) {
      return null;
    }
  }
}

/// Provider for ReactionViewModel - keyed by thoughtId
final reactionViewModelProvider = StateNotifierProvider.autoDispose
    .family<ReactionViewModel, ReactionViewState, String>((ref, thoughtId) {
  final repository = ref.watch(thoughtRepositoryProvider);
  return ReactionViewModel(
    repository: repository,
    thoughtId: thoughtId,
  );
});
