import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/thought/repositories/reaction.repository.dart';
import 'package:metal/features/thought/data/domain/entries/reaction.model.dart';

class ReactionNotifier extends StateNotifier<ReactionState> {
  ReactionNotifier(this.ref, this.thoughtId) : super(ReactionState.initial()) {
    _startListening();
  }

  final Ref ref;
  final String thoughtId;
  StreamSubscription<List<ReactionModel>>? _reactionSubscription;

  @override
  void dispose() {
    _reactionSubscription?.cancel();
    super.dispose();
  }

  /// Start listening to real-time reaction updates
  void _startListening() {
    try {
      state = ReactionState.loading();

      final repository = ref.read(reactionRepositoryProvider);
      _reactionSubscription = repository.getReactionsStream(thoughtId).listen(
        (reactions) {
          if (mounted) {
            state = ReactionState.success(reactions);
          }
        },
        onError: (error) {
          if (mounted) {
            state = ReactionState.error('Failed to load reactions: $error');
          }
        },
      );
    } catch (e) {
      state = ReactionState.error('Failed to initialize reactions: $e');
    }
  }

  /// Manually refresh reactions (for pull-to-refresh)
  Future<void> getReactions() async {
    try {
      final repository = ref.read(reactionRepositoryProvider);
      final response = await repository.getReactions(thoughtId);

      if (response.success != true) {
        state =
            ReactionState.error(response.message ?? 'Failed to load reactions');
        return;
      }

      final data = response.data;
      if (data == null) {
        state = ReactionState.success([]);
        return;
      }

      final reactionsList =
          (data as List).map((json) => ReactionModel.fromJson(json)).toList();
      state = ReactionState.success(reactionsList);
    } catch (e) {
      state = ReactionState.error('Failed to load reactions: $e');
    }
  }

  Future<void> addReaction(String emoji) async {
    try {
      final repository = ref.read(reactionRepositoryProvider);
      final response = await repository.addReaction(thoughtId, emoji);

      if (response.success != true) {
        state =
            ReactionState.error(response.message ?? 'Failed to add reaction');
        return;
      }

      // No need to manually refresh - the stream will automatically update
    } catch (e) {
      state = ReactionState.error('Failed to add reaction: $e');
    }
  }

  Future<void> deleteReaction(String reactionId) async {
    try {
      final repository = ref.read(reactionRepositoryProvider);
      final response = await repository.deleteReaction(thoughtId, reactionId);

      if (response.success != true) {
        state = ReactionState.error(
            response.message ?? 'Failed to delete reaction');
        return;
      }

      // No need to manually refresh - the stream will automatically update
    } catch (e) {
      state = ReactionState.error('Failed to delete reaction: $e');
    }
  }

  Future<ReactionModel?> getUserReaction(String userId) async {
    try {
      final repository = ref.read(reactionRepositoryProvider);
      final response = await repository.getUserReaction(thoughtId, userId);

      if (response.success != true || response.data == null) {
        return null;
      }

      return ReactionModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  /// Restart the stream listener (useful for pull-to-refresh)
  void refreshStream() {
    _reactionSubscription?.cancel();
    _startListening();
  }
}

typedef ReactionState = BaseState<List<ReactionModel>>;

final reactionProvider =
    StateNotifierProvider.family<ReactionNotifier, ReactionState, String>(
  (ref, thoughtId) => ReactionNotifier(ref, thoughtId),
);
