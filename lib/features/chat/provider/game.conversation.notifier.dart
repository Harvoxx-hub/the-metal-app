import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/chat/data/repositories/message.repository.dart';
import 'package:metal/features/chat/domain/entries/message.model.dart';

class GameConversationNotifier extends StateNotifier<GameConversationState> {
  GameConversationNotifier(this.ref) : super(GameConversationState.initial());

  final Ref ref;

  /// Update game in conversation
  Future<void> updateGameConversation({
    required String conversatioId,
    required String gameTitle,
    MessageModel? message,
  }) async {
    try {
      state = GameConversationState.loading();

      final messageRepository = ref.watch(messageRepositoryProvider);
      await messageRepository.updateGame(conversatioId, gameTitle,
          message: message);

      if (mounted) {
        state = GameConversationState.success("Game updated successfully");
      }
    } catch (e) {
      if (mounted) {
        state = GameConversationState.error('Failed to update game: $e');
      }
    }
  }
}

typedef GameConversationState = BaseState<String>;

final gameConversationProvider = StateNotifierProvider.autoDispose<
    GameConversationNotifier, GameConversationState>(
  (ref) => GameConversationNotifier(ref),
);
