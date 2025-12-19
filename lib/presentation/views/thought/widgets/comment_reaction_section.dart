import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:metal/domain/entities/reaction_dto.dart';
import 'package:metal/presentation/viewmodels/thought/comment_viewmodel.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/res/res.dart';

class CommentReactionSection extends ConsumerStatefulWidget {
  final String thoughtId;
  final String commentId;
  final List<ReactionDto> reactions;

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
    final userdata = ref.watch(userStateProvider).user;

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

  Widget _buildReactionDisplay(List<ReactionDto> reactions, String? userId) {
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
          GestureDetector(
            onTap: () async {
              // Toggle reaction via API
              final viewModel =
                  ref.read(commentViewModelProvider(widget.thoughtId).notifier);
              await viewModel.reactToComment(widget.commentId, userReaction.emoji);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                userReaction.emoji,
                style: const TextStyle(fontSize: 20),
              ),
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReactionList(List<ReactionDto> reactions) {
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
                      final userAsync =
                          ref.watch(getUserProvider(reaction.userId));

                      return userAsync.when(
                        data: (baseState) {
                          if (baseState.isError || baseState.data == null) {
                            return Row(
                              children: [
                                const TextView(text: "User"),
                                const Gap(5),
                                TextView(
                                  text: reaction.emoji,
                                  fontSize: 16,
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              TextView(text: baseState.data!.username ?? "User"),
                              const Gap(5),
                              TextView(
                                text: reaction.emoji,
                                fontSize: 16,
                              ),
                            ],
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (error, stack) => Row(
                          children: [
                            const TextView(text: "User"),
                            const Gap(5),
                            TextView(
                              text: reaction.emoji,
                              fontSize: 16,
                            ),
                          ],
                        ),
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
    final userdata = ref.watch(userStateProvider).user;
    final userReaction = userdata?.id != null
        ? widget.reactions
            .where((reaction) => reaction.userId == userdata!.id)
            .firstOrNull
        : null;

    final emojis = ["😍", "👍", "😂", "😢", "😡"];
    return emojis.map((emoji) {
      final isCurrentReaction = userReaction?.emoji == emoji;
      return GestureDetector(
        onTap: () async {
          final viewModel =
              ref.read(commentViewModelProvider(widget.thoughtId).notifier);
          await viewModel.reactToComment(widget.commentId, emoji);
          setState(() {
            _showReactions = false;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: isCurrentReaction
              ? BoxDecoration(
                  color: AppColors.metalPinkColour.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: TextView(
            text: emoji,
            fontSize: 24,
          ),
        ),
      );
    }).toList();
  }
}
