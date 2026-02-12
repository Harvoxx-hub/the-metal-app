import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/presentation/views/spark/widgets/search_user_dialog.dart';
import 'package:metal/presentation/viewmodels/spark/spark_viewmodel.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

/// Dialog for sending sparks to another user
class SendSparkDialog extends ConsumerStatefulWidget {
  final UserDto? preSelectedUser;
  
  const SendSparkDialog({
    super.key,
    this.preSelectedUser,
  });

  @override
  ConsumerState<SendSparkDialog> createState() => _SendSparkDialogState();
}

class _SendSparkDialogState extends ConsumerState<SendSparkDialog> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectedUserId;
  UserDto? selectedUser;

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedUser != null) {
      selectedUser = widget.preSelectedUser;
      selectedUserId = widget.preSelectedUser!.id;
      _usernameController.text = widget.preSelectedUser!.username ??
          widget.preSelectedUser!.fullname ?? '';
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _openSearchUserDialog() async {
    if (widget.preSelectedUser != null) return;
    final user = await SearchUserDialog.show(context);
    if (!mounted || user == null) return;
    setState(() {
      selectedUserId = user.id;
      selectedUser = user;
      _usernameController.text = user.username ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final sparkState = ref.watch(sparkViewModelProvider);

    return Dialog(
      backgroundColor: AppColors.metalWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const TextView(
                    text: "Send Sparks ✨",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Gap(10),
              TextView(
                text: "Available: ${sparkState.balance} sparks",
                fontSize: 14,
                color: AppColors.metalPinkColour,
                fontWeight: FontWeight.w600,
              ),
              const Gap(20),
              // Recipient (tap opens search dialog)
              const TextView(
                text: "Recipient Username",
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              const Gap(8),
              EditFormField(
                controller: _usernameController,
                hint: "Search by username",
                readOnly: true,
                onTapped: _openSearchUserDialog,
                enabled: widget.preSelectedUser == null,
                validator: (value) {
                  if (widget.preSelectedUser != null) return null;
                  if (selectedUserId == null) {
                    return "Please select a recipient";
                  }
                  return null;
                },
              ),
              const Gap(16),
              // Amount field
              const TextView(
                text: "Amount",
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              const Gap(8),
              EditFormField(
                controller: _amountController,
                hint: "Enter amount",
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter an amount";
                  }
                  final amount = int.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return "Please enter a valid amount";
                  }
                  if (amount > sparkState.balance) {
                    return "Insufficient balance";
                  }
                  return null;
                },
              ),
              const Gap(16),
              // Message field (optional)
              const TextView(
                text: "Message (Optional)",
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              const Gap(8),
              EditFormField(
                controller: _messageController,
                hint: "Add a message",
                maxLines: 3,
              ),
              const Gap(24),
              // Send button
              BaseButton(
                buttonText: "Send Sparks",
                loading: sparkState.isSending,
                onPressed: () => _handleSendSparks(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSendSparks() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedUserId == null) {
      Fluttertoast.showToast(msg: "Please select a recipient");
      return;
    }

    final amount = int.parse(_amountController.text);
    final message = _messageController.text.isNotEmpty
        ? _messageController.text
        : null;

    final success = await ref.read(sparkViewModelProvider.notifier).sendSparks(
          recipientId: selectedUserId!,
          amount: amount,
          message: message,
        );

    if (mounted) {
      if (success) {
        Fluttertoast.showToast(
          msg: "Successfully sent $amount sparks to @${selectedUser?.username ?? 'user'}",
        );
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
          msg: ref.read(sparkViewModelProvider).errorMessage ?? "Failed to send sparks",
        );
      }
    }
  }
}
