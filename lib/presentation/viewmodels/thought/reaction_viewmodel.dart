import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/models/reaction_model.dart';

import 'package:metal/data/repositories/thought/thought_repository.dart';
import 'package:metal/domain/entities/reaction_dto.dart';
import 'package:metal/presentation/viewmodels/thought/thought_providers.dart';

/// State for reaction management
class ReactionViewState {
  final List<ReactionModel> reactions;
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

  factory ReactionViewState.loading() => const ReactionViewState(isLoading: true);

  factory ReactionViewState.success(List<ReactionModel> reactions) =>
      ReactionViewState(reactions: reactions);

  factory ReactionViewState.error(String message) =>
      ReactionViewState(isError: true, errorMessage: message);

  ReactionViewState copyWith({
    List<ReactionModel>? reactions,
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
    state = ReactionViewState.loading();

    final result = await _repository.getReactions(thoughtId);

    if (result.isSuccess && result.data != null) {
      state = ReactionViewState.success(result.data!.reactions);
    } else if (result.isError) {
      state = ReactionViewState.error(result.errorMessage ?? 'Failed to load reactions');
    } else {
      state = ReactionViewState.success([]);
    }
  }

  /// Add or toggle a reaction on the thought
  /// If user already has a reaction with the same emoji, it will be removed
  /// If user has a different emoji, it will be updated
  Future<void> addReaction(String emoji) async {
    final result = await _repository.addReaction(
      thoughtId: thoughtId,
      emoji: emoji,
    );

    if (result.isSuccess && result.data != null) {
      // Reload reactions to get the updated list
      await loadReactions();
    }
  }

  /// Refresh reactions
  Future<void> refresh() async {
    await loadReactions();
  }

  /// Find user's current reaction
  ReactionModel? getUserReaction(String userId) {
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
