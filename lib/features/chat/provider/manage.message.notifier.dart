import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/chat/data/repositories/message.repository.dart';

class ManagerMessageNotifier extends StateNotifier<ManagerMessageState> {
  ManagerMessageNotifier(this.ref) : super(ManagerMessageState.initial());

  final Ref ref;

  Future<void> deleteMessage(String connectionID, messageId) async {
    try {
      final repository = ref.watch(messageRepositoryProvider);
      await repository.deleteMessage(connectionID, messageId);
    } catch (e) {
      state = ManagerMessageState.error('Failed to send message: $e');
    }
  }

  Future<void> updateMessage(
      String connectionID, messageId, Map<String, dynamic> data) async {
    try {
      final repository = ref.watch(messageRepositoryProvider);
      await repository.updateMessage(connectionID, messageId, data);
    } catch (e) {
      state = ManagerMessageState.error('Failed to send message: $e');
    }
  }

  /// **Mark a message as read in Firestore**
  Future<void> markMessageAsRead(String connectionID, String messageId) async {
    if (connectionID.isEmpty || messageId.isEmpty) {
      print("Invalid connectionID or messageId");
      return;
    }

    try {
      final repository = ref.watch(messageRepositoryProvider);
      await repository.updateMessage(
          connectionID, messageId, {'isRead': true, 'unreadCount': 0});
    } catch (e) {
      // Check if the notifier is still mounted before updating the state
      if (mounted) {
        state = ManagerMessageState.error('Failed to mark message as read: $e');
      } else {
        print("UnmeltNotifier is disposed. Error: $e");
      }
    }
  }
}

typedef ManagerMessageState = BaseState<String>;

final managerMessageProvider = StateNotifierProvider.autoDispose<
    ManagerMessageNotifier, ManagerMessageState>(
  (ref) => ManagerMessageNotifier(ref),
);
