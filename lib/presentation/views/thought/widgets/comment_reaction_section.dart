import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:metal/domain/entities/reaction_dto.dart';
import 'package:metal/presentation/viewmodels/thought/comment_viewmodel.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/res/res.dart';
import 'package:metal/route/routes.dart';

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
  void _showEmojiPickerSheet() {
    final userdata = ref.read(userStateProvider).user;
    final userReaction = userdata?.id != null
        ? widget.reactions.where((r) => r.userId == userdata!.id).firstOrNull
        : null;
    final emojis = ['😍', '👍', '😂', '😢', '😡'];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: emojis.map((emoji) {
                final isCurrentReaction = userReaction?.emoji == emoji;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final viewModel = ref.read(
                        commentViewModelProvider(widget.thoughtId).notifier);
                    await viewModel.reactToComment(widget.commentId, emoji);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: isCurrentReaction
                        ? BoxDecoration(
                            color: AppColors.metalPinkColour.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          )
                        : null,
                    child: TextView(
                      text: emoji,
                      fontSize: 32,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userdata = ref.watch(userStateProvider).user;

    return SizedBox(
      height: 60,
      width: 250,
      child: Row(
        children: [
          GestureDetector(
            onTap: _showEmojiPickerSheet,
            child: _buildReactionDisplay(
              widget.reactions,
              userdata?.id,
              onTapOpenPicker: _showEmojiPickerSheet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionDisplay(
    List<ReactionDto> reactions,
    String? userId, {
    required VoidCallback onTapOpenPicker,
  }) {
    if (reactions.isEmpty) {
      return Row(
        children: [
          IconButton(
            onPressed: onTapOpenPicker,
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
              await viewModel.reactToComment(
                  widget.commentId, userReaction.emoji);
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
            onPressed: onTapOpenPicker,
            icon: const Icon(Icons.favorite_border),
          ),
        GestureDetector(
          onTap: () {
            if (reactions.isNotEmpty) {
              showModalBottomSheet<void>(
                backgroundColor: Colors.white,
                context: context,
                isScrollControlled: true,
                builder: (BuildContext sheetContext) {
                  final maxHeight =
                      MediaQuery.sizeOf(sheetContext).height * 0.55;
                  return SizedBox(
                    height: maxHeight,
                    child: _buildReactionList(reactions),
                  );
                },
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

  /// ListTile [title] must leave horizontal room for [leading]; keep name on one line.
  Widget _reactionListTileTitle(String name, String emoji) {
    return Row(
      children: [
        Expanded(
          child: TextView(
            text: name,
            fontSize: 16,
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
          ),
        ),
        const Gap(5),
        TextView(
          text: emoji,
          fontSize: 16,
        ),
      ],
    );
  }

  Widget _buildReactionList(List<ReactionDto> reactions) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.userProfile,
                      arguments: reaction.userId,
                    );
                  },
                  leading: SizedBox(
                    width: 56,
                    height: 56,
                    child: Center(
                      child: ProfilePhoto(
                        verfly: false,
                        size: 40,
                        meltId: reaction.userId,
                      ),
                    ),
                  ),
                  title: Consumer(
                    builder: (context, ref, child) {
                      final userAsync =
                          ref.watch(getUserProvider(reaction.userId));

                      return userAsync.when(
                        data: (baseState) {
                          if (baseState.isError || baseState.data == null) {
                            return _reactionListTileTitle(
                              'User',
                              reaction.emoji,
                            );
                          }

                          return _reactionListTileTitle(
                            baseState.data!.username ?? 'User',
                            reaction.emoji,
                          );
                        },
                        loading: () =>
                            _reactionListTileTitle('…', reaction.emoji),
                        error: (error, stack) =>
                            _reactionListTileTitle('User', reaction.emoji),
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
}
