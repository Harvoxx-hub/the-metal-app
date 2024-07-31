import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/chat/data/repositories/message.repository.dart';
import 'package:metal/features/chat/domain/entries/conversations.model.dart';

class ChatListNotifier extends StateNotifier<ChatListState> {
  ChatListNotifier(this.ref) : super(ChatListState.initial()) {
    getChatList();
  }

  final Ref ref;
  StreamSubscription<List<ConversationsModel>>? _messageSubscription;

  Future<void> getChatList() async {
    try {
      state = ChatListState.loading();

      final messageRepository = ref.watch(messageRepositoryProvider);
      final userData = ref.watch(authProvider).data;
      _messageSubscription =
          messageRepository.getChatList(userData!.id!).listen((event) {
        print(event.length);
        if (mounted) {
          state = ChatListState.success(event);
        }
      });
    } catch (e) {
      print('Failed to Get Message: $e');
      state = ChatListState.error('Failed to Get Message $e');
    }
  }

  

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}

typedef ChatListState = BaseState<List<ConversationsModel>>;

final chatListProvider =
    StateNotifierProvider.autoDispose<ChatListNotifier, ChatListState>(
  (ref) => ChatListNotifier(ref),
);
