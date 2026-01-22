import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:metal/domain/entities/reaction_dto.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/route/routes.dart';

class ReactionListTile extends ConsumerWidget {
  final ReactionDto reactionModel;

  const ReactionListTile({
    Key? key,
    required this.reactionModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(getUserProvider(reactionModel.userId));

    return userAsync.when(
      data: (baseState) {
        if (baseState.isError || baseState.data == null) {
          return const SizedBox(height: 60);
        }

        final user = baseState.data!;
        final metalId = user.metal ?? reactionModel.userId;

        return InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.userProfile,
              arguments: reactionModel.userId,
            );
          },
          child: Padding(
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
          ),
        );
      },
      loading: () => const SizedBox(
        height: 60,
        child: Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      ),
      error: (error, stack) => const SizedBox(height: 60),
    );
  }
}
