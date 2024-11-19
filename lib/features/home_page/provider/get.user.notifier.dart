import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/home_page/data/repositories/home.repository.dart';

class GetUserNotifier extends StateNotifier<GetUserState> {
  GetUserNotifier(super.state, this.ref, this.id) {
    getUserById();
  }
  final Ref ref;
  final String id;

  void getUserById() async {
    try {
      state = GetUserState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.getUserById(id: id);
      print(response.data);

      state = GetUserState.success(UserModel.fromJson(response.data));
    } catch (e, s) {
      state = GetUserState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef GetUserState = BaseState<UserModel>;

final getUserProvider = StateNotifierProvider.autoDispose
    .family<GetUserNotifier, GetUserState, String>(
  (ref, id) => GetUserNotifier(GetUserState.initial(), ref, id),
);
