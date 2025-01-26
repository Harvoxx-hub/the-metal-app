import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/utils/constant/constants.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';

import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/main.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(
    super.state,
    this.ref,
  ) {}

  final Ref ref;

  //get current user
  void getCurrentUser() async {
    state = AuthState.loading();
    try {
      final authenticationRepository =
          ref.watch(authenticationRepositoryProvider);
      final response = await authenticationRepository.getCurrentUser();

      // Add null check
      if (response.data == null) {
        state = AuthState.error('No user data available');
        return;
      }

      final userData = UserModel.fromJson(response.data);
      state = AuthState.success(userData);
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

  Future<void> initZIMKIt() async {
         
    // if (state.data != null) {
    //   ZegoUIKitPrebuiltCallInvitationService().init(
    //     appID: appIDKey,
    //     appSign: appSignKey,
    //     userID: state.data! .id!,
    //     userName: state.data! .username!,
    //     plugins: [ZegoUIKitSignalingPlugin()],
    //   );
    // }
  }
}

// Define a type alias
typedef AuthState = BaseState<UserModel>;

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(AuthState.initial(), ref),
);
