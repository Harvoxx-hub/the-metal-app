import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/home_page/domain/entries/thought.model.dart';
import 'package:metal/features/home_page/provider/get.user.notifier.dart';
 
import 'package:metal/features/settings/provider/get.blocked.user.notifier.dart';
import 'package:metal/route/routes.dart';
 
import 'package:metal/widgets/text_views.dart';

class ReactionListTile extends ConsumerWidget {
  const ReactionListTile({super.key, required this.reactionModel});
  final ReactionModel reactionModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creatorUserdata = ref.watch(getUserProvider(reactionModel.userId));
    final blockedUsers = ref.watch(getBlockUserProvider).data ?? [];

    // Check if the user is blocked
    final isBlocked = blockedUsers
        .any((blockedUser) => blockedUser['id'] == reactionModel.userId);

    // Don't show the reaction if the user is blocked
    if (isBlocked) {
      return const SizedBox.shrink();
    }

    return creatorUserdata.isLoading
        ? CircularProgressIndicator.adaptive()
        : creatorUserdata.data! == null
            ? const SizedBox.shrink()
            : ListTile(
                title: TextView(text: creatorUserdata.data!.username!),
                onTap: () {
              if (reactionModel.userId != ref.watch(authProvider).data!.id) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.myMeltedUser,
                  arguments: {"metalId": reactionModel.userId},
                );
              }
            },
            // leading: ProfilePhoto(
            //   size: 24,
            //   meltId: creatorUserdata.data!.metal!,
            // ),
            trailing: TextView(text: reactionModel.emoji),
          );
  }
}
