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

//getStream of chatlist
  Future<void> getChatList() async {
    try {
      state = ChatListState.loading();

      final messageRepository = ref.watch(messageRepositoryProvider);
      final userData = ref.watch(authProvider).data;
      final messages = messageRepository.getChatList(userData!.id!)
        ..listen((messages) {
          print(messages
              .first.lastMessage); // This will print the length of the messages whenever new data arrives
        });
      state = ChatListState.success(messages);
    } catch (e) {
      print('Failed to Get Message: $e');
      state = ChatListState.error('Failed to Get Message $e');
    }
  }
}

typedef ChatListState = BaseState<Stream<List<ConversationsModel>>>;

final chatListProvider =
    StateNotifierProvider.autoDispose<ChatListNotifier, ChatListState>(
  (ref) => ChatListNotifier(ref),
);
