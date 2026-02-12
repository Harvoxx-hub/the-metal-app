import 'package:flutter/material.dart';
import 'package:metal/presentation/widgets/settings/block_reason_dialog.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text_views.dart';

/// Shows the enhanced block user dialog with reason selection and reporting options
Future<void> showBlockReasonDialog(
  BuildContext context, {
  required String userId,
  required String username,
}) async {
  try {
    return await showDialog(
      context: context,

      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (context) => WillPopScope(
        // Handle back button press
        onWillPop: () async {
          return true; // Allow dialog to be dismissed
        },
        child: Dialog(
          backgroundColor: AppColors.metalWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: BlockReasonDialog(
            userId: userId,
            username: username,
          ),
        ),
      ),
    );
  } catch (e) {
    // Silently handle any errors during dialog display
    print("Error showing block dialog: $e");
  }
}

/// Shows a dialog to inform the user they've blocked someone
/// Returns true if the user was successfully unblocked
Future<bool> showBlockedUserDialog(
  BuildContext context, {
  required String userName,
  required String userId,
  required Function() onUnblock,
}) async {
  try {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextView(
              text: "User Blocked",
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 16),
            TextView(
              text: "You have blocked @$userName",
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(height: 8),
            TextView(
              text:
                  "You will not see their content and they cannot interact with you. You need to unblock this user to view their profile or interact with them.",
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const TextView(
                    text: "Cancel",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    try {
                      onUnblock();
                      Navigator.of(context).pop(true);
                    } catch (e) {
                      Navigator.of(context).pop(false);
                    }
                  },
                  child: const TextView(
                    text: "Unblock User",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return result ?? false;
  } catch (e) {
    return false;
  }
}
