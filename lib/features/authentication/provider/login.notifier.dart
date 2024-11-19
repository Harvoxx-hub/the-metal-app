import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/services/auth.pref.service.dart';

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
    try {
      final authenticationRepository =
          ref.watch(authenticationRepositoryProvider);
      final response = await authenticationRepository.logIn(
        email: email,
        password: password,
      );

      if (response.action == "ENTER OTP") {
        state = LoginStates.action(action: response.data);
      } else {
        await AuthManager.saveAccessToken(response.data['access_token']);
        await AuthManager.saveRefreshToken(response.data['refresh_token']);
        await AuthManager.saveLoginState(LoginState.loggedIn);
        ref
            .read(authProvider.notifier)
            .updateUserData(UserModel.fromJson(response.data));
        state = LoginStates.success(UserModel.fromJson(response.data));
      }
    } catch (e, s) {
      state = LoginStates.error(e.toString(), stackTrace: s);
    }
  }
}

typedef LoginStates = BaseState<UserModel>;

final loginProvider =
    StateNotifierProvider.autoDispose<LoginNotifier, LoginStates>(
  (ref) => LoginNotifier(LoginStates.initial(), ref),
);
