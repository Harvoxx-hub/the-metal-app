import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/chat/data/repositories/message.repository.dart';
import 'package:metal/features/chat/domain/entries/message.model.dart';

class GetMessageNotifier extends StateNotifier<GetMessageState> {
  GetMessageNotifier(this.ref) : super(GetMessageState.initial());

  final Ref ref;

//getStream of chatlist
  Future<void> getMessage(String conversationId) async {
    try {
      state = GetMessageState.loading();

      final messageRepository = ref.watch(messageRepositoryProvider);

      final messages = messageRepository.getMessages(conversationId)
        ..listen((messages) {
          print(messages
              .length); // This will print the length of the messages whenever new data arrives

         
        });
         state = GetMessageState.success(messages);
    } catch (e) {
      print('Failed to Get Message: $e');
      state = GetMessageState.error('Failed to Get Message $e');
    }
  }
}

typedef GetMessageState = BaseState<Stream<List<MessageModel>>>;

final getMessageProvider =
    StateNotifierProvider.autoDispose<GetMessageNotifier, GetMessageState>(
  (ref) => GetMessageNotifier(ref),
);
