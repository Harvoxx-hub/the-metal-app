import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';

class ChnagePasswordNotifier extends StateNotifier<ChangePasswordStates> {
  ChnagePasswordNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  void changePassword({
    required String id,
    required String password,
  }) async {
    state = ChangePasswordStates.loading();
    try {
      final authenticationRepository =
          ref.watch(authenticationRepositoryProvider);
      final response =
          await authenticationRepository.changePassword(id, password);

      state = ChangePasswordStates.success(response.data);
    } catch (e, s) {
      state = ChangePasswordStates.error(
        e.toString(), stackTrace: s
      );
    }
  }
}

typedef ChangePasswordStates = BaseState<Map>;

final changePasswordProvider = StateNotifierProvider.autoDispose<
    ChnagePasswordNotifier, ChangePasswordStates>(
  (ref) => ChnagePasswordNotifier(ChangePasswordStates.initial(), ref),
);
