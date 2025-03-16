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
}

typedef UnmeltState = BaseState<String>;

final unMeltProvider =
    StateNotifierProvider.autoDispose<UnmeltNotifier, UnmeltState>(
  (ref) => UnmeltNotifier(ref),
);
