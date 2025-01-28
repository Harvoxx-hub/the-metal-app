import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:metal/core/services/firebase.remote.config.service.dart';

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
    final bool is15DaysReached = hasDurationReached(
        widget.connectionModel.connectedOn, daysRequiredToUnMelt);
    int dayRemaining =
        daysRemaining(widget.connectionModel.connectedOn, daysRequiredToUnMelt);

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
                text: widget.meltUserModel.isOnline
                    ? "active"
                    : widget.meltUserModel.lastActive == null
                        ? "Offline"
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
            content: const SizedBox(
              width: 180,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Video call is enabled after 15 days of connection.',
                ),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: ZegoSendCallInvitationButton(
                isVideoCall: true,
                invitees: [
                  ZegoUIKitUser(
                    id: widget.meltUserModel.id!,
                    name: widget.meltUserModel.username!,
                  ),
                ],
                resourceID: 'zego_call', // Configured in ZegoCloud
                iconSize: const Size(30, 30),
                buttonSize: const Size(40, 40),
                icon: ButtonIcon(
                  icon: SvgPicture.asset(
                    Assets.icons.chatsWindowactiveVideoRecorder.path,
                    height: 30,
                    width: 30,
                    color: is15DaysReached ? Colors.black : Colors.grey,
                  ),
                ),
                onWillPressed: () {
                  if (!is15DaysReached) {
                    tooltipController.showTooltip();
                    return Future.value(false);
                  }
                  if (widget.connectionModel.isAnonymous) {
                    tooltipController.showTooltip();
                    return Future.value(false);
                  }
                  return Future.value(true);
                },
              ),
            ),
          ),
          const Gap(15),
          JustTheTooltip(
            controller: tooltipController2,
            content: const SizedBox(
              width: 180,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Voice call is available after un-melting.',
                ),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: ZegoSendCallInvitationButton(
                isVideoCall: false,
                invitees: [
                  ZegoUIKitUser(
                    id: widget.meltUserModel.id!,
                    name: widget.meltUserModel.username!,
                  ),
                ],
                resourceID: 'zego_call',
                iconSize: const Size(30, 30),
                buttonSize: const Size(40, 40),
                icon: ButtonIcon(
                  icon: SvgPicture.asset(
                    Assets.icons.chatsWindowactiveFill.path,
                    height: 30,
                    width: 30,
                    color: is15DaysReached ? Colors.black : Colors.grey,
                  ),
                ),
                onWillPressed: () {
                  if (!is15DaysReached) {
                    tooltipController2.showTooltip();
                    return Future.value(false);
                  }
                  if (widget.connectionModel.isAnonymous) {
                    tooltipController2.showTooltip();
                    return Future.value(false);
                  }
                  return Future.value(true);
                },
              ),
            ),
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
              } else if (value == "rejected") {
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
                    arguments: widget.meltUserModel.id!);
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
              "To Unmetal, we require a minimum of $daysRequiredToUnMelt days of Melt conversations between you and @${widget.meltUserModel.username}",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(15),
        TextView(
          text: "You have had * $remaining days* remaining",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(38),
        if (hasDurationReached(
            widget.connectionModel.connectedOn, daysRequiredToUnMelt))
          BaseButton(
            buttonText: "Un-Melt Request",
            onPressed: () {
              sendUnmelt();
              Navigator.pop(context);
            },
          )
        else
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
              "@${widget.meltUserModel.username} has opted to always be a metal.\nThis request cannot be sent.",
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

  // Handle video call initialization
  // void makeVideoCall(BuildContext context) {
  // Navigator.push(
  //   context,
  //   MaterialPageRoute(
  //       builder: (context) => ZegoSendCallInvitationButton(
  //             isVideoCall: true,
  //             //You need to use the resourceID that you created in the subsequent steps.
  //             //Please continue reading this document.
  //             resourceID: "metal_call",
  //             invitees: [
  //               ZegoUIKitUser(
  //                 id: widget.meltUserModel.id!,
  //                 name: widget.meltUserModel.username!,
  //               ),
  //             ],
  //           )),
  // );
  // }

  // Handle voice call initialization
  // void makeVoiceCall(BuildContext context) {
  // Navigator.push(
  //   context,
  //   MaterialPageRoute(
  //       builder: (context) => ZegoSendCallInvitationButton(
  //             isVideoCall: false,
  //             resourceID: "metal_call",
  //             invitees: [
  //               ZegoUIKitUser(
  //                 id: widget.meltUserModel.id!,
  //                 name: widget.meltUserModel.username!,
  //               ),
  //             ],
  //           )),
  // );
  // }

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
