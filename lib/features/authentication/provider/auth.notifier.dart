import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/utils/constant/common.dart';
import 'package:metal/core/utils/constant/constants.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';

import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import '../../../core/utils/permission_helper.dart';

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

  

  

  Future<void> initZIMKIt() async {
    if (state.data != null) {
      // Use the new permission helper for better permission handling
      // Note: We need a BuildContext for the permission helper
      // You might want to pass this context from where initZIMKIt is called
      // For now, we'll use the existing logic but with better error handling

      if (Platform.isAndroid) {
        final status = await Permission.systemAlertWindow.status;
        if (status.isDenied) {
          await Permission.systemAlertWindow.request();
        }
      } else if (Platform.isIOS) {
        // Check existing permissions first
        final cameraStatus = await Permission.camera.status;
        final microphoneStatus = await Permission.microphone.status;
        final notificationStatus = await Permission.notification.status;

        // Only request permissions that are not already granted
        final permissionsToRequest = <Permission>[];

        if (cameraStatus.isDenied) {
          permissionsToRequest.add(Permission.camera);
        }
        if (microphoneStatus.isDenied) {
          permissionsToRequest.add(Permission.microphone);
        }
        if (notificationStatus.isDenied) {
          permissionsToRequest.add(Permission.notification);
        }

        // Only request if there are permissions to request
        if (permissionsToRequest.isNotEmpty) {
          final results = await permissionsToRequest.request();

          // Check if any critical permissions were permanently denied
          bool hasCriticalPermissionDenied = false;
          for (final permission in permissionsToRequest) {
            final status = await permission.status;
            if (status.isPermanentlyDenied) {
              hasCriticalPermissionDenied = true;
              break;
            }
          }

          // If critical permissions are permanently denied, show a dialog
          if (hasCriticalPermissionDenied) {
            // You can show a custom dialog here explaining why permissions are needed
            // For now, we'll just log it and continue without forcing settings
            print(
                'Some permissions are permanently denied. Call features may be limited.');
          }
        }
      }

      // Initialize ZegoUIKit regardless of permission status
      // The SDK will handle permission requests internally when needed
      ZegoUIKitPrebuiltCallInvitationService().init(
        appID: appIDKey,
        appSign: appSignKey,
        userID: state.data!.id!,
        userName: state.data!.username!,
        plugins: [ZegoUIKitSignalingPlugin()],
        notificationConfig: ZegoCallInvitationNotificationConfig(
          androidNotificationConfig: ZegoCallAndroidNotificationConfig(
            showFullScreen: true,
            fullScreenBackgroundAssetURL: 'assets/image/call.png',
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

  // Add a new method that can be called with context for better permission handling
  Future<void> initZIMKItWithContext(BuildContext context) async {
    if (state.data != null) {
      // // Check if permissions are already granted first
      // final hasPermissions = await PermissionHelper.checkCallPermissions();

      // if (hasPermissions) {
      //   // Permissions are already granted, initialize directly without showing dialogs
      //   _initializeZegoUIKit();
      //   return;
      // }

      // // Only show permission explanation dialog if permissions are not granted
      // final shouldRequestPermissions =
      //     await PermissionHelper.showPermissionExplanationDialogIfNeeded(
      //         context);

      // if (shouldRequestPermissions) {
      //   // Use the permission helper for better permission handling
      //   final permissionsGranted =
      //       await PermissionHelper.requestCallPermissionsIfNeeded(context);

      //   if (!permissionsGranted) {
      //     // Show limited functionality dialog
      //     await PermissionHelper.showLimitedFunctionalityDialog(context);
      //   }
      // } else {
      //   // User chose "Not Now", show limited functionality dialog
      //   await PermissionHelper.showLimitedFunctionalityDialog(context);
      // }

      // // Initialize ZegoUIKit regardless of permission status
      // // The SDK will handle permission requests internally when needed
      _initializeZegoUIKit();
    }
  }

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
          fullScreenBackgroundAssetURL: 'assets/image/call.png',
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
