import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/home_page/domain/entries/reaction.model.dart';
import 'package:metal/features/home_page/provider/get.user.notifier.dart';
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
      return const SizedBox.shrink();
    }

    final user = userState.data!;

    return ListTile(
      leading: ProfilePhoto(
        verfly: false,
        size: 40,
        meltId: user.metal ?? "",
      ),
      title: Row(
        children: [
          TextView(text: user.username ?? ""),
          const Gap(5),
          TextView(
            text: reactionModel.emoji,
            fontSize: 16,
          ),
        ],
      ),
    );
  }
}
