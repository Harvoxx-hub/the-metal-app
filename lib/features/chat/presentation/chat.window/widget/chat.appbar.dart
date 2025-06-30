import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:metal/core/services/firebase.remote.config.service.dart';
import 'package:metal/core/utils/constant/enums.dart';

import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/core/utils/image_picker_util.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/authentication/provider/unmelt_days_notifier.dart';

import 'package:metal/features/chat/domain/entries/message.model.dart';
import 'package:metal/features/chat/presentation/widget/profile.image.dart';

import 'package:metal/features/chat/provider/get.message.notifier.dart';
import 'package:metal/features/chat/provider/send.message.notifier.dart';

import 'package:metal/features/home_page/domain/entries/connection.model.dart';
import 'package:metal/features/home_page/provider/check.melt.status.notifier.dart';
import 'package:metal/features/home_page/provider/get.connection.notifier.dart';

import 'package:metal/features/profile/presentation/widget/profile.header.dart';

import 'package:metal/features/settings/provider/block.user.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';

import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:metal/core/utils/permission_helper.dart';

class ChatWindowsAppBar extends ConsumerStatefulWidget {
  const ChatWindowsAppBar({
    super.key,
    required this.meltUserModel,
    required this.connectionModel,
  });
  final UserModel meltUserModel;
  final ConnectionModel connectionModel;
  @override
  ConsumerState<ChatWindowsAppBar> createState() => _ChatWindowsAppBarState();
}

class _ChatWindowsAppBarState extends ConsumerState<ChatWindowsAppBar> {
  final tooltipController = JustTheController();
  final tooltipController2 = JustTheController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int dayRemaining = daysRemaining(widget.connectionModel.connectedOn,
        FirebaseRemoteConfigService().getDaysRequiredToUnMelt());
    print("CHECK FOR ACTIVE USER:${widget.meltUserModel.isOnline}");

    final checkMeltState =
        ref.watch(checkMeltProvider(widget.meltUserModel.id!));

    /// Determines if the user is allowed to call
    bool isCallAllowed = checkMeltState.data == MeltRequestState.connected;

    /// Function to check call eligibility
    Future<bool> handleCallPress(
        JustTheController tooltip, String callType) async {
      if (widget.connectionModel.isAnonymous) {
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
          return false;
        }

        sendCall(callType);
      } catch (e) {
        debugPrint('Error checking ZegoCloud connection state: $e');
        return false;
      }

      return true;
    }

    /// Function to create call button with tooltip
    Widget buildCallButton({
      required bool isVideoCall,
      required JustTheController tooltip,
      required String tooltipText,
      required String iconPath,
    }) {
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
            resourceID: 'metal_call',
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
            onWillPressed: () => handleCallPress(
                tooltip, isVideoCall ? "Video call" : "Voice call"),
          ),
        ),
      );
    }

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
              url: widget.connectionModel.isAnonymous == false
                  ? widget.meltUserModel.profilePhoto
                  : null),
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
                  builder: (BuildContext context) {
                    return CustomDialog(
                      content: unmetalDialog(context, dayRemaining),
                    );
                  },
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
              if (widget.connectionModel.isAnonymous)
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

  Widget unmetalDialog(BuildContext context, int remaining) {
    final connectionModel =
        ref.watch(getConnectionProvider(widget.connectionModel.connectionId));
    final currentUser = ref.watch(authProvider).data;
    final daysRequired = ref.watch(numberDaysProvider);
    final uniqueDailyConversations =
        connectionModel.data?.uniqueDailyConversationsCount ?? 0;

    // Force refresh user data to get the latest profile photo
    ref.read(authProvider.notifier).getUpdatedUser();

    // Improved check for profile photo existence
    final hasProfilePhoto = currentUser?.profilePhoto != null &&
        currentUser!.profilePhoto!.isNotEmpty &&
        currentUser.profilePhoto!.trim().isNotEmpty;
    final otherUserHasPhoto = widget.meltUserModel.profilePhoto != null &&
        widget.meltUserModel.profilePhoto!.isNotEmpty &&
        widget.meltUserModel.profilePhoto!.trim().isNotEmpty;

    final missingYourPhoto = !hasProfilePhoto;
    final missingOtherPhoto = !otherUserHasPhoto;

    // Only block proceeding if the current user is missing a photo
    if (missingYourPhoto) {
      return Column(
        children: [
          const Gap(38),
          const TextView(
            text: "Want to Unmetal?",
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          const Gap(15),
          const TextView(
            text:
                "Wait a minute, we are missing your photo! To unmetal means that the two profiles can view each others photos",
            fontSize: 16,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w400,
          ),
          const Gap(15),
          const TextView(
            text: "To continue",
            fontSize: 16,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w400,
          ),
          const Gap(38),
          BaseButton(
            buttonText: "Upload your photo",
            onPressed: () {
              Navigator.pop(context);
              ImagePickerUtil.pickImage(context, ref);
            },
          ),
          const Gap(23),
        ],
      );
    }

    // Warn about the other user's missing photo but allow proceeding
    if (missingOtherPhoto) {
      return Column(
        children: [
          const Gap(38),
          const TextView(
            text: "Want to Unmetal?",
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          const Gap(15),
          const TextView(
            text:
                "The other user doesn't have a profile photo yet. They will be asked to upload one when accepting your request.",
            fontSize: 16,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w400,
          ),
          const Gap(15),
          TextView(
            text:
                "Do you still want to send an unmetal request to @${widget.meltUserModel.username}?",
            fontSize: 16,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w400,
          ),
          const Gap(38),
          Row(
            children: [
              Expanded(
                child: BaseButton(
                  buttonText: "Cancel",
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const Gap(10),
              Expanded(
                child: BaseButton(
                  buttonText: "Send Request",
                  onPressed: () {
                    Navigator.pop(context);
                    sendUnmelt();
                  },
                ),
              ),
            ],
          ),
          const Gap(23),
        ],
      );
    }

    return Column(
      children: [
        const Gap(38),
        const TextView(
          text: "Want to Unmetal?",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        const Gap(15),
        TextView(
          text:
              "To Unmetal, we require a minimum of $daysRequired days and 10 sessions of conversations between you and @${widget.meltUserModel.username}",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(15),
        TextView(
          text:
              "You have had $remaining days and $uniqueDailyConversations interactions",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(38),
        (remaining <= 0 && uniqueDailyConversations >= 10)
            ? BaseButton(
                buttonText: "Return to chat",
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            : BaseButton(
                buttonText: "Unmetal",
                onPressed: () {
                  sendUnmelt();
                },
              ),
        const Gap(23),
      ],
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

  Widget unmetalRequestSentDialog(BuildContext context) {
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
              "We have sent your request to @${widget.meltUserModel.username}. We will notify you when we get a response",
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

  void sendUnmelt() {
    final message = MessageModel(
      senderId: ref.watch(authProvider).data!.id!,
      type: MessageType.un_melt,
      timestamp: DateTime.now().toIso8601String(),
      isRead: false,
      message: "Un-melt Request",
    );

    ref
        .read(sendMessageProvider.notifier)
        .sendMessage(message, widget.connectionModel.connectionId);

    // Show the sent confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          content: unmetalRequestSentDialog(context),
        );
      },
    );
  }

  void sendCall(String callType) {
    final message = MessageModel(
      content: callType,
      senderId: ref.watch(authProvider).data!.id!,
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
