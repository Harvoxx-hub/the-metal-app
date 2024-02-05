import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';

import 'package:metal/features/authentication/domain/entries/user.model.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(
    AuthState state,
    this.ref,
  ) : super(state) {}
  final Ref ref;

  //get current user
  void getCurrentUser() async {
    state = AuthState.loading();
    try {
      final authenticationRepository =
          ref.watch(authenticationRepositoryProvider);
      final response = await authenticationRepository.getCurrentUser();
      final userData = UserModel.fromJson(response.data);
      state = AuthState.success(userData);
    } catch (e) {
      print(e.toString());
      state = AuthState.error(e.toString());
    }
  }

  //update state with new user data
  void updateUserData(UserModel userData) {
    state = AuthState.success(userData);
  }
}

// Define a type alias
typedef AuthState = BaseState<UserModel>;

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(AuthState.initial(), ref),
);
