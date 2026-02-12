import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/blocked_user_dto.dart';
import 'package:metal/presentation/viewmodels/settings/blocked_users_viewmodel.dart';
import 'package:metal/presentation/widgets/settings/block_user_helper.dart';
import 'package:metal/widgets/card.with.shadow.dart';
import 'package:metal/widgets/text_views.dart';

class BlockedCard extends ConsumerWidget {
  const BlockedCard({
    super.key,
    required this.blockedUserDto,
  });

  final BlockedUserDto blockedUserDto;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: CardWithShadow(
        onTap: () {
          showBlockedUserDialog(
            context,
            userName: blockedUserDto.username ?? 'Unknown',
            userId: blockedUserDto.userId,
            onUnblock: () async {
              await ref
                  .read(blockedUsersViewModelProvider.notifier)
                  .unblockUser(userId: blockedUserDto.userId);
            },
          );
        },
        height: 105,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ProfilePhoto can be added here if needed
            // ProfilePhoto(
            //   photoUrl: blockedUserDto.profilePhoto,
            // ),
            const Gap(23),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextView(
                  text: blockedUserDto.username ?? 'Unknown',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                if (blockedUserDto.fullname != null) ...[
                  const Gap(4),
                  TextView(
                    text: blockedUserDto.fullname!,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
