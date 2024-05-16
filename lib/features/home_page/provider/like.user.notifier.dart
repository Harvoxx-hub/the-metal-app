import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';

import 'package:metal/features/home_page/data/repositories/home.repository.dart';
 

class LikeUsersNotifier extends StateNotifier<LikeUsersState> {
  LikeUsersNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  // melt user
  void LikeUser(String id) async {
    try {
      state = LikeUsersState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.likeUser(userToLike: id);
      if (mounted) {
        state = LikeUsersState.success(response.message!);
      }
    } catch (e) {
      print(e.toString());
      state = LikeUsersState.error(e.toString());
    }
  }
}

// Define a type alias
typedef LikeUsersState = BaseState<String>;

final likeUserProvider =
    StateNotifierProvider.autoDispose<LikeUsersNotifier, LikeUsersState>(
  (ref) => LikeUsersNotifier(LikeUsersState.initial(), ref),
);
