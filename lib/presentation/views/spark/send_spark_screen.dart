import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/presentation/viewmodels/spark/spark_viewmodel.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/presentation/views/spark/widgets/search_user_dialog.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/dialog/dialogs.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/route/routes.dart';

/// Full screen for sending sparks to another user
class SendSparkScreen extends ConsumerStatefulWidget {
  final UserDto? preSelectedUser;

  const SendSparkScreen({
    super.key,
    this.preSelectedUser,
  });

  @override
  ConsumerState<SendSparkScreen> createState() => _SendSparkScreenState();
}

class _SendSparkScreenState extends ConsumerState<SendSparkScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
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
          widget.preSelectedUser!.fullname ??
          '';
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _amountController.dispose();
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

    return Scaffold(
      backgroundColor: AppColors.metalWhite,
      appBar: CustomAppBar(
        appBarState: AppBarState.BackWithHeader,
        headerText: "Send Spark",
        appBarEnabled: true,
        onBackButtonPressed: () => Navigator.pop(context),
        onHamburgerPressed: () {},
        onSkipButtonPressed: () {},
        onNotificationPressed: () {
          Navigator.pushNamed(context, AppRoutes.notificationPage);
        },
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Sparks Balance Card - Hot Pink
              _buildBalanceCard(sparkState.balance.toString()),

              const Gap(24),

              // Form Section
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipient field (tap opens search dialog)
                      const TextView(
                        text: "I want to send Sparks to",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.metalBrownColourForText,
                      ),
                      const Gap(8),
                      EditFormField(
                        controller: _usernameController,
                        hint: "Search by username",
                        readOnly: true,
                        onTapped: _openSearchUserDialog,
                        enabled: widget.preSelectedUser == null,
                        prefixWidget: const Icon(
                          Icons.person_outline,
                          color: AppColors.metalPinkColour,
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w300,
                          fontSize: 14,
                        ),
                        validator: (value) {
                          if (widget.preSelectedUser != null) return null;
                          if (selectedUserId == null) {
                            return "Please select a recipient";
                          }
                          return null;
                        },
                      ),

                      const Gap(20),

                      // Amount field
                      const TextView(
                        text: "Number of Sparks to send",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.metalBrownColourForText,
                      ),
                      const Gap(8),
                      EditFormField(
                        controller: _amountController,
                        hint: "Number of sparks to send",
                        keyboardType: TextInputType.number,
                        prefixWidget: const Icon(
                          Icons.star_outline,
                          color: AppColors.metalPinkColour,
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w300,
                          fontSize: 14,
                        ),
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

                      const Gap(32),
                    ],
                  ),
                ),
              ),

              // Bottom Send Button - Gradient (red-orange to pink)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: BaseButton(
                  buttonText: "Send spark",
                  loading: sparkState.isSending,
                  onPressed: () => _handleSendSparks(),
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String balance) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.metalPinkColour,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              TextView(
                text: "Sparks Balance ",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.metalWhite,
              ),
              Text(
                "✨",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          const Gap(12),
          TextView(
            text: balance,
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.metalWhite,
          ),
          const Gap(16),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF87CEEB), // Light blue
                      Color(0xFF4682B4), // Steel blue
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_upward,
                  color: AppColors.metalWhite,
                  size: 24,
                ),
              ),
              const Gap(12),
              const TextView(
                text: "Send Sparks",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.metalWhite,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleSendSparks() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedUserId == null && widget.preSelectedUser == null) {
      Fluttertoast.showToast(msg: "Please select a recipient");
      return;
    }

    final recipientId = selectedUserId ?? widget.preSelectedUser!.id;
    final amount = int.parse(_amountController.text);

    final success = await ref.read(sparkViewModelProvider.notifier).sendSparks(
          recipientId: recipientId,
          amount: amount,
          message: null,
        );

    if (!mounted) return;

    final userName =
        selectedUser?.username ?? widget.preSelectedUser?.username ?? 'user';
    final message = success
        ? "Successfully sent $amount spark${amount == 1 ? '' : 's'} to @$userName"
        : (ref.read(sparkViewModelProvider).errorMessage ??
            "Failed to send sparks");

    final navigator = Navigator.of(context);
    await MetalDialog.show(
      context: context,
      barrierDismissible: false,
      icon: Icon(
        success ? Icons.check_circle : Icons.error_outline,
        size: 48,
        color: success ? AppColors.metalPinkColour : Colors.grey.shade700,
      ),
      title: success ? "Success" : "Failed",
      content: TextView(
        text: message,
        fontSize: 14,
        textAlign: TextAlign.center,
        color: Colors.black87,
      ),
      primaryButtonText: "Dismiss",
      onPrimaryPressed: () {
        navigator.pop(); // Close dialog
        navigator.pop(); // Back to previous screen
      },
    );
  }
}
