import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

class GetUserNotifier extends StateNotifier<GetUserState> {
  GetUserNotifier(super.state, this.ref, this.id) {
    getUserById();
  }
  final Ref ref;
  final String id;

  void getUserById() async {
    try {
      state = GetUserState.loading();
      final homeRepository = ref.watch(authenticationRepositoryProvider);
      final response = await homeRepository.getUserByID(id: id);

      if (response.success == false) {
        state = GetUserState.error('No user data available');
      } else {
        final userData = UserModel.fromJson(response.data);

        state = GetUserState.success(userData);
      }
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
