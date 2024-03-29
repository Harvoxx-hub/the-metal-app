import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';

import 'package:metal/features/home_page/data/repositories/home.repository.dart';
 

class PushUsersNotifier extends StateNotifier<PushUsersState> {
  PushUsersNotifier(
    PushUsersState state,
    this.ref,
  ) : super(state) {}
  final Ref ref;

  // melt user
  void pushUser(String id) async {
    try {
      state = PushUsersState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.pushUser(id);

      state = PushUsersState.success(response.message!);
    } catch (e) {
      print(e.toString());
      state = PushUsersState.error(e.toString());
    }
  }
}

// Define a type alias
typedef PushUsersState = BaseState<String>;

final pushUserProvider =
    StateNotifierProvider.autoDispose<PushUsersNotifier, PushUsersState>(
  (ref) => PushUsersNotifier(PushUsersState.initial(), ref),
);
