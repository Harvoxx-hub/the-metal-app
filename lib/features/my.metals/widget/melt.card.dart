import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/home_page/domain/entries/connection.model.dart';
import 'package:metal/features/home_page/provider/get.user.notifier.dart';
import 'package:metal/features/settings/presentation/widget/block_user_helper.dart';
import 'package:metal/features/settings/provider/get.blocked.user.notifier.dart';
import 'package:metal/features/settings/provider/block.user.notifier.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/button/base_button.dart';

import 'package:metal/route/routes.dart';
import 'package:metal/widgets/card.with.shadow.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

class MeltCard extends ConsumerWidget {
  const MeltCard({super.key, required this.user});
  final ConnectionModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).data;
    final blockedUsers = ref.watch(getBlockUserProvider).data ?? [];

    final metalId = user.users.firstWhere(
      (user) => user != currentUser!.id,
      orElse: () =>
          "", // Handle cases where all user IDs match the current user
    );

    // Check if this user is blocked
    final isBlocked =
        blockedUsers.any((blockedUser) => blockedUser['id'] == metalId);
    final isConnectionBlocked = user.status == "blocked";

    final getUser = ref.watch(getUserProvider(metalId));

    return CardWithShadow(
        onTap: () {
          // If the user is blocked, show dialog instead of navigating
          if (isBlocked || isConnectionBlocked) {
            // Use new helper function for blocked user dialog
            showBlockedUserDialog(
              context,
              userName: getUser.data?.username ?? "This user",
              userId: metalId,
              onUnblock: () {
                ref.read(blockUserProvider.notifier).unBlockUser(metalId);
              },
            );
          } else {
            Navigator.pushNamed(
              context,
              AppRoutes.myMeltedUser,
              arguments: {"metalId": metalId},
            );
          }
        },
        height: 105,
        child: getUser.isLoading
            ? const Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : Opacity(
                opacity: isBlocked || isConnectionBlocked
                    ? 0.5
                    : 1.0, // Grey out blocked users
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        ProfilePhoto(
                            size: 56,
                            verfly: false,
                            meltId: getUser.data!.metal!,
                            imgUrl: user.isAnonymous
                                ? null
                                : getUser.data!.profilePhoto),
                        if (isBlocked || isConnectionBlocked)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.block,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Gap(23),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        user.isAnonymous
                            ? TextView(
                                text: getUser.data!.username!,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              )
                            : TextView(
                                text: getUser.data!.fullname!,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                        const Gap(5),
                        TextView(
                          text: "-  ${getUser.data!.gender}",
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        const Gap(14),
                        Row(
                          children: [
                            TextView(
                              text:
                                  "- ${getUser.data!.connectionOption?[0] ?? ""}",
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                            if (isBlocked || isConnectionBlocked)
                              const TextView(
                                text: " (Blocked)",
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.red,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ));
  }
}
