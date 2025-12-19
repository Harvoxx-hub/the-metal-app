import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/presentation/viewmodels/verification/work_email_verification_viewmodel.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/text_views.dart';

/// Work Email Verification View
/// Allows users to verify their work email for professional badge
class WorkEmailVerificationView extends ConsumerStatefulWidget {
  static const String route = '/work-email-verification';

  const WorkEmailVerificationView({super.key});

  @override
  ConsumerState<WorkEmailVerificationView> createState() =>
      _WorkEmailVerificationViewState();
}

class _WorkEmailVerificationViewState
    extends ConsumerState<WorkEmailVerificationView> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workEmailVerificationViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Work Email'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.verified_user,
                size: 80,
                color: AppColors.metalPinkColour,
              ),
              const Gap(24),
              const TextView(
                text: 'Verify Your Work Email',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              const Gap(12),
              TextView(
                text:
                    'Get a professional badge on your profile by verifying your work email.',
                fontSize: 14,
                color: Colors.grey[600],
                textAlign: TextAlign.center,
              ),
              const Gap(32),
              if (!state.codeSent) _buildEmailInput(),
              if (state.codeSent && !state.isVerified) _buildCodeInput(),
              if (state.isVerified) _buildSuccessMessage(),
              const Gap(24),
              if (state.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextView(
                    text: state.errorMessage!,
                    fontSize: 14,
                    color: Colors.red[700],
                  ),
                ),
              if (state.successMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextView(
                    text: state.successMessage!,
                    fontSize: 14,
                    color: Colors.green[700],
                  ),
                ),
              const Gap(24),
              if (!state.isVerified) _buildActionButton(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextView(
          text: 'Work Email',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        const Gap(8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'your.name@company.com',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your work email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextView(
          text: 'Verification Code',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        const Gap(8),
        TextView(
          text: 'Enter the 6-digit code sent to ${ref.read(workEmailVerificationViewModelProvider).workEmail}',
          fontSize: 14,
          color: Colors.grey[600],
        ),
        const Gap(12),
        TextFormField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            hintText: '000000',
            prefixIcon: Icon(Icons.vpn_key_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the verification code';
            }
            if (value.length != 6) {
              return 'Code must be 6 digits';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: 64,
            color: Colors.green[600],
          ),
          const Gap(16),
          const TextView(
            text: 'Email Verified!',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
          const Gap(8),
          TextView(
            text: 'Your work email has been verified. You now have a professional badge on your profile.',
            fontSize: 14,
            color: Colors.grey[700],
            textAlign: TextAlign.center,
          ),
          const Gap(24),
          PlainButton(
            buttonText: 'Back to Profile',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(WorkEmailVerificationState state) {
    if (!state.codeSent) {
      return PlainButton(
        buttonText: 'Send Verification Code',
        loading: state.isLoading,
        onPressed: state.isLoading
            ? null
            : () async {
                if (_formKey.currentState!.validate()) {
                  await ref
                      .read(workEmailVerificationViewModelProvider.notifier)
                      .requestVerification(
                        workEmail: _emailController.text.trim(),
                      );
                }
              },
      );
    } else {
      return Column(
        children: [
          PlainButton(
            buttonText: 'Verify Code',
            loading: state.isLoading,
            onPressed: state.isLoading
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      final success = await ref
                          .read(workEmailVerificationViewModelProvider.notifier)
                          .verifyCode(
                            code: _codeController.text.trim(),
                          );

                      if (success) {
                        // Success is handled in the UI via state.isVerified
                      }
                    }
                  },
          ),
          const Gap(12),
          TextButton(
            onPressed: state.isLoading
                ? null
                : () {
                    ref
                        .read(workEmailVerificationViewModelProvider.notifier)
                        .reset();
                    _codeController.clear();
                  },
            child: const Text('Change Email'),
          ),
        ],
      );
    }
  }
}
