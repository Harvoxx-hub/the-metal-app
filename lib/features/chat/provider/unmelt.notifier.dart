import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/chat/data/repositories/message.repository.dart';

class UnmeltNotifier extends StateNotifier<UnmeltState> {
  UnmeltNotifier(this.ref) : super(UnmeltState.initial());

  final Ref ref;

  Future<void> unmelter(
      String connectionID, messageId, Map<String, dynamic> data) async {
    try {
      final repository = ref.watch(messageRepositoryProvider);
      await repository.unMelt(connectionID, messageId, data);
    } catch (e) {
      state = UnmeltState.error('Failed to send message: $e');
    }
  }

  Future<void> deleteMessage(String connectionID, messageId) async {
    try {
      final repository = ref.watch(messageRepositoryProvider);
      await repository.deleteMessage(connectionID, messageId);
    } catch (e) {
      state = UnmeltState.error('Failed to send message: $e');
    }
  }

  Future<void> updateMessage(
      String connectionID, messageId, Map<String, dynamic> data) async {
    try {
      final repository = ref.watch(messageRepositoryProvider);
      await repository.updateMessage(connectionID, messageId, data);
    } catch (e) {
      state = UnmeltState.error('Failed to send message: $e');
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
      await repository.updateMessage(connectionID, messageId, {'isRead': true});
    } catch (e) {
      // Check if the notifier is still mounted before updating the state
      if (mounted) {
        state = UnmeltState.error('Failed to mark message as read: $e');
      } else {
        print("UnmeltNotifier is disposed. Error: $e");
      }
    }
  }
}

typedef UnmeltState = BaseState<String>;

final unMeltProvider =
    StateNotifierProvider.autoDispose<UnmeltNotifier, UnmeltState>(
  (ref) => UnmeltNotifier(ref),
);
