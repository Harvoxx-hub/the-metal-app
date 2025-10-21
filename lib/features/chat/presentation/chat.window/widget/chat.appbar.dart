import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:metal/features/unmetal/widgets/unmetal_dialog.dart';
import 'package:metal/core/utils/constant/constants.dart';

import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';

import 'package:metal/features/chat/domain/entries/message.model.dart';
import 'package:metal/features/chat/presentation/widget/profile.image.dart';

import 'package:metal/features/chat/provider/get.message.notifier.dart';
import 'package:metal/features/chat/provider/send.message.notifier.dart';

import 'package:metal/features/thought/data/domain/entries/connection.model.dart';

import 'package:metal/features/thought/provider/get.connection.notifier.dart';

import 'package:metal/features/settings/provider/block.user.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';

import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'dart:io';
import 'package:metal/core/utils/permission_helper.dart';

class ChatWindowsAppBar extends ConsumerStatefulWidget {
  const ChatWindowsAppBar({
    super.key,
    required this.meltUserModel,
    required this.connectionModel,
  });
  final UserModel meltUserModel;
  final connectionModel;
  @override
  ConsumerState<ChatWindowsAppBar> createState() => _ChatWindowsAppBarState();
}

class _ChatWindowsAppBarState extends ConsumerState<ChatWindowsAppBar> {
  final tooltipController = JustTheController();
  final tooltipController2 = JustTheController();
  ConnectionModel? _connectionModel;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    _connectionModel = widget.connectionModel;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("CHECK FOR ACTIVE USER:${widget.meltUserModel.isOnline}");

    /// Function to check call eligibility
    Future<bool> handleCallPress(
        JustTheController tooltip, String callType) async {
      if (_connectionModel?.isAnonymous ?? true) {
        tooltip.showTooltip();
        return false;
      }

      try {
        // Check permissions before making the call
        final authNotifier = ref.read(authProvider.notifier);
        final hasPermissions =
            await authNotifier.handleCallPermissionsBeforeCall(context);

        if (!hasPermissions) {
          // Permissions were denied, don't proceed with the call
          // On iOS, show a one-time explanation dialog if permissions are denied
          if (Platform.isIOS) {
            await PermissionHelper.showPermissionExplanationDialog(context);
          }
          return false;
        }

        final connectionState = ZegoUIKitSignalingPlugin().getConnectionState();

        if (connectionState != ZegoSignalingPluginConnectionState.connected) {
          debugPrint(
              'ZegoCloud service not connected. State: $connectionState');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Unable to connect to call service. Please try again.'),
            ),
          );
          return false;
        }

