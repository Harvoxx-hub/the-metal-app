import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';

import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/provider/get.thoughts.for.you.dart';

class SendThoughtNotifier extends StateNotifier<SendThoughtState> {
  SendThoughtNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  // melt user
  void sendThought(String thought) async {
    try {
      state = SendThoughtState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.sendThought(thought);
      ref.read(getThoughtForYouProvider.notifier).getThoughtUpdate();
      if (mounted) {
        state = SendThoughtState.success(response.message!);
      }
    } catch (e, s) {
      state = SendThoughtState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef SendThoughtState = BaseState<String>;

final sendThoughtProvider =
    StateNotifierProvider.autoDispose<SendThoughtNotifier, SendThoughtState>(
  (ref) => SendThoughtNotifier(SendThoughtState.initial(), ref),
);
