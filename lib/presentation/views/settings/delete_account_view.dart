import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/presentation/viewmodels/settings/delete_account_viewmodel.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/text_views.dart';

/// Delete Account View - allows users to delete their account
class DeleteAccountView extends ConsumerStatefulWidget {
  const DeleteAccountView({super.key});

  @override
  ConsumerState<DeleteAccountView> createState() => _DeleteAccountViewState();
}

class _DeleteAccountViewState extends ConsumerState<DeleteAccountView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deleteAccountState = ref.watch(deleteAccountViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.metalWhite,
      appBar: AppBar(
        title: const TextView(
          text: "Delete Account",
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: AppColors.metalWhite,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: Colors.red.shade700,
                      size: 24,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextView(
                            text: 'Warning',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                          const Gap(4),
                          TextView(
                            text:
                                'This action is permanent and cannot be undone. All your data will be deleted.',
                            fontSize: 14,
                            color: Colors.red.shade900,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(24),
              const TextView(
                text: 'What happens when you delete your account:',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              const Gap(12),
              _buildInfoItem('Your profile will be permanently removed'),
              _buildInfoItem('All your connections will be deleted'),
              _buildInfoItem('Your messages and data will be erased'),
              _buildInfoItem('You will lose access to all features'),
              const Gap(32),
              const TextView(
                text: 'Enter your password to confirm',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              const Gap(12),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.metalPinkColour,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const Gap(32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: deleteAccountState.isDeleting
                      ? null
                      : () => _handleDeleteAccount(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: AppColors.metalWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: deleteAccountState.isDeleting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.metalWhite,
                          ),
                        )
                      : const TextView(
                          text: 'Delete My Account',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.metalWhite,
                        ),
                ),
              ),
              if (deleteAccountState.isError && deleteAccountState.errorMessage != null) ...[
                const Gap(16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const Gap(8),
                      Expanded(
                        child: TextView(
                          text: deleteAccountState.errorMessage!,
                          fontSize: 14,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 20,
            color: Colors.grey,
          ),
          const Gap(8),
          Expanded(
            child: TextView(
              text: text,
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const TextView(
          text: 'Are you absolutely sure?',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        content: const TextView(
          text:
              'This will permanently delete your account and all associated data. This action cannot be undone.',
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
              backgroundColor: Colors.red,
            ),
            child: const TextView(
              text: 'Delete Account',
              fontSize: 14,
              color: AppColors.metalWhite,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(deleteAccountViewModelProvider.notifier)
          .deleteAccount(password: _passwordController.text);

      if (!context.mounted) return;

      if (success) {
        // Account deleted successfully - navigate to login screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to login screen and clear navigation stack
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }
}
