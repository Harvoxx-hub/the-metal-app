import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';

import 'package:metal/features/settings/data/repositories/setting.repository.dart';

class GetBlockUsersNotifier extends StateNotifier<GetBlockUsersState> {
  GetBlockUsersNotifier(
    super.state,
    this.ref,
  ) {
    getBlock();
  }
  final Ref ref;

  // melt user
  void getBlock() async {
    try {
      state = GetBlockUsersState.loading();
      final repo = ref.watch(settingRepositoryProvider);
      final response = await repo.getBlockedUsers();

      if (mounted) {
        state = GetBlockUsersState.success(response.data);
      }
    } catch (e) {
      state = GetBlockUsersState.error(e.toString());
    }
  }
}

// Define a type alias
typedef GetBlockUsersState = BaseState<List<dynamic>>;

final getBlockUserProvider = StateNotifierProvider<
    GetBlockUsersNotifier, GetBlockUsersState>(
  (ref) => GetBlockUsersNotifier(GetBlockUsersState.initial(), ref),
);
