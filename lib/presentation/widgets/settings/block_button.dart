import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/features/settings/presentation/widget/block_user_helper.dart';
import 'package:metal/features/settings/provider/get.blocked.user.notifier.dart';

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
    final blockedUsers = ref.watch(getBlockUserProvider).data ?? [];
    final isBlocked =
        blockedUsers.any((blockedUser) => blockedUser['id'] == userId);

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
        onUnblock: () {
          // Unblock logic handled in the dialog
          if (onBlockStatusChanged != null) {
            onBlockStatusChanged!();
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

      if (onBlockStatusChanged != null) {
        onBlockStatusChanged!();
      }
    }
  }
}
