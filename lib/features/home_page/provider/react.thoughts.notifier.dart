import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';

import 'package:metal/features/home_page/data/repositories/home.repository.dart';

class ReactThoughtNotifier extends StateNotifier<ReactThoughtState> {
  ReactThoughtNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  void reactThought(String thoughtid, String emoji) async {
    try {
      final homeRepository = ref.watch(homeRepositoryProvider);
      final userData = ref.watch(authProvider).data;
      await homeRepository.reactThought(
          thoughtId: thoughtid, userId: userData?.id ?? "", emoji: emoji);

      if (mounted) {
        state = ReactThoughtState.success("");
      }
    } catch (e, s) {
      state = ReactThoughtState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef ReactThoughtState = BaseState<String>;

final reactThoughtProvider =
    StateNotifierProvider.autoDispose<ReactThoughtNotifier, ReactThoughtState>(
  (ref) => ReactThoughtNotifier(ReactThoughtState.initial(), ref),
);
