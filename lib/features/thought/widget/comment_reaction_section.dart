import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
 
import 'package:metal/features/thought/data/domain/entries/comment.model.dart';
import 'package:metal/features/thought/provider/comment.provider.dart';
import 'package:metal/features/thought/provider/get.user.notifier.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
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
    final userdata = ref.watch(userStateProvider).data;

    return Stack(
      children: [
        SizedBox(
          height: _showReactions ? 100 : 60,
          width: 250, // Match the width with ReactionSection
          child: Row(
            children: [
              GestureDetector(
                onTap: _toggleReactions,
                child: _buildReactionDisplay(widget.reactions, userdata?.id),
              ),
            ],
          ),
        ),
        if (_showReactions) _buildReactionsSelector(),
      ],
    );
  }

  Widget _buildReactionDisplay(List<ReactionModel> reactions, String? userId) {
    if (reactions.isEmpty) {
      return Row(
        children: [
          IconButton(
            onPressed: _toggleReactions,
            icon: const Icon(Icons.favorite_border),
          ),
          const TextView(
            text: "0",
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ],
      );
    }

    // Find user's reaction if exists
    final userReaction = userId != null
        ? reactions.where((reaction) => reaction.userId == userId).firstOrNull
        : null;

    return Row(
      children: [
        if (userReaction != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              userReaction.emoji,
              style: const TextStyle(fontSize: 20),
            ),
          )
        else
          IconButton(
            onPressed: _toggleReactions,
            icon: const Icon(Icons.favorite_border),
          ),
        GestureDetector(
          onTap: () {
            if (reactions.isNotEmpty) {
              showModalBottomSheet(
                backgroundColor: Colors.white,
                context: context,
                builder: (BuildContext context) =>
                    _buildReactionList(reactions),
              );
            }
          },
          child: Row(
            children: [
              TextView(
                text: reactions.length.toString(),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              const Gap(4),
              // TextView(
              //   text: "reactions",
              //   fontSize: 12,
              //   fontWeight: FontWeight.w400,
              //   color: AppColors.metalBlack50,
              // ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReactionList(List<ReactionModel> reactions) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextView(
                  text: '${reactions.length}',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                const Gap(4),
                // TextView(
                //   text: 'Reactions',
                //   fontSize: 16,
                //   fontWeight: FontWeight.w600,
                // ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: reactions.length,
              itemBuilder: (context, index) {
                final reaction = reactions[index];
                return ListTile(
                  leading: ProfilePhoto(
                    verfly: false,
                    size: 40,
                    meltId: reaction.userId,
                  ),
                  title: Consumer(
                    builder: (context, ref, child) {
                      final userState =
                          ref.watch(getUserProvider(reaction.userId));
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
