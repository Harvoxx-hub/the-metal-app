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
    super.key,
    required this.reactionModel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(getUserProvider(reactionModel.userId));

    return userAsync.when(
      data: (baseState) {
        // Live fetch failed — fall back to denormalized data stored in the reaction.
        // If that's also missing (old reactions pre-dating the schema update) hide the
        // row entirely so the list never shows a blank gap.
        if (baseState.isError || baseState.data == null) {
          return _buildFallbackTile(context);
        }

        final user = baseState.data!;
        final metalId = user.metal ?? reactionModel.metalId ?? reactionModel.userId;

        return _buildTile(
          context: context,
          metalId: metalId,
          displayName: user.username ?? reactionModel.username ?? 'Unknown User',
        );
      },
      loading: () => const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (_, __) => _buildFallbackTile(context),
    );
  }

  /// Renders using denormalized username/metalId from the reaction doc.
  /// Returns SizedBox.shrink() if neither is available (pre-schema reactions).
  Widget _buildFallbackTile(BuildContext context) {
    final name = reactionModel.username;
    final metal = reactionModel.metalId;
    if (name == null && metal == null) return const SizedBox.shrink();
    return _buildTile(
      context: context,
      metalId: metal ?? reactionModel.userId,
      displayName: name ?? 'Unknown User',
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required String metalId,
    required String displayName,
  }) {
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
              child: ProfilePhoto(verfly: false, size: 40, meltId: metalId),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: TextView(
                      text: displayName,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Gap(8),
                  TextView(text: reactionModel.emoji, fontSize: 16),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
