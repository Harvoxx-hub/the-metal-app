import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:metal/features/home_page/domain/entries/reaction.model.dart';
import 'package:metal/features/home_page/provider/reaction.provider.dart';
import 'package:metal/features/home_page/widget/reaction.listtile.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/res/res.dart';

class ReactionSection extends ConsumerStatefulWidget {
  final String thoughtId;
  final GlobalKey? reactionKey;
  const ReactionSection({
    Key? key,
    required this.thoughtId,
    this.reactionKey,
  }) : super(key: key);

  @override
  ConsumerState<ReactionSection> createState() => _ReactionSectionState();
}

class _ReactionSectionState extends ConsumerState<ReactionSection> {
  bool _showReactions = false;

  void _toggleReactions() {
    setState(() {
      _showReactions = !_showReactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reactions = ref.watch(reactionProvider(widget.thoughtId)).data ?? [];
    final userdata = ref.watch(userStateProvider).data;

    return Stack(
      children: [
        SizedBox(
          height: _showReactions ? 100 : 60,
          child: Row(
            children: [
              GestureDetector(
                onTap: _toggleReactions,
                child: _buildReactionDisplay(reactions, userdata?.id),
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
        key: widget.reactionKey,
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
      key: widget.reactionKey,
      children: [
        if (userReaction != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              userReaction.emoji,
              style: const TextStyle(fontSize: 24),
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
      List<ReactionModel> reactions, ScrollController scrollController) {
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
          final reactionNotifier =
              ref.read(reactionProvider(widget.thoughtId).notifier);
          await reactionNotifier.addReaction(emoji);
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
