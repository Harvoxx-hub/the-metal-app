import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/home_page/domain/entries/comment.model.dart';
import 'package:metal/features/home_page/provider/comment.provider.dart';
import 'package:metal/features/home_page/provider/get.user.notifier.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/res/res.dart';

class CommentReactionSection extends ConsumerStatefulWidget {
  final String thoughtId;
  final String commentId;
  final List<ReactionModel> reactions;

  const CommentReactionSection({
    Key? key,
    required this.thoughtId,
    required this.commentId,
    required this.reactions,
  }) : super(key: key);

  @override
  ConsumerState<CommentReactionSection> createState() =>
      _CommentReactionSectionState();
}

class _CommentReactionSectionState
    extends ConsumerState<CommentReactionSection> {
  bool _showReactions = false;

  void _toggleReactions() {
    setState(() {
      _showReactions = !_showReactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: _showReactions ? 100 : 60,
          width: 250,
          child: Row(
            children: [
              IconButton(
                onPressed: _toggleReactions,
                icon: _buildReactionIcon(),
              ),
              _buildReactionsRow(),
            ],
          ),
        ),
        if (_showReactions) _buildReactionsSelector(),
      ],
    );
  }

  Widget _buildReactionIcon() {
    final userdata = ref.watch(authProvider).data;
    if (userdata == null) return const Icon(Icons.favorite_border);

    final userReaction = widget.reactions
        .where((reaction) => reaction.userId == userdata.id)
        .firstOrNull;

    if (userReaction == null) {
      return const Icon(Icons.favorite_border);
    }

    return Text(
      userReaction.emoji,
      style: const TextStyle(fontSize: 24),
    );
  }

  Widget _buildReactionsRow() {
    final userdata = ref.watch(authProvider).data;
    if (userdata == null || widget.reactions.isEmpty) return const SizedBox();

    int totalReactions = widget.reactions.length;
    bool userHasReacted =
        widget.reactions.any((reaction) => reaction.userId == userdata.id);

    String reactionText = userHasReacted
        ? (totalReactions > 1
            ? 'You and ${totalReactions - 1} others reacted'
            : 'You reacted')
        : '$totalReactions reacted';

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          backgroundColor: Colors.white,
          context: context,
          builder: (BuildContext context) => _buildReactionList(),
        );
      },
      child: Row(
        children: [
          for (var reaction in widget.reactions) TextView(text: reaction.emoji),
          TextView(text: reactionText),
        ],
      ),
    );
  }

  Widget _buildReactionList() {
    return SafeArea(
      child: Wrap(
        children: [
          for (var reaction in widget.reactions)
            ListTile(
              leading: ProfilePhoto(
                verfly: false,
                size: 40,
                meltId: reaction.userId,
              ),
              title: Consumer(
                builder: (context, ref, child) {
                  final userState = ref.watch(getUserProvider(reaction.userId));
                  if (userState.isLoading || userState.data == null) {
                    return const SizedBox.shrink();
                  }
                  return Row(
                    children: [
                      TextView(text: userState.data!.username ?? ""),
                      const Gap(5),
                      TextView(
                        text: reaction.emoji,
                        fontSize: 16,
                      ),
                    ],
                  );
                },
              ),
            ),
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
    final reactions = ["😍", "👍", "😂", "😢", "😡"];
    return reactions.map((emoji) {
      return GestureDetector(
        onTap: () async {
          final commentNotifier =
              ref.read(commentProvider(widget.thoughtId).notifier);
          await commentNotifier.reactToComment(widget.commentId, emoji);
          setState(() {
            _showReactions = false;
          });
        },
        child: TextView(
          text: emoji,
          fontSize: 24,
        ),
      );
    }).toList();
  }
}
