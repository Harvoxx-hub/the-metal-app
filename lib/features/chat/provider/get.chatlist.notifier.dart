import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';

class ChatListNotifier extends StateNotifier<ChatListState> {
  ChatListNotifier(this.ref) : super(ChatListState.initial());

  final Ref ref;

//getStream of chatlist
  Future<void> getChatList() async {
    try {} catch (e) {
      print('Failed to send message: $e');
      state = ChatListState.error('Failed to send message: $e');
    }
  }
}

typedef ChatListState = BaseState<void>;

final chatListProvider =
    StateNotifierProvider.autoDispose<ChatListNotifier, ChatListState>(
  (ref) => ChatListNotifier(ref),
);
