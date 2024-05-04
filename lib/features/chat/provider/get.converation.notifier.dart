import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
 
import 'package:metal/features/chat/data/repositories/message.repository.dart';
import 'package:metal/features/chat/domain/entries/conversations.model.dart';

class GetConveration extends StateNotifier<ConversationState> {
  GetConveration(this.ref, this.id) : super(ConversationState.initial()) {
    getConversation();
  }

  final Ref ref;
  final String id;

  StreamSubscription<ConversationsModel>? _messageSubscription;

  Future<void> getConversation() async {
    try {
      state = ConversationState.loading();

      final messageRepository = ref.watch(messageRepositoryProvider);
 
      _messageSubscription =
          messageRepository.conversation(id).listen((event) {
        print(event);
        state = ConversationState.success(event);
      });
    } catch (e) {
      print('Failed to Get Message: $e');
      state = ConversationState.error('Failed to Get Message $e');
    }
  }


  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}

typedef ConversationState = BaseState<ConversationsModel>;

final getConverationProvider =
    StateNotifierProvider.family.autoDispose<GetConveration, ConversationState, String>(
  (ref, id) => GetConveration(ref, id),
);
