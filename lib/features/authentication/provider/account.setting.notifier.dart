import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/api.service.dart';
import 'package:metal/core/services/token.manager.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';

class AccountSettingNotifier extends StateNotifier<AccountSettingState> {
  AccountSettingNotifier(
    AccountSettingState state,
    this.ref,
  ) : super(state) {}
  final Ref ref;

  //sign up
  void signup({
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    state = AccountSettingState.loading();
    try {
      final authenticationRepository =
          ref.watch(authenticationRepositoryProvider);
      final response = await authenticationRepository.signUp(
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );
      final tokenManager = ref.read(tokenManagerProvider);
      await tokenManager.saveAccessToken(response.data['access_token']);
      state = AccountSettingState.success(response.message);
    } catch (e) {
      print(e.toString());
      state = AccountSettingState.error(e.toString());
    }
  }
}

// Define a type alias
typedef AccountSettingState = BaseState<String>;

final accountSettingProvider =
    StateNotifierProvider<AccountSettingNotifier, AccountSettingState>(
  (ref) => AccountSettingNotifier(AccountSettingState.initial(), ref),
);
