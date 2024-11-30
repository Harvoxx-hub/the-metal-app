import 'package:flutter_riverpod/flutter_riverpod.dart';
 
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/chat/data/repositories/message.repository.dart';
 

class UnmeltNotifier extends StateNotifier<UnmeltState> {
  UnmeltNotifier(this.ref) : super(UnmeltState.initial());

  final Ref ref;

  Future<void> umelter(String userId) async {
    try {
      state = UnmeltState.loading();

      final repository = ref.watch(messageRepositoryProvider);
      final response = await repository.deMelt(userId);

      if (response.success!) {
        state = UnmeltState.success(response.success.toString());
      }
    } catch (e) {
      state = UnmeltState.error('Failed to send message: $e');
    }
  }
}

typedef UnmeltState = BaseState<String>;

final unMeltProvider = StateNotifierProvider.autoDispose<
    UnmeltNotifier, UnmeltState>(
  (ref) => UnmeltNotifier(ref),
);
