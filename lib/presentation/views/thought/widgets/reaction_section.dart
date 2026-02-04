import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:metal/domain/entities/reaction_dto.dart';
import 'package:metal/presentation/viewmodels/thought/reaction_viewmodel.dart';
import 'package:metal/presentation/views/thought/widgets/reaction_list_tile.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

class ReactionSection extends ConsumerStatefulWidget {
  final String thoughtId;
  final GlobalKey? reactionKey;
  final VoidCallback? onToggleReactions;
  const ReactionSection({
    Key? key,
    required this.thoughtId,
    this.reactionKey,
    this.onToggleReactions,
  }) : super(key: key);

  @override
  ConsumerState<ReactionSection> createState() => _ReactionSectionState();
}

class _ReactionSectionState extends ConsumerState<ReactionSection> {
  @override
  Widget build(BuildContext context) {
    final reactionState =
        ref.watch(reactionViewModelProvider(widget.thoughtId));
    final reactions = reactionState.reactions;
    final userdata = ref.watch(userStateProvider).user;

    final onTapPicker = widget.onToggleReactions ??
        () => _showReactionPicker(context, reactions);

    return Row(
      children: [
        GestureDetector(
          onTap: onTapPicker,
          child: _buildReactionDisplay(
            reactions,
            userdata?.id,
            onTapAddReaction: onTapPicker,
          ),
        ),
      ],
    );
  }

  void _showReactionPicker(BuildContext context, List<ReactionDto> reactions) {
    final userdata = ref.read(userStateProvider).user;
    final userReaction = userdata?.id != null
        ? reactions.where((r) => r.userId == userdata!.id).firstOrNull
        : null;
    final emojis = ['😍', '👍', '😂', '😢', '😡'];
    final currentUserId = userdata?.id;

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
                        reactionViewModelProvider(widget.thoughtId).notifier);
                    await viewModel.addReaction(emoji,
                        currentUserId: currentUserId);
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

  Widget _buildReactionDisplay(
    List<ReactionDto> reactions,
    String? userId, {
    required VoidCallback onTapAddReaction,
  }) {
    if (reactions.isEmpty) {
      return Row(
        key: widget.reactionKey,
        children: [
          IconButton(
            onPressed: onTapAddReaction,
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
      key: widget.reactionKey,
      children: [
        if (userReaction != null)
          GestureDetector(
            onTap: () async {
              // Toggle reaction (API handles remove if same emoji)
              final viewModel = ref
                  .read(reactionViewModelProvider(widget.thoughtId).notifier);
              await viewModel.addReaction(
                userReaction.emoji,
                currentUserId: userId,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                userReaction.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          )
        else
          IconButton(
            onPressed: onTapAddReaction,
            icon: const Icon(Icons.favorite_border),
          ),
        GestureDetector(
          onTap: () {
            if (reactions.isNotEmpty) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (BuildContext context) => DraggableScrollableSheet(
                  initialChildSize: 0.4,
                  minChildSize: 0.2,
                  maxChildSize: 0.75,
                  expand: false,
                  builder: (context, scrollController) =>
                      _buildReactionList(reactions, scrollController),
                ),
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

  Widget _buildReactionList(
      List<ReactionDto> reactions, ScrollController scrollController) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
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
                TextView(
                  text: 'Reactions',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: reactions.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) => ReactionListTile(
                reactionModel: reactions[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
