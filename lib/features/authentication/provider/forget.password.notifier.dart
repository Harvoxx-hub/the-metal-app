import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';

class ForgetPasswordNotifier extends StateNotifier<ForgetPasswordStates> {
  ForgetPasswordNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  void forgetPassword({
    required String email,
  }) async {
    state = ForgetPasswordStates.loading();
    try {
      final authenticationRepository =
          ref.watch(authenticationRepositoryProvider);
      final response = await authenticationRepository.forgetPassword(
        email,
      );
      if (mounted) {
        state = ForgetPasswordStates.success(response.data);
      }
    } catch (e, s) {
      state = ForgetPasswordStates.error(e.toString(), stackTrace: s);
    }
  }
}

typedef ForgetPasswordStates = BaseState<Map>;

final forgetPasswordProvider = StateNotifierProvider.autoDispose<
    ForgetPasswordNotifier, ForgetPasswordStates>(
  (ref) => ForgetPasswordNotifier(ForgetPasswordStates.initial(), ref),
);
