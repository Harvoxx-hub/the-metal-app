import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/block_reason_code.dart';
import 'package:metal/presentation/viewmodels/settings/blocked_users_viewmodel.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

class BlockReasonDialog extends ConsumerStatefulWidget {
  final String userId;
  final String username;

  const BlockReasonDialog({
    Key? key,
    required this.userId,
    required this.username,
  }) : super(key: key);

  @override
  ConsumerState<BlockReasonDialog> createState() => _BlockReasonDialogState();
}

class _BlockReasonDialogState extends ConsumerState<BlockReasonDialog> {
  String selectedReasonCode = BlockReasonCode.harassment.name;
  bool isReporting = false;
  final TextEditingController _customReasonController = TextEditingController();
  final TextEditingController _reportDetailsController =
      TextEditingController();

  @override
  void dispose() {
    _customReasonController.dispose();
    _reportDetailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blockState = ref.watch(blockedUsersViewModelProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextView(
              text: "Block User",
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
            const Gap(10),
            TextView(
              text: "You are about to block @${widget.username}",
              fontSize: 16,
            ),
            const Gap(20),
            const TextView(
              text: "Select a reason for blocking:",
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            const Gap(10),
            _buildReasonSelector(),
            const Gap(15),

            // Show custom reason field if 'Other' is selected
            if (selectedReasonCode == BlockReasonCode.other.name)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EditFormField(
                    label: "Specify reason",
                    controller: _customReasonController,
                    maxLines: 2,
                  ),
                  const Gap(15),
                ],
              ),

            // Option to also report the user
            Row(
              children: [
                Checkbox(
                  value: isReporting,
                  onChanged: (value) {
                    setState(() {
                      isReporting = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isReporting = !isReporting;
                      });
                    },
                    child: const TextView(
                      text: "Also report this user to Metal moderators",
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            // Show report details field if reporting
            if (isReporting)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(10),
                  const TextView(
                    text: "Please provide details about your report:",
                    fontSize: 14,
                  ),
                  const Gap(5),
                  EditFormField(
                    label: "Report details",
                    controller: _reportDetailsController,
                    maxLines: 3,
                  ),
                  const Gap(15),
                ],
              ),

            const Gap(20),
            Column(
              children: [
              
               
                BaseButton(
                  buttonText: isReporting ? "Block & Report" : "Block",
                  loading: blockState.isBlocking,
                  onPressed: () {
                    _handleBlockUser();
                  },
                  color: Colors.red,
                ),

                Gap(
                  10
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const TextView(text: "Cancel"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: BlockReasonCode.values.map((reasonCode) {
          return RadioListTile<String>(
            title: TextView(
              text: BlockReasonCodeExtension(reasonCode).displayName,
              fontSize: 14,
            ),
            value: reasonCode.name,
            groupValue: selectedReasonCode,
            onChanged: (value) {
              setState(() {
                selectedReasonCode = value!;
              });
            },
            dense: true,
          );
        }).toList(),
      ),
    );
  }

  void _handleBlockUser() async {
    // Get custom reason if 'Other' was selected
    String? customReason;
    if (selectedReasonCode == BlockReasonCode.other.name) {
      customReason = _customReasonController.text.trim();
      if (customReason.isEmpty) {
        // Show error for empty custom reason
        Fluttertoast.showToast(msg: 'Please specify a reason');
        return;
      }
    }

    // Get report details if reporting
    String? reportDetails;
    if (isReporting) {
      reportDetails = _reportDetailsController.text.trim();
      if (reportDetails.isEmpty) {
        // Show error for empty report details
        Fluttertoast.showToast(msg: 'Please provide report details');
        return;
      }
    }

    // Build comprehensive reason string
    final reasonCode = BlockReasonCode.values.firstWhere(
      (code) => code.name == selectedReasonCode,
      orElse: () => BlockReasonCode.other,
    );
    final reasonDisplay = BlockReasonCodeExtension(reasonCode).displayName;

    String fullReason = reasonDisplay;
    if (customReason != null && customReason.isNotEmpty) {
      fullReason = '$fullReason: $customReason';
    }
    if (isReporting && reportDetails != null && reportDetails.isNotEmpty) {
      fullReason = '$fullReason | Report: $reportDetails';
    }

    // Call the block method with the new architecture
    final success = await ref
        .read(blockedUsersViewModelProvider.notifier)
        .blockUser(
          userId: widget.userId,
          reason: fullReason,
        );

    if (success && mounted) {
      // Refresh the blocked users list to ensure it's up to date
      await ref
          .read(blockedUsersViewModelProvider.notifier)
          .refreshBlockedUsers();
      
      // Close the dialog
      Navigator.of(context).pop();

      // Show success message
      Fluttertoast.showToast(
        msg: isReporting
                ? 'User blocked and reported successfully'
                : 'User blocked successfully',
      );
    } else if (mounted) {
      // Show error message
      final errorMessage =
          ref.read(blockedUsersViewModelProvider).errorMessage ??
              'Failed to block user';
      Fluttertoast.showToast(msg: errorMessage);
    }
  }
}
