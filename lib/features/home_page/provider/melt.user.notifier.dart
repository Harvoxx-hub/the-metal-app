import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';

import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/zim.manager/zim.notifier.dart';

class MeltUsersNotifier extends StateNotifier<MeltUsersState> {
  MeltUsersNotifier(
    MeltUsersState state,
    this.ref,
    this.id,
  ) : super(state) {
    meltUser();
  }
  final Ref ref;
  final String id;

  // melt user
  void meltUser() async {
    try {
      state = MeltUsersState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.meltUser(id);
     

      state = MeltUsersState.success(response.message);
    } catch (e) {
      print(e.toString());
      state = MeltUsersState.error(e.toString());
    }
  }
 
 

}

// Define a type alias
typedef MeltUsersState = BaseState<String>;

final meltUserProvider = StateNotifierProvider.autoDispose
    .family<MeltUsersNotifier, MeltUsersState, String>(
  (ref, id) => MeltUsersNotifier(MeltUsersState.initial(), ref, id),
);
