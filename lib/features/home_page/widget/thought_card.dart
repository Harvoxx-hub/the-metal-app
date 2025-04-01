import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/home_page/domain/entries/thought.model.dart';

import 'package:metal/features/home_page/provider/delete.thoughts.dart';

import 'package:metal/features/home_page/provider/get.user.notifier.dart';
import 'package:metal/features/home_page/provider/react.thoughts.notifier.dart';
import 'package:metal/features/home_page/widget/reaction.listtile.dart';

import 'package:metal/features/settings/provider/block.user.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/res.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

class ThoughtCard extends ConsumerStatefulWidget {
  final ThoughtModel thoughtModel;

  const ThoughtCard({
    super.key,
    required this.thoughtModel,
  });

  @override
  ConsumerState<ThoughtCard> createState() => _ThoughtCardState();
}

class _ThoughtCardState extends ConsumerState<ThoughtCard> {
  bool _showReactions = false;

  late ThoughtModel thoughtModel;
  UserModel? creatorUserdata;
  @override
  void initState() {
    super.initState();
    thoughtModel = widget.thoughtModel;
  }

  @override
  Widget build(BuildContext context) {
    creatorUserdata = ref.watch(getUserProvider(thoughtModel.userId)).data;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _buildThoughtCard(context),
    );
  }

  Widget _buildThoughtCard(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfo(context),
              const Gap(10),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.thoughtDetails,
                    arguments: thoughtModel.id,
                  );
                },
                child: TextView(
                  text: thoughtModel.content,
                  maxLines: 4,
                  textOverflow: TextOverflow.ellipsis,
                ),
              ),
              const Gap(10),
              _buildReactionsRow(),
              IconButton(
                onPressed: _toggleReactions,
                icon: const Icon(Icons.favorite_border),
              ),
            ],
          ),
          if (_showReactions) _buildReactionsSelector(),
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    final userdata = ref.watch(authProvider).data;

    return GestureDetector(
      onTap: () {
        if (thoughtModel.userId != userdata?.id) {
          Navigator.pushNamed(
            context,
            AppRoutes.myMeltedUser,
            arguments: {"metalId": thoughtModel.userId},
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
                _buildOptionsButton(context),
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
            if (user.isVerified ?? false)
              Assets.icons.checkVerified.svg(height: 16),
          ],
        ),
        TextView(
          text: formatTime(isoDateString: thoughtModel.createdAt),
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildOptionsButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet(
          backgroundColor: Colors.white,
          context: context,
          builder: (BuildContext context) => _buildOptionsBottomSheet(context),
        );
      },
      icon: const Icon(Icons.more_vert),
    );
  }

  Widget _buildOptionsBottomSheet(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: <Widget>[
          if (widget.thoughtModel.userId == ref.watch(authProvider).data!.id)
            ListTile(
              title: const TextView(text: 'Edit Thoughts'),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.postThought,
                    arguments: widget.thoughtModel);
              },
            ),
          if (widget.thoughtModel.userId == ref.watch(authProvider).data!.id)
            ListTile(
              title: const TextView(text: 'Delete Thoughts'),
              onTap: () {
                ref
                    .read(deleteThoughtProvider.notifier)
                    .deleteThought(widget.thoughtModel.id);
                Navigator.pop(context);
              },
            ),
          if (widget.thoughtModel.userId != ref.watch(authProvider).data!.id)
            ListTile(
              title: const TextView(text: 'Block Metal'),
              onTap: () {
                _showDialog(
                  context,
                  _blockDialog(context, thoughtModel, ref),
                );
              },
            ),
          if (widget.thoughtModel.userId != ref.watch(authProvider).data!.id)
            ListTile(
              title: const TextView(text: 'Block and Report'),
              onTap: () {
                _showDialog(
                  context,
                  _blockAndReportDialog(context, thoughtModel, ref),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _reactionList(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: <Widget>[
          for (var element in widget.thoughtModel.reactions)
            ReactionListTile(
              reactionModel: element,
            )
        ],
      ),
    );
  }

  Widget _buildReactionsRow() {
    final userdata = ref.watch(authProvider).data;
    String userid = userdata!
        .id!; // Replace this with the actual ID check logic if necessary

// Check if the thought has any reactions
    if (thoughtModel.reactions.isEmpty) {
      return Container(); // or any other fallback widget when there are no reactions
    }

// Initialize variables to track reactions
    int totalReactions = thoughtModel.reactions.length;

// Check if the user has reacted
    bool userHasReacted =
        thoughtModel.reactions.any((reaction) => reaction.userId == userid);

// Build the display text based on the user's reaction status
    String reactionText;
    if (userHasReacted) {
      if (totalReactions > 1) {
        reactionText = 'You and ${totalReactions - 1} others reacted';
      } else {
        reactionText = 'You reacted';
      }
    } else {
      reactionText = '$totalReactions reacted';
    }

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          backgroundColor: Colors.white,
          context: context,
          builder: (BuildContext context) => _reactionList(context),
        );
      },
      child: Row(
        children: [
          for (var reaction in thoughtModel.reactions)
            TextView(
              text: reaction.emoji,
            ),
          TextView(text: reactionText),
        ],
      ),
    );
  }

  Widget _buildReactionsSelector() {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.metalTabBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _buildReactionIcons(),
        ),
      ),
    );
  }

  List<Widget> _buildReactionIcons() {
    return [
      ReactionIcon(
        icon: '👍',
        reaction: 'like',
        onTap: () => _selectReaction('👍'),
      ),
      ReactionIcon(
        icon: '❤️',
        reaction: 'love',
        onTap: () => _selectReaction('❤️'),
      ),
      ReactionIcon(
        icon: '😮',
        reaction: 'wow',
        onTap: () => _selectReaction('😮'),
      ),
      ReactionIcon(
        icon: '😂',
        reaction: 'haha',
        onTap: () => _selectReaction('😂'),
      ),
      ReactionIcon(
        icon: '😢',
        reaction: 'sad',
        onTap: () => _selectReaction('😢'),
      ),
      ReactionIcon(
        icon: '😡',
        reaction: 'angry',
        onTap: () => _selectReaction('😡'),
      ),
    ];
  }

  void _showDialog(BuildContext context, Widget dialogContent) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(content: dialogContent),
    );
  }

  Widget _blockDialog(BuildContext context, ThoughtModel data, WidgetRef ref) {
    return _buildDialog(
      context: context,
      data: data,
      ref: ref,
      isReport: false,
    );
  }

  Widget _blockAndReportDialog(
      BuildContext context, ThoughtModel data, WidgetRef ref) {
    return _buildDialog(
      context: context,
      data: data,
      ref: ref,
      isReport: true,
    );
  }

  Widget _buildDialog({
    required BuildContext context,
    required ThoughtModel data,
    required WidgetRef ref,
    bool isReport = false,
  }) {
    TextEditingController _controller = TextEditingController();
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
          text: isReport ? 'Block and Report this User' : 'Block this User',
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        const Gap(8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: TextView(
            text:
                'This user will not be able to see or interact with your posts and messages. They will not be notified.',
            maxLines: 3,
            textAlign: TextAlign.center,
          ),
        ),
        const Gap(8),
        if (isReport)
          EditFormField(
            controller: _controller,
            hint: 'Reason for reporting',
            maxLines: 5,
            keyboardType: TextInputType.name,
            minLines: 5,
            validator: Validators.validateString(),
          ),
        const Gap(15),
        const Gap(38),
        BaseButton(
            buttonText: "Block ${creatorUserdata!.username}",
            onPressed: () {
              ref
                  .read(blockUserProvider.notifier)
                  .BlockUser(creatorUserdata!.username!, creatorUserdata!.id!);

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
        const Gap(24),
      ],
    );
  }

  void _toggleReactions() {
    _showReactions = !_showReactions;

    setState(() {});
  }

  void _selectReaction(String reaction) {
    setState(() {
      _showReactions = false;

      // Update locally
      final currentReactions =
          List<ReactionModel>.from(widget.thoughtModel.reactions);
      currentReactions.add(ReactionModel(userId: "", emoji: reaction));

      // Create a new instance of thoughtModel with the updated reactions
      thoughtModel = widget.thoughtModel.copyWith(reactions: currentReactions);
    });

    // Send the reaction to the backend
    ref
        .read(reactThoughtProvider.notifier)
        .reactThought(widget.thoughtModel.id, reaction);
  }
}

class ReactionIcon extends StatelessWidget {
  final String icon;
  final String reaction;
  final VoidCallback onTap;

  const ReactionIcon({
    Key? key,
    required this.icon,
    required this.reaction,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          Text(
            reaction,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
