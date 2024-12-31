import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';

import 'package:metal/features/authentication/domain/entries/user.model.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(
    super.state,
    this.ref,
  ) {
  }

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
      // initZIMKIt();
    } catch (e, s) {
      state = AuthState.error(e.toString(), stackTrace: s);
    }
  }

  Future getUpdatedUser() async {
    try {
      final authenticationRepository =
          ref.watch(authenticationRepositoryProvider);
      final response = await authenticationRepository.getCurrentUser();
      final userData = UserModel.fromJson(response.data);
      state = AuthState.success(userData);
    } catch (e) {
      print(e.toString());
    }
  }

  //update state with new user data
  Future<void> updateUserData(UserModel userData) async {
    state = AuthState.success(userData);
    //  initZIMKIt();
  }

  void initZIMKIt() {
    // ZegoUIKitPrebuiltCallInvitationService().init(
    //   appID: 1856538990 /*input your AppID*/,
    //   appSign: "23d0ea4be7d7668a83f511adac01c5fd3e8727a59c24357700af9f6beddfc3b1" /*input your AppSign*/,
    //   userID: state.data!.phone!,
    //   userName: state.data!.username!,
    //   plugins: [ZegoUIKitSignalingPlugin()],
    // );
  }
 
}

// Define a type alias
typedef AuthState = BaseState<UserModel>;

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(AuthState.initial(), ref),
);