        // Only send the call message if all checks pass
        sendCall(callType);
        return true;
      } catch (e) {
        debugPrint('Error checking ZegoCloud connection state: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('An error occurred while trying to initiate the call.'),
          ),
        );
        return false;
      }
    }

    /// Function to create call button with tooltip
    Widget buildCallButton({
      required bool isVideoCall,
      required JustTheController tooltip,
      required String tooltipText,
      required String iconPath,
    }) {
      final isAnonymous = _connectionModel?.isAnonymous ?? true;
      final isCallAllowed =
          !isAnonymous && widget.meltUserModel.profilePhoto != null;

      return JustTheTooltip(
        controller: tooltip,
        content: SizedBox(
          width: 180,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(tooltipText),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: ZegoSendCallInvitationButton(
            isVideoCall: isVideoCall,
            invitees: [
              ZegoUIKitUser(
                id: widget.meltUserModel.id!,
                name: widget.meltUserModel.username!,
              ),
            ],
            resourceID: resourceID,
            iconSize: const Size(30, 30),
            buttonSize: const Size(40, 40),
            icon: ButtonIcon(
              icon: SvgPicture.asset(
                iconPath,
                height: 30,
                width: 30,
                color: isCallAllowed ? Colors.black : Colors.grey,
              ),
            ),
            //    iconVisible: false,
            onWillPressed: () => handleCallPress(
                tooltip, isVideoCall ? "Video call" : "Voice call"),
          ),
        ),
      );
    }

    // Watch the connection to update UI when isAnonymous changes
    bool isAnonymous = _connectionModel?.isAnonymous ?? true;

    ref.listen(getConnectionProvider(widget.connectionModel.connectionId),
        (previous, next) {
      if (next.isSuccess) {
        _connectionModel = next.data;
        setState(() {});
      }
    });

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SvgPicture.asset(
              Assets.icons.chatsWindowactiveCaretLeft.path,
              height: 32,
              width: 32,
            ),
          ),
          const Gap(3),
          ProfileImage(
            width: 42,
            height: 42,
            metalID: widget.meltUserModel.metal ?? "",
            url: isAnonymous ? null : widget.meltUserModel.profilePhoto,
          ),
          const Gap(3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextView(
                text: "@${widget.meltUserModel.username!}",
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              const Gap(3),
              TextView(
                text: getAccurateOnlineStatus(
                  isOnline: widget.meltUserModel.isOnline,
                  showOnline: widget.meltUserModel.showOnline,
                  lastActive: widget.meltUserModel.lastActive,
                  maxOfflineMinutes: 5, // Consider offline after 5 minutes
                ),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.metalBlack50,
              ),
            ],
          ),
          const Spacer(),
          buildCallButton(
            isVideoCall: true,
            tooltip: tooltipController,
            tooltipText: 'Video call is available after mutual Unmetal.',
            iconPath: Assets.icons.chatsWindowactiveVideoRecorder.path,
          ),
          const Gap(15),

          /// Audio Call Button
          buildCallButton(
            isVideoCall: false,
            tooltip: tooltipController2,
            tooltipText: 'Voice call is available after mutual Unmetal.',
            iconPath: Assets.icons.chatsWindowactiveFill.path,
          ),
          const Gap(15),
          PopupMenuButton(
            color: Colors.white,
            child: SvgPicture.asset(
              Assets.icons.chatsWindowactiveSrMenuVerticalLite.path,
              height: 24,
              width: 24,
            ),
            onSelected: (value) {
              if (value == "Unmetal") {
                showDialog(
                  context: context,
                  builder: (context) => UnmetalDialog(
                    otherUser: widget.meltUserModel,
                    connectionModel: widget.connectionModel,
                  ),
                );
              } else if (value == "Rejected") {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomDialog(
                      content: unmetalRequestDialog(context),
                    );
                  },
                );
              } else if (value == "View contact") {
                Navigator.pushNamed(context, AppRoutes.myMeltedUser,
                    arguments: {
                      "metalId": widget.meltUserModel.id!,
                      "metalName": widget.meltUserModel.username!,
                    });
              } else if (value == "Clear chat") {
                ref
                    .read(getMessageList(widget.connectionModel.connectionId)
                        .notifier)
                    .clearChat();
                Navigator.pop(context);
              } else if (value == "Block") {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomDialog(
                      content: _blockDialog(
                        context,
                        widget.meltUserModel,
                      ),
                    );
                  },
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                value: "View contact",
                child: TextView(
                  text: 'View contact',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_connectionModel?.isAnonymous ?? true)
                const PopupMenuItem(
                  value: "Unmetal",
                  child: TextView(
                    text: 'Unmetal',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              // const PopupMenuItem(
              //   value: "Unblock from audio call",
              //   child: TextView(
              //     text: 'Unblock from audio call',
              //     fontSize: 15,
              //     fontWeight: FontWeight.w500,
              //   ),
              // ),
              // const PopupMenuItem(
              //   value: "Unblock from video call",
              //   child: TextView(
              //     text: 'Unblock from video call',
              //     fontSize: 15,
              //     fontWeight: FontWeight.w500,
              //   ),
              // ),
              const PopupMenuItem(
                value: "Clear chat",
                child: TextView(
                  text: 'Clear chat',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const PopupMenuItem(
                value: "Block",
                child: TextView(
                  text: 'Block',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget unmetalRequestDialog(BuildContext context) {
    return Column(
      children: [
        const Gap(38),
        const TextView(
          text: "Unmetal request",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        const Gap(15),
        TextView(
          text:
              "@${widget.meltUserModel.username} has opted to always be a Metal.\nThis request cannot be sent.",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(38),
        BaseButton(
          buttonText: "Return to chat",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        const Gap(23),
      ],
    );
  }

  void sendCall(String callType) {
    final message = MessageModel(
      content: callType,
      senderId: ref.watch(userStateProvider).data!.id!,
      type: MessageType.calls,
      timestamp: DateTime.now().toIso8601String(),
      isRead: false,
      message: "Call Request",
    );

    ref
        .read(sendMessageProvider.notifier)
        .sendMessage(message, widget.connectionModel.connectionId);
  }

  Widget _blockDialog(BuildContext context, UserModel data) {
    return Column(
      children: [
        const Gap(38),
        SvgPicture.asset(
          Assets.icons.meltedMetalsSmileyXEyes.path,
          height: 45,
          width: 45,
        ),
        const Gap(15),
        TextView(
          text: "Block  ${data.username} ",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        const Gap(15),
        const TextView(
          text:
              "Blocked metals cannot call or send you messages. This Metal will not be notified",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(38),
        BaseButton(
            buttonText: "Block  ${data.username}",
            onPressed: () {
              ref
                  .read(blockUserProvider.notifier)
                  .blockUser(data.username!, data.id!);
              Navigator.pop(context);
            }),
        const Gap(23),
        TextView(
          text: "Cancel",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          onTap: () => Navigator.pop(context),
        ),
        const Gap(21),
      ],
    );
  }
}
