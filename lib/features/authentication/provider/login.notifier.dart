import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/error/error.handle.dart';
 
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
      final tokenManager = ref.read(authManagerProvider);
      await tokenManager.saveAccessToken(response.data['access_token']);
      await tokenManager.saveRefreshToken(response.data['refresh_token']);
      await tokenManager.saveLoginState(LoginState.loggedIn);
      ref
          .read(authProvider.notifier)
          .updateUserData(UserModel.fromJson(response.data));
      state = LoginStates.success(UserModel.fromJson(response.data));
    } catch (e) {
      AppError error = e as AppError;

      state = LoginStates.error(error.message, errorData: e.errorData);
    }
  }
}

typedef LoginStates = BaseState<UserModel>;

final loginProvider =
    StateNotifierProvider.autoDispose<LoginNotifier, LoginStates>(
  (ref) => LoginNotifier(LoginStates.initial(), ref),
);
