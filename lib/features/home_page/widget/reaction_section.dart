import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/home_page/domain/entries/reaction.model.dart';
import 'package:metal/features/home_page/provider/reaction.provider.dart';
import 'package:metal/features/home_page/widget/reaction.listtile.dart';
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

    return Stack(
      children: [
        SizedBox(
          height: _showReactions ? 100 : 60,
          width: 230,
          child: Row(
            children: [
              IconButton(
                onPressed: _toggleReactions,
                icon: _buildReactionIcon(),
              ),
              _buildReactionsRow(reactions),
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

    final reactions = ref.watch(reactionProvider(widget.thoughtId)).data ?? [];
    final userReaction = reactions
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

  Widget _buildReactionsRow(List<ReactionModel> reactions) {
    final userdata = ref.watch(authProvider).data;
    if (userdata == null || reactions.isEmpty) return const SizedBox();

    int totalReactions = reactions.length;
    bool userHasReacted =
        reactions.any((reaction) => reaction.userId == userdata.id);

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
          builder: (BuildContext context) => _buildReactionList(reactions),
        );
      },
      child: Row(
        children: [
          for (var reaction in reactions) TextView(text: reaction.emoji),
          TextView(text: reactionText),
        ],
      ),
    );
  }

  Widget _buildReactionList(List<ReactionModel> reactions) {
    return SafeArea(
      child: Wrap(
        children: [
          for (var reaction in reactions)
            ReactionListTile(reactionModel: reaction),
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
