import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/presentation/viewmodels/settings/blocked_users_viewmodel.dart';
import 'package:metal/presentation/widgets/settings/block_user_helper.dart';

/// A reusable block button that can be used across the app
/// Shows either 'Block' or 'Unblock' based on the current block status
class BlockUserButton extends ConsumerWidget {
  final String userId;
  final String username;
  final Color? textColor;
  final IconData? icon;
  final double fontSize;
  final bool isOutlined;
  final VoidCallback? onBlockStatusChanged;

  const BlockUserButton({
    Key? key,
    required this.userId,
    required this.username,
    this.textColor = Colors.red,
    this.icon = Icons.block,
    this.fontSize = 14.0,
    this.isOutlined = false,
    this.onBlockStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedUsers = ref.watch(blockedUsersViewModelProvider).blockedUsers;
    final isBlocked = blockedUsers.any((user) => user.id == userId);

    return isOutlined
        ? OutlinedButton.icon(
            icon: Icon(
              isBlocked ? Icons.check_circle : icon,
              size: 16,
              color: textColor,
            ),
            label: Text(
              isBlocked ? 'Unblock' : 'Block',
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: textColor!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => _handleBlockAction(context, ref, isBlocked),
          )
        : TextButton.icon(
            icon: Icon(
              isBlocked ? Icons.check_circle : icon,
              size: 16,
              color: textColor,
            ),
            label: Text(
              isBlocked ? 'Unblock' : 'Block',
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            onPressed: () => _handleBlockAction(context, ref, isBlocked),
          );
  }

  void _handleBlockAction(
      BuildContext context, WidgetRef ref, bool isBlocked) async {
    if (isBlocked) {
      // Show unblock confirmation dialog
      final didUnblock = await showBlockedUserDialog(
        context,
        userName: username,
        userId: userId,
        onUnblock: () async {
          // Call the unblock method from the viewmodel
          final success = await ref
              .read(blockedUsersViewModelProvider.notifier)
              .unblockUser(userId: userId);

          if (success) {
            // Refresh the blocked users list
            await ref
                .read(blockedUsersViewModelProvider.notifier)
                .refreshBlockedUsers();
            
            if (onBlockStatusChanged != null) {
              onBlockStatusChanged!();
            }
          }
        },
      );

      if (didUnblock && onBlockStatusChanged != null) {
        onBlockStatusChanged!();
      }
    } else {
      // Show block reason dialog
      await showBlockReasonDialog(
        context,
        userId: userId,
        username: username,
      );

      // Refresh the blocked users list after blocking
      await ref
          .read(blockedUsersViewModelProvider.notifier)
          .refreshBlockedUsers();

      if (onBlockStatusChanged != null) {
        onBlockStatusChanged!();
      }
    }
  }
}
