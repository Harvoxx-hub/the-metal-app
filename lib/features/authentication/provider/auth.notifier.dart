import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/utils/constant/common.dart';
import 'package:metal/core/utils/constant/constants.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';

import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

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

      print("USER RESPONSE: ${response.data}");

      final userData = UserModel.fromJson(response.data);
      print("USER DATA: ${userData.id}");
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
    if (state.data != null) {
      if (Platform.isAndroid) {
        final status = await Permission.systemAlertWindow.status;
        if (status.isDenied) {
          await Permission.systemAlertWindow.request();
        }
      } else if (Platform.isIOS) {
        // Request iOS permissions
        await [
          Permission.camera,
          Permission.microphone,
          Permission.notification,
        ].request();
      }
      ZegoUIKitPrebuiltCallInvitationService().init(
        appID: appIDKey,
        appSign: appSignKey,
        userID: state.data!.id!,
        userName: state.data!.username!,
        plugins: [ZegoUIKitSignalingPlugin()],
        requireConfig: (ZegoCallInvitationData data) {
          final config = (data.invitees.length > 1)
              ? ZegoCallInvitationType.videoCall == data.type
                  ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
                  : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
              : ZegoCallInvitationType.videoCall == data.type
                  ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                  : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

          config.topMenuBar.isVisible = true;
          config.avatarBuilder = customAvatarBuilder;
          config.topMenuBar.buttons
              .insert(0, ZegoCallMenuBarButtonName.minimizingButton);
          config.topMenuBar.buttons
              .insert(1, ZegoCallMenuBarButtonName.soundEffectButton);

          return config;
        },
      );
    }
  }
}

// Define a type alias
typedef AuthState = BaseState<UserModel>;

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(AuthState.initial(), ref),
);
