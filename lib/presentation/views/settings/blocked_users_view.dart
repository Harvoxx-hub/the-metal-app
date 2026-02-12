import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:metal/presentation/viewmodels/settings/blocked_users_viewmodel.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

/// Blocked Users View - displays list of blocked users
class BlockedUsersView extends ConsumerWidget {
  const BlockedUsersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedUsersState = ref.watch(blockedUsersViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.metalWhite,
      appBar: AppBar(
        title: const TextView(
          text: "Blocked Users",
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: AppColors.metalWhite,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(blockedUsersViewModelProvider.notifier)
              .refreshBlockedUsers();
        },
        child: _buildBody(context, ref, blockedUsersState),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    BlockedUsersState state,
  ) {
    if (state.isLoading && state.blockedUsers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.metalPinkColour,
        ),
      );
    }

    if (state.isError && state.blockedUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const Gap(16),
            TextView(
              text: state.errorMessage ?? 'Failed to load blocked users',
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
            const Gap(16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(blockedUsersViewModelProvider.notifier)
                    .refreshBlockedUsers();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.metalPinkColour,
              ),
              child: const TextView(
                text: 'Retry',
                fontSize: 14,
                color: AppColors.metalWhite,
              ),
            ),
          ],
        ),
      );
    }

    if (state.blockedUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.block,
              size: 64,
              color: Colors.grey,
            ),
            const Gap(16),
            const TextView(
              text: 'No blocked users',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            const Gap(8),
            TextView(
              text: 'Users you block will appear here',
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: state.blockedUsers.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.blockedUsers.length) {
          if (state.hasMore) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  color: AppColors.metalPinkColour,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        final blockedUser = state.blockedUsers[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.metalPinkColour.withValues(alpha: 0.2),
              backgroundImage: blockedUser.profilePhoto != null
                  ? NetworkImage(blockedUser.profilePhoto!)
                  : null,
              child: blockedUser.profilePhoto == null
                  ? TextView(
                      text: blockedUser.fullname?.substring(0, 1).toUpperCase() ??
                          blockedUser.username?.substring(0, 1).toUpperCase() ??
                          'U',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.metalPinkColour,
                    )
                  : null,
            ),
            title: TextView(
              text: blockedUser.fullname ?? blockedUser.username ?? 'Unknown',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (blockedUser.username != null)
                  TextView(
                    text: '@${blockedUser.username}',
                    fontSize: 14,
                    color: Colors.grey[600]!,
                  ),
                if (blockedUser.reason != null) ...[
                  const Gap(4),
                  Text(
                    'Reason: ${blockedUser.reason}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500]!,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            trailing: ElevatedButton(
              onPressed: state.isUnblocking
                  ? null
                  : () => _handleUnblock(context, ref, blockedUser.userId),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.metalPinkColour,
                foregroundColor: AppColors.metalWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const TextView(
                text: 'Unblock',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.metalWhite,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleUnblock(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const TextView(
          text: 'Unblock User',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        content: const TextView(
          text: 'Are you sure you want to unblock this user?',
          fontSize: 14,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const TextView(
              text: 'Cancel',
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.metalPinkColour,
            ),
            child: const TextView(
              text: 'Unblock',
              fontSize: 14,
              color: AppColors.metalWhite,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(blockedUsersViewModelProvider.notifier)
          .unblockUser(userId: userId);

      if (context.mounted) {
        if (success) {
          Fluttertoast.showToast(msg: 'User unblocked successfully');
        } else {
          final errorMessage = ref.read(blockedUsersViewModelProvider).errorMessage;
          Fluttertoast.showToast(msg: errorMessage ?? 'Failed to unblock user');
        }
      }
    }
  }
}
