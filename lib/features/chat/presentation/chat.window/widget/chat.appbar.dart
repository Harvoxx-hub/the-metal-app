import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/chat/domain/entries/message.model.dart';
import 'package:metal/features/chat/presentation/widget/profile.image.dart';
import 'package:metal/features/chat/provider/get.last.active.notifier.dart';
import 'package:metal/features/chat/provider/get.message.notifier.dart';
import 'package:metal/features/chat/provider/send.message.notifier.dart';
import 'package:metal/features/home_page/domain/entries/connection.model.dart';

import 'package:metal/features/settings/provider/block.user.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';

import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(lastActiveProvider.notifier)
          .GetLastActiveTime(widget.meltUserModel.id!);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final time = ref.watch(lastActiveProvider).data;
    int dayRemaining = daysRemaining(widget.connectionModel.connectedOn, 5);
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
                text: "@${widget.meltUserModel.username! ?? ""}",
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              const Gap(3),
              TextView(
                text: widget.meltUserModel.isOnline
                    ? "active"
                    : ActiveTime(
                        isoDateString: widget.meltUserModel.lastActive ??
                            DateTime.now().toIso8601String()),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.metalBlack50,
              ),
            ],
          ),
          const Spacer(),
          JustTheTooltip(
            controller: tooltipController,
            content: SizedBox(
              width: 180,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Video call features are enabled after 5 days. $dayRemaining days remaining. Please wait.',
                ),
              ),
            ),
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: GestureDetector(
                onTap: () {
                  makeVideoCall(context);
                  // if (hasDurationReached(
                  //     widget.connectionModel.connectedOn, 5)) {

                  // } else {
                  //   tooltipController.showTooltip();
                  // }
                },
                child: SvgPicture.asset(
                  Assets.icons.chatsWindowactiveVideoRecorder.path,
                  height: 30,
                  width: 30,
                ),
              ),
            ),
          ),
          const Gap(15),
          JustTheTooltip(
            controller: tooltipController2,
            content: SizedBox(
              width: 180,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Voice call features are enabled after 5 days. $dayRemaining days remaining. Please wait.',
                ),
              ),
            ),
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: GestureDetector(
                onTap: () {
                  makeVoiceCall(context);
                  // if (hasDurationReached(
                  //     widget.connectionModel.connectedOn, 5)) {
                  // } else {
                  //   tooltipController2.showTooltip();
                  // }
                },
                child: SvgPicture.asset(
                  Assets.icons.chatsWindowactiveFill.path,
                  height: 24,
                  width: 24,
                ),
              ),
            ),
          ),
          const Gap(15),
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
              } else if (value == "View contact") {
                Navigator.pushNamed(context, AppRoutes.myMeltedUser,
                    arguments: widget.meltUserModel.id!);
              } else if (value == "Clear chat") {
                ref
                    .read(getMessageList(widget.connectionModel.connectionId!)
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
          )
        ],
      ),
    );
  }

  Widget unmetalDialog(BuildContext context, int remaining) {
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
              "To Unmetal, we require a minimum of 5days and 5 sessions of conversations between you and @${widget.meltUserModel.username}",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(15),
        TextView(
          text:
              "You have had * $remaining Remaining days* and *0 interactions*",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(38),
        BaseButton(
            buttonText: "Un-Melt Request",
            onPressed: () {
              sendUnmelt();
              Navigator.pop(context);
            }),
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
                  .BlockUser(data.username!, data.id!);

              Navigator.pop(context);
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

  // Initialize a video call session
  void makeVideoCall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZegoUIKitPrebuiltCall(
          appID: 918677174,
          appSign:
              'a593a3eacbd96523d72730d336acaf02574848a9fda4f4fdb3110cb18b3c23f0',
          userID: ref.watch(authProvider).data!.id!,
          userName: ref.watch(authProvider).data!.username!,
          callID: widget.connectionModel.connectionId,
          config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
        ),
      ),
    );
  }

  // Initialize a voice call session
  void makeVoiceCall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZegoUIKitPrebuiltCall(
          appID: 918677174,
          appSign:
              'a593a3eacbd96523d72730d336acaf02574848a9fda4f4fdb3110cb18b3c23f0',
          userID: ref.watch(authProvider).data!.id!,
          userName: ref.watch(authProvider).data!.username!,
          callID: widget.connectionModel.connectionId,
          config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
        ),
      ),
    );
  }
}
