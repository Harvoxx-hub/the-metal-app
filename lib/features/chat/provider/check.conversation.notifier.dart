import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/chat/data/repositories/message.repository.dart';

class CheckConversationNotifier extends StateNotifier<CheckConversationState> {
  CheckConversationNotifier(this.ref, this.id)
      : super(CheckConversationState.initial()) {
    getChatList();
  }

  final Ref ref;
  final id;

  Future<void> getChatList() async {
    try {
      state = CheckConversationState.loading();

      final messageRepository = ref.watch(messageRepositoryProvider);
      final userData = ref.watch(authProvider).data;

      final response =
          await messageRepository.checkConversationId(userData!.id!, id);
      if (mounted) {
        state = CheckConversationState.success(response);
      }
    } catch (e) {
      print('Failed to Get Message: $e');
      state = CheckConversationState.error('Failed to Get Message $e');
    }
  }
}

typedef CheckConversationState = BaseState<String>;

final checkConversationProvider = StateNotifierProvider.family
    .autoDispose<CheckConversationNotifier, CheckConversationState, String>(
  (ref, id) => CheckConversationNotifier(ref, id),
);
