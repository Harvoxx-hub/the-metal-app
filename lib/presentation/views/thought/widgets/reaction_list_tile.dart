import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:metal/features/thought/data/domain/entries/reaction.model.dart';
import 'package:metal/features/thought/provider/get.user.notifier.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

class ReactionListTile extends ConsumerWidget {
  final ReactionModel reactionModel;

  const ReactionListTile({
    Key? key,
    required this.reactionModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(getUserProvider(reactionModel.userId));

    if (userState.isLoading || userState.data == null) {
      return const SizedBox(
        height: 60,
        child: Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }

    final user = userState.data!;
    final metalId = user.metal ?? "";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 16),
          SizedBox(
            width: 40,
            height: 40,
            child: ProfilePhoto(
              verfly: false,
              size: 40,
              meltId: metalId,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: TextView(
                    text: user.username ?? "Unknown User",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    maxLines: 1,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                ),
                const Gap(8),
                TextView(
                  text: reactionModel.emoji,
                  fontSize: 16,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
