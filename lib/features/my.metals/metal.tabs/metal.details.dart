import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/services/firebase.remote.config.service.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/authentication/provider/unmelt_days_notifier.dart';
import 'package:metal/features/chat/domain/entries/message.model.dart';
import 'package:metal/features/chat/provider/send.message.notifier.dart';
import 'package:metal/features/home_page/domain/entries/connection.model.dart';
import 'package:metal/features/home_page/provider/get.connection.notifier.dart';
import 'package:metal/features/my.metals/provider/unmelt.user.notifier.dart';
import 'package:metal/features/profile/presentation/widget/edit.field.dart';
import 'package:metal/features/settings/provider/block.user.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/features/settings/presentation/widget/block_user_helper.dart';

class MetalDetailsTab extends ConsumerStatefulWidget {
  const MetalDetailsTab({
    super.key,
    required this.melted,
    required this.userModel,
    required this.connectionModel,
    required this.connectedOn,
  });
  final UserModel userModel;
  final bool melted;
  final String connectionModel;
  final String connectedOn;
  @override
  ConsumerState<MetalDetailsTab> createState() => _MetalDetailsTabState();
}

class _MetalDetailsTabState extends ConsumerState<MetalDetailsTab> {
  late int dayRemaining;

  @override
  void initState() {
    super.initState();
    dayRemaining = daysRemaining(widget.connectedOn,
        FirebaseRemoteConfigService().getDaysRequiredToUnMelt());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              EditField(
                text: "Go to ${widget.userModel.username} metal profile",
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.userProfilePage,
                      arguments: widget.userModel);
                },
                floatingLabel: " View profile",
                suffixIcon: SvgPicture.asset(
                  Assets.icons.meltedMetalsArrowUpRight.path,
                  height: 21,
                  width: 21,
                ),
              ),
              if (widget.melted)
                Column(
                  children: [
                    const Gap(20),
                    EditField(
                      text:
                          "De-melt ${widget.userModel.username}  from your metal list",
                      floatingLabel: "Remove from my list of metals",
                      suffixIcon: SvgPicture.asset(
                        Assets.icons.meltedMetalsTrash01.path,
                        height: 21,
                        width: 21,
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialog(
                                content: _ceMeltDialog(
                                    context, widget.userModel, ref));
                          },
                        );
                      },
                    ),
                    const Gap(20),
                    EditField(
                      text:
                          "Un-melt ${widget.userModel.username}  from your metal list",
                      floatingLabel: "Un-metals",
                      suffixIcon: SvgPicture.asset(
                        Assets.icons.meltedMetalsTrash01.path,
                        height: 21,
                        width: 21,
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialog(
                              content: unmetalDialog(context, dayRemaining),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              const Gap(20),
              EditField(
                text: "Block ${widget.userModel.username}  from reaching you",
                floatingLabel: "Block from viewing my profile",
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomDialog(
                          content:
                              _blockDialog(context, widget.userModel, ref));
                    },
                  );
                },
                suffixIcon: SvgPicture.asset(
                  Assets.icons.meltedMetalsSmileyXEyes.path,
                  height: 21,
                  width: 21,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget unmetalDialog(BuildContext context, int remaining) {
    final connectionModel =
        ref.watch(getConnectionProvider(widget.connectionModel));
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
    final otherUserHasPhoto = widget.userModel.profilePhoto != null &&
        widget.userModel.profilePhoto!.isNotEmpty &&
        widget.userModel.profilePhoto!.trim().isNotEmpty;

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
              Navigator.pushNamed(context, AppRoutes.createProfilePage);
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
                "Do you still want to send an unmetal request to @${widget.userModel.username}?",
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
              "To Unmetal, we require a minimum of $daysRequired days and 10 sessions of conversations between you and @${widget.userModel.username}",
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
              "We have sent your request to @${widget.userModel.username}. We will notify you when we get a response",
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
        .sendMessage(message, widget.connectionModel);

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

  Widget _blockDialog(BuildContext context, UserModel data, WidgetRef ref) {
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
              // Close the current dialog
              Navigator.pop(context);

              // Show the enhanced block reason dialog
              showBlockReasonDialog(
                context,
                userId: data.id!,
                username: data.username!,
              );
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

  Widget _ceMeltDialog(BuildContext context, UserModel data, WidgetRef ref) {
    // ref.watch(unmeltUserProvider(data.id!));
    return Column(
      children: [
        const Gap(38),
        SvgPicture.asset(
          Assets.icons.meltedMetalsTrash01.path,
          height: 45,
          width: 45,
        ),
        const Gap(15),
        TextView(
          text: "De-melt  ${data.username}",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        const Gap(15),
        const TextView(
          text: "De-melted metals will have to request to melt with you again",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(38),
        BaseButton(
            buttonText: "De-melt  ${data.username}",
            onPressed: () {
              ref
                  .read(demeltUserProvider.notifier)
                  .deMeltUser(widget.connectionModel, widget.userModel.id!);
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
}
