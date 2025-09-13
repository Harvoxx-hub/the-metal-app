import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';
 
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:metal/widgets/call_avatar.dart';

// Export the new callAvatarBuilder for backward compatibility
ZegoAvatarBuilder get customAvatarBuilder => (
      BuildContext context,
      Size size,
      ZegoUIKitUser? user,
      Map<String, dynamic> extraInfo,
    ) {
      return CallAvatar(user: user, size: size);
    };
