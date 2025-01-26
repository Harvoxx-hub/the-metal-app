import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
      if (response.success ?? false) {
        if (mounted) {
          Fluttertoast.showToast(
              msg: "Instructions have been sent to your Email");
          state = ForgetPasswordStates.success("");
        }
      } else {
        state = ForgetPasswordStates.error(response.message!);
      }
    } catch (e, s) {
      state = ForgetPasswordStates.error(e.toString(), stackTrace: s);
    }
  }
}

typedef ForgetPasswordStates = BaseState<String>;

final forgetPasswordProvider = StateNotifierProvider.autoDispose<
    ForgetPasswordNotifier, ForgetPasswordStates>(
  (ref) => ForgetPasswordNotifier(ForgetPasswordStates.initial(), ref),
);
