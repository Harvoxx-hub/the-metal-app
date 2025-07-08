import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/features/authentication/presentation/signup/verfication.argument.dart';
import 'package:metal/features/authentication/presentation/signup/verfication.page.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/features/authentication/provider/verfication.notifier.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/route/routes.dart';

class WorkEmailPage extends ConsumerStatefulWidget {
  const WorkEmailPage({Key? key}) : super(key: key);

  @override
  ConsumerState<WorkEmailPage> createState() => _WorkEmailPageState();
}

class _WorkEmailPageState extends ConsumerState<WorkEmailPage> {
  final _emailController = TextEditingController();
  String? _errorText;
  bool _isLoading = false;

  bool isValidWorkEmail(String email) {
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

    if (!email.contains('@')) return false;

    final domain = email.split('@')[1].toLowerCase();
    return !publicDomains.contains(domain);
  }

  void _verifyEmail() async {
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

    setState(() => _isLoading = true);

    try {
      // Send verification code for work email
      await ref.read(verficationProvider.notifier).sendVerificationCode(email);

      if (mounted) {
        // Navigate to verification page
        Navigator.pushNamed(
          context,
          AppRoutes.verificationPage,
          arguments: VerificationSentArgument(
            email: email,
            type: RouteFrom.WorkEmail,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() =>
            _errorText = 'Failed to send verification code. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBarState: AppBarState.BackWithHeader,
        headerText: 'Work Email Verification',
        onBackButtonPressed: () => Navigator.pop(context),
        onHamburgerPressed: () {},
        onSkipButtonPressed: () {},
        onNotificationPressed: () {},
        appBarEnabled: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.metalPinkColour.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.metalPinkColour),
                    const SizedBox(width: 12),
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
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Work Email',
                  hintText: 'Enter your work email',
                  errorText: _errorText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() => _errorText = null),
              ),
              const SizedBox(height: 32),
              BaseButton(
                buttonText: 'Verify Email',
                onPressed: _isLoading ? null : _verifyEmail,
                loading: _isLoading,
              ),
            ],
          ),
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
