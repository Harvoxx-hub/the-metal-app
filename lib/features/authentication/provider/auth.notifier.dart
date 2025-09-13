import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/utils/constant/common.dart';
import 'package:metal/core/utils/constant/constants.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';

import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import '../../../core/utils/permission_helper.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(
    super.state,
    this.ref,
  ) {
    getCurrentUser();
  }

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

  // Add a new method that can be called with context for better permission handling
  Future<void> initZIMKItWithContext(BuildContext context) async {
    /// add 3 seconds delay
    await Future.delayed(const Duration(seconds: 5));
    _initializeZegoUIKit();
  }

  // Private method to initialize ZegoUIKit without permission dialogs
// Private method to initialize ZegoUIKit without permission dialogs
  void _initializeZegoUIKit() {
    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: appIDKey,
      appSign: appSignKey,
      userID: state.data!.id!,
      userName: state.data!.username!,
      plugins: [ZegoUIKitSignalingPlugin()],
      notificationConfig: ZegoCallInvitationNotificationConfig(
        androidNotificationConfig: ZegoCallAndroidNotificationConfig(
          showFullScreen: true,
          fullScreenBackgroundAssetURL: 'assets/images/voice_bg.png',
          callChannel: ZegoCallAndroidNotificationChannelConfig(
            channelID: "ZegoUIKit",
            channelName: "Call Notifications",
            sound: "call",
            icon: "call",
          ),
          missedCallChannel: ZegoCallAndroidNotificationChannelConfig(
            channelID: "MissedCall",
            channelName: "Missed Call",
            sound: "missed_call",
            icon: "missed_call",
            vibrate: false,
          ),
        ),
        iOSNotificationConfig: ZegoCallIOSNotificationConfig(
          systemCallingIconName: 'CallKitIcon',
        ),
      ),
      requireConfig: (ZegoCallInvitationData data) {
        final config = (data.invitees.length > 1)
            ? ZegoCallInvitationType.videoCall == data.type
                ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
                : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
            : ZegoCallInvitationType.videoCall == data.type
                ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

        // Show top menu
        config.topMenuBar.isVisible = true;

        // Optional: customize buttons
        config.topMenuBar.buttons
            .insert(0, ZegoCallMenuBarButtonName.minimizingButton);
        config.topMenuBar.buttons
            .insert(1, ZegoCallMenuBarButtonName.soundEffectButton);

        return config;
      },
    );
  }

  // Add a method to check if call permissions are available
  Future<bool> hasCallPermissions() async {
    return await PermissionHelper.checkCallPermissions();
  }

  // Add a method to request permissions before making calls
  Future<bool> requestCallPermissionsIfNeeded(BuildContext context) async {
    return await PermissionHelper.requestCallPermissions(context);
  }

  // Add a method to handle permission requests before making calls
  Future<bool> handleCallPermissionsBeforeCall(BuildContext context) async {
    // Check if permissions are already granted
    final hasPermissions = await PermissionHelper.checkCallPermissions();

    if (hasPermissions) {
      return true; // Permissions already granted, no need for dialogs
    }

    // Only show permission explanation dialog if permissions are not granted
    final shouldRequestPermissions =
        await PermissionHelper.showPermissionExplanationDialogIfNeeded(context);

    if (shouldRequestPermissions) {
      // Request permissions
      final granted =
          await PermissionHelper.requestCallPermissionsIfNeeded(context);

      if (!granted) {
        // Show limited functionality dialog
        await PermissionHelper.showLimitedFunctionalityDialog(context);
      }

      return granted;
    } else {
      // User chose "Not Now"
      await PermissionHelper.showLimitedFunctionalityDialog(context);
      return false;
    }
  }

  // Add a method to handle Android display permission specifically
  Future<bool> requestAndroidDisplayPermission(BuildContext context) async {
    return await PermissionHelper.requestAndroidDisplayPermission(context);
  }

  // Add a method to check Android display permission
  Future<bool> hasAndroidDisplayPermission() async {
    return await PermissionHelper.hasAndroidDisplayPermission();
  }

  // Add a method to handle all Android call permissions
  Future<bool> handleAndroidCallPermissions(BuildContext context) async {
    if (Platform.isAndroid) {
      return await PermissionHelper.requestAndroidDisplayPermission(context);
    }
    return true; // Not applicable on iOS
  }

  // Add a method to handle incoming call permissions
  Future<bool> handleIncomingCallPermissions(BuildContext context) async {
    return await PermissionHelper.handleIncomingCallPermissions(context);
  }
}

// Define a type alias
typedef AuthState = BaseState<UserModel>;

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(AuthState.initial(), ref),
);
