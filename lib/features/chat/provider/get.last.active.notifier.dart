import 'package:flutter_riverpod/flutter_riverpod.dart';
 
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/chat/data/repositories/message.repository.dart';
 

class GetLastActiveNotifier extends StateNotifier<GetLastActiveState> {
  GetLastActiveNotifier(this.ref) : super(GetLastActiveState.initial());

  final Ref ref;

  Future<void> GetLastActiveTime(String userId) async {
    try {
      state = GetLastActiveState.loading();

      final messageRepository = ref.watch(messageRepositoryProvider);
      final response = await messageRepository.lastActiveTime(userId);

      if (response.success!) {
        state = GetLastActiveState.success(response.data);
      }
    } catch (e) {
      state = GetLastActiveState.error('Failed to send message: $e');
    }
  }
}

typedef GetLastActiveState = BaseState<String>;

final lastActiveProvider = StateNotifierProvider.autoDispose<
    GetLastActiveNotifier, GetLastActiveState>(
  (ref) => GetLastActiveNotifier(ref),
);
