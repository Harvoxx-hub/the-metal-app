import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/authentication/provider/update.profile.notifier.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text.field/base.text.field.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

class WorkEmailDialog extends ConsumerStatefulWidget {
  const WorkEmailDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<WorkEmailDialog> createState() => _WorkEmailDialogState();
}

class _WorkEmailDialogState extends ConsumerState<WorkEmailDialog> {
  final _emailController = TextEditingController();
  String? _errorText;

  bool isValidWorkEmail(String email) {
    // List of common public email domains to reject
    final publicDomains = [
      'gmail.com',
      'yahoo.com',
      'hotmail.com',
      'outlook.com',
      'aol.com',
      'icloud.com',
      'mail.com',
      'protonmail.com',
      'zoho.com'
    ];

    // Check if email contains @ and has a domain
    if (!email.contains('@')) return false;

    final domain = email.split('@')[1].toLowerCase();
    return !publicDomains.contains(domain);
  }

  void _verifyEmail() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorText = 'Please enter your work email');
      return;
    }

    if (!isValidWorkEmail(email)) {
      setState(() => _errorText =
          'Please enter a valid work or school email. Public email domains are not accepted.');
      return;
    }

    // Update the user model with work email
    final userData = ref.read(authProvider).data;
    if (userData != null) {
      final updated = userData.copyWith(
        workEmail: email,
        workEmailVerified: false, // Will be set to true after verification
      );
      // TODO: Implement email verification logic here
      ref.read(updateProfileProvider.notifier).updateUserData(updated);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextView(
              text: 'Work Email Verification',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppColors.metalPinkColour),
                const SizedBox(width: 8),
                Expanded(
                  child: TextView(
                    text:
                        'Only work or school email addresses are accepted. Public email domains (Gmail, Yahoo, etc.) are not allowed.',
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Enter your work email',
                errorText: _errorText,
              ),
              onChanged: (_) => setState(() => _errorText = null),
            ),
            const SizedBox(height: 24),
            BaseButton(
              buttonText: 'Verify Email',
              onPressed: _verifyEmail,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
