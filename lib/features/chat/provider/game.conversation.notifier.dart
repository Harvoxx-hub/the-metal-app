import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/chat/data/repositories/message.repository.dart';

class GameConversationNotifier extends StateNotifier<GameConversationState> {
  GameConversationNotifier(
    this.ref,
  ) : super(GameConversationState.initial()) {
    //   getChatList();
  }

  final Ref ref;

  Future<void> updateGameConversation(
      String conversatioId, String gameTitle) async {
    try {
      state = GameConversationState.loading();

      final messageRepository = ref.watch(messageRepositoryProvider);

      await messageRepository.updateGame(conversatioId, gameTitle);
      if (mounted) {
        state = GameConversationState.success("response");
      }
    } catch (e) {
      print('Failed to Get Message: $e');
      state = GameConversationState.error('Failed to Get Message $e');
    }
  }
}

typedef GameConversationState = BaseState<String>;

final gameConversationProvider = StateNotifierProvider.autoDispose<
    GameConversationNotifier, GameConversationState>(
  (ref) => GameConversationNotifier(ref),
);
