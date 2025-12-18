import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/base/widget/appbar.state.dart';

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

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    // TODO: Implement work email verification with new API flow
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: 'Work email verification coming soon');
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBarState: AppBarState.BackWithHeader,
        headerText: 'Work Email',
        onBackButtonPressed: () => Navigator.pop(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextView(
              text: 'Verify Your Work Email',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 12),
            const TextView(
              text:
                  'Add your work or school email to get verified and unlock additional features.',
              fontSize: 14,
              color: AppColors.metalBrownColourForText,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Work Email',
                hintText: 'name@company.com',
                errorText: _errorText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
            ),
            const Spacer(),
            BaseButton(
              buttonText: 'Verify Email',
              loading: _isLoading,
              onPressed: _isLoading ? null : _verifyEmail,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
