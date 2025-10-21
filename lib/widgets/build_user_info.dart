import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';

import 'package:metal/features/thought/data/domain/entries/thought.model.dart';
import 'package:metal/features/thought/provider/delete.thoughts.dart';
import 'package:metal/features/thought/provider/get.user.notifier.dart';
import 'package:metal/features/settings/presentation/widget/block_user_helper.dart';
import 'package:metal/gen/assets.gen.dart';

import 'package:metal/route/routes.dart';

import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

class BuildUserInfo extends ConsumerStatefulWidget {
  const BuildUserInfo({
    super.key,
    this.userId,
    this.thought,
    this.date,
    this.onDeleteComment,
    this.commentId,
  });

  final String? date;
  final Function(String)? onDeleteComment;
  final String? userId;
  final ThoughtModel? thought;
  final String? commentId;

  @override
  ConsumerState<BuildUserInfo> createState() => _BuildUserInfoState();
}

class _BuildUserInfoState extends ConsumerState<BuildUserInfo> {
  @override
  Widget build(BuildContext context) {
    return buildUserInfo(context);
  }

  Widget buildUserInfo(BuildContext context) {
    final userdata = ref.watch(userStateProvider).data;
    final creatorUserdata =
        ref.watch(getUserProvider(widget.userId ?? "")).data;

    return GestureDetector(
      onTap: () {
        if (widget.userId != userdata?.id) {
          Navigator.pushNamed(
            context,
            AppRoutes.myMeltedUser,
            arguments: {"metalId": widget.userId},
          );
        }
      },
      child: creatorUserdata != null
          ? Row(
              children: [
                ProfilePhoto(
                  verfly: false,
                  size: 40,
                  meltId: creatorUserdata?.metal ?? "",
                ),
                const Gap(10),
                _buildUserDetails(creatorUserdata!),
                const Spacer(),
                _buildOptionsButton(
                    context, creatorUserdata!, widget.onDeleteComment),
              ],
            )
          : const SizedBox(),
    );
  }

  Column _buildUserDetails(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextView(fontSize: 13.5, text: "${user.username}"),
            const Gap(5),
            if (user.workEmailVerified ?? false)
              Assets.icons.checkVerified.svg(height: 16),
          ],
        ),
        TextView(
          text: widget.date != null
              ? formatTime(isoDateString: widget.date!)
              : formatTime(isoDateString: widget.thought?.createdAt ?? ""),
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildOptionsButton(BuildContext context, UserModel creatorUserdata,
      Function(String)? onDeleteComment) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet(
          backgroundColor: Colors.white,
          context: context,
          builder: (BuildContext context) => _buildOptionsBottomSheet(
              context, creatorUserdata, onDeleteComment),
        );
      },
      icon: const Icon(Icons.more_vert),
    );
  }

  Widget _buildOptionsBottomSheet(BuildContext context,
      UserModel creatorUserdata, Function(String)? onDeleteComment) {
    // Capture user ID in a local variable to avoid ref access in async context
    final currentUserId = ref.read(userStateProvider).data?.id;
    final thoughtId = widget.thought?.id;

    return SafeArea(
        child: Wrap(children: <Widget>[
      if (onDeleteComment != null && widget.userId == currentUserId)
        ListTile(
          title: const TextView(text: 'Delete Comment'),
          onTap: () {
            if (widget.commentId != null) {
              onDeleteComment(widget.commentId!);
              Navigator.pop(context);
            }
          },
        ),
      if (onDeleteComment == null) ...[
        if (widget.userId == currentUserId)
          ListTile(
            title: const TextView(text: 'Edit Thoughts'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.postThought,
                  arguments: widget.thought);
            },
          ),
        if (widget.userId == currentUserId)
          ListTile(
            title: const TextView(text: 'Delete Thoughts'),
            onTap: () {
              final deleteNotifier = ref.read(deleteThoughtProvider.notifier);
              Navigator.pop(context);
              deleteNotifier.deleteThought(thoughtId ?? "");
            },
          ),
        // Show block options for other users' thoughts
        if (widget.userId != currentUserId)
          _buildBlockOption(context, creatorUserdata!),
        if (widget.userId != currentUserId)
          _buildReportOption(context, creatorUserdata!),
      ],
    ]));
  }

  PopupMenuItem _buildBlockOption(
      BuildContext context, UserModel creatorUserdata) {
    return PopupMenuItem(
      value: 'block',
      child: Row(
        children: [
          SvgPicture.asset(
            Assets.icons.meltedMetalsSmileyXEyes.path,
            height: 21,
            width: 21,
          ),
          const Gap(15),
          const TextView(
            text: "Block",
            color: Colors.red,
          ),
        ],
      ),
      onTap: () {
        // Use enhanced block flow directly
        if (creatorUserdata?.username != null && widget.userId != null) {
          // Add a slight delay to allow menu to close
          Future.delayed(const Duration(milliseconds: 100), () {
            showBlockReasonDialog(
              context,
              userId: widget.userId ?? "",
              username: creatorUserdata!.username!,
            );
          });
        }
      },
    );
  }

  PopupMenuItem _buildReportOption(
      BuildContext context, UserModel creatorUserdata) {
    return PopupMenuItem(
      value: 'report',
      child: Row(
        children: [
          Icon(
            Icons.report_outlined,
            color: Colors.red,
            size: 21,
          ),
          const Gap(15),
          const TextView(
            text: "Report",
            color: Colors.red,
          ),
        ],
      ),
      onTap: () {
        // Use enhanced block flow with reporting
        if (creatorUserdata?.username != null && widget.userId != null) {
          // Add a slight delay to allow menu to close
          Future.delayed(const Duration(milliseconds: 100), () {
            showBlockReasonDialog(
              context,
              userId: widget.userId ?? "",
              username: creatorUserdata!.username!,
            );
          });
        }
      },
    );
  }
}
