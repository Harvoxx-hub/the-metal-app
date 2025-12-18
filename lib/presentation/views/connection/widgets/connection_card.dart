import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/data/datasources/remote/connection_remote_data_source.dart';
import 'package:metal/features/settings/presentation/widget/block_user_helper.dart';
import 'package:metal/features/settings/provider/get.blocked.user.notifier.dart';
import 'package:metal/features/settings/provider/block.user.notifier.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/card.with.shadow.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

/// Connection card widget for displaying a single connection in the list
class ConnectionCard extends ConsumerWidget {
  const ConnectionCard({super.key, required this.connection});

  final ConnectionApiModel connection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserDto = ref.watch(userStateProvider).user;
    final blockedUsers = ref.watch(getBlockUserProvider).data ?? [];

    // Get the other user's ID from the connection
    final otherUserId = connection.users.firstWhere(
      (userId) => userId != currentUserDto?.id,
      orElse: () => "",
    );

    // Check if this user is blocked
    final isBlocked =
        blockedUsers.any((blockedUser) => blockedUser['id'] == otherUserId);
    final isConnectionBlocked = connection.status == "blocked";

    // Use otherUser from the connection API response
    final otherUser = connection.otherUser;

    return CardWithShadow(
      onTap: () {
        if (isBlocked || isConnectionBlocked) {
          showBlockedUserDialog(
            context,
            userName: otherUser?.username ?? "This user",
            userId: otherUserId,
            onUnblock: () {
              ref.read(blockUserProvider.notifier).unBlockUser(otherUserId);
            },
          );
        } else {
          Navigator.pushNamed(
            context,
            AppRoutes.myMeltedUser,
            arguments: {"metalId": otherUserId},
          );
        }
      },
      height: 105,
      child: otherUser == null
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Opacity(
              opacity: isBlocked || isConnectionBlocked ? 0.5 : 1.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      ProfilePhoto(
                        size: 56,
                        verfly: false,
                        meltId: otherUser.metal ?? '',
                        imgUrl: connection.isAnonymous
                            ? null
                            : otherUser.profilePhoto,
                      ),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextView(
                          text: connection.isAnonymous
                              ? (otherUser.username ?? 'Anonymous')
                              : otherUser.fullName,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        const Gap(5),
                        if (otherUser.gender != null)
                          TextView(
                            text: "-  ${otherUser.gender}",
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        const Gap(14),
                        Row(
                          children: [
                            if (otherUser.connectionOption?.isNotEmpty == true)
                              TextView(
                                text: "- ${otherUser.connectionOption![0]}",
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
                  ),
                ],
              ),
            ),
    );
  }
}
