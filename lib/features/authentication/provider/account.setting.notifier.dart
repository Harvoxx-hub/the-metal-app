import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';

class AccountSettingNotifier extends StateNotifier<AccountSettingState> {
  AccountSettingNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  //sign up
  void signup({
    required String email,
    required String password,
    required String phoneNumber,
    String? referal
  }) async {
    state = AccountSettingState.loading();
    try {
      final authenticationRepository =
          ref.watch(authenticationRepositoryProvider);
      final response = await authenticationRepository.signUp(
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        referal: referal
      );
      state = AccountSettingState.success(response.data);
    } catch (e,s) {
      
      state = AccountSettingState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef AccountSettingState = BaseState<Map>;

final accountSettingProvider = StateNotifierProvider.autoDispose<
    AccountSettingNotifier, AccountSettingState>(
  (ref) => AccountSettingNotifier(AccountSettingState.initial(), ref),
);
