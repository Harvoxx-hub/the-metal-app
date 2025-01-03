import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';

class LoginNotifier extends StateNotifier<LoginStates> {
  LoginNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  //login user
  void login({
    required String email,
    required String password,
  }) async {
    state = LoginStates.loading();
    debugPrint("LOGIN STATE:$state");
    try {
      final authenticationRepository =
          ref.watch(authenticationRepositoryProvider);
      final response = await authenticationRepository.logIn(
        email: email,
        password: password,
      );

      if (response.success!) {
        final Map<String, dynamic> data = response.data;
        ref
            .read(authProvider.notifier)
            .updateUserData(UserModel.fromJson(data));
        state = LoginStates.success(UserModel.fromJson(data));
        debugPrint("LOGIN RESPONSE SUCCESS:${response.success}");
      } else {
        debugPrint("LOGIN ERROR RESPONSE:$response");
        state = LoginStates.error(
          response.message!,
        );
      }
    } catch (e, s) {
      debugPrint('LOGIN Error: $e, LOGIN StackTrace: $s');
      state = LoginStates.error(e.toString(), stackTrace: s);
    }
  }
}

typedef LoginStates = BaseState<UserModel>;

final loginProvider =
    StateNotifierProvider.autoDispose<LoginNotifier, LoginStates>(
  (ref) => LoginNotifier(LoginStates.initial(), ref),
);
