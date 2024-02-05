import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/services/auth.manager.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';

class VerficationNotifier extends StateNotifier<VerficationState> {
  VerficationNotifier(
    VerficationState state,
    this.ref,
  ) : super(state) {}
  final Ref ref;

  void activateAccount() async {
    state = VerficationState.loading();
    try {
      final authenticationRepository =
          ref.watch(authenticationRepositoryProvider);
      final response = await authenticationRepository.activateAccount();
      final tokenManager = ref.read(authManagerProvider);
      await tokenManager.saveLoginState(LoginState.loggedIn);
      state = VerficationState.success("");
    } catch (e) {
      print(e.toString());
      state = VerficationState.error(e.toString());
    }
  }
}

// Define a type alias
typedef VerficationState = BaseState<String>;

final verficationProvider =
    StateNotifierProvider.autoDispose<VerficationNotifier, VerficationState>(
  (ref) => VerficationNotifier(VerficationState.initial(), ref),
);
