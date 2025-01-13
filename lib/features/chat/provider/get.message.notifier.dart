import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';

import 'package:metal/features/chat/data/repositories/message.repository.dart';
import 'package:metal/features/chat/domain/entries/message.model.dart';

class MessageListNotifier extends StateNotifier<MessageListState> {
  MessageListNotifier(super.state, this.ref, this.id) {
    getMessageList();
  }
  final Ref ref;
  final String id;
  StreamSubscription<List<MessageModel>>? _messageSubscription;

  void getMessageList() async {
    try {
      if (id.isEmpty) {
        print("Conversation Id missing");
        state = MessageListState.error("No Message");
        return; // Add this return to stop further execution
      }

      state = MessageListState.loading();
      final messageRepository = ref.watch(messageRepositoryProvider);

      _messageSubscription =
          messageRepository.getMessages(id).listen((messages) {
        if (mounted) {
          state = MessageListState.success(messages);
        }
      });
    } catch (e, s) {
      state = MessageListState.error(e.toString(), stackTrace: s);
    }
  }

  void clearChat() {
    ref.watch(messageRepositoryProvider).clearChat(id);
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
// }
}

typedef MessageListState = BaseState<List<MessageModel>>;

final getMessageList = StateNotifierProvider.family
    .autoDispose<MessageListNotifier, MessageListState, String>(
  (ref, id) => MessageListNotifier(MessageListState.initial(), ref, id),
);
