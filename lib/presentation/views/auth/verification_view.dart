import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/strings/app_strings.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/auth/verification_viewmodel.dart';
import 'package:metal/presentation/viewmodels/profile/profile_viewmodel_providers.dart';
import 'package:metal/res/res.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text_views.dart';

/// Email verification view
/// Receives email as simple string argument
class VerificationView extends ConsumerStatefulWidget {
  const VerificationView({super.key});

  static const String name = 'verification';
  static const String route = '/verification';

  @override
  ConsumerState<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends ConsumerState<VerificationView> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  String? _email;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendInitialCode();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get email from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _email = args;
    }
  }

  void _sendInitialCode() {
    if (_email != null) {
      ref.read(verificationViewModelProvider.notifier).sendCode(_email!);
    }
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _verifyCode() {
    if (_email == null) return;
    final code = _otpCode;
    if (code.length != 6) return;

    FocusScope.of(context).unfocus();
    ref.read(verificationViewModelProvider.notifier).verifyCode(_email!, code);
  }

  void _resendCode() {
    if (_email == null) return;
    // Clear existing OTP
    for (var controller in _controllers) {
      controller.clear();
    }
    ref.read(verificationViewModelProvider.notifier).sendCode(_email!);
  }

  void _handleVerificationSuccess() async {
    // Refresh user profile to get updated emailVerified status
    await ref.read(profileViewModelProvider.notifier).fetchUserProfile();

    if (!mounted) return;

    final profileState = ref.read(profileViewModelProvider);
    final user = profileState.data;

    // Navigate based on profile completion
    if (user?.profileUpdated == true) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.dashboardPage,
        (route) => false,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.welcomePage,
        (route) => false,
      );
    }
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) {
      return '$name***@$domain';
    }

    final visible = name.substring(0, 2);
    return '$visible***@$domain';
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final verificationState = ref.watch(verificationViewModelProvider);
    final viewModel = ref.read(verificationViewModelProvider.notifier);

    // Listen for state changes
    ref.listen(verificationViewModelProvider, (previous, current) {
      if (current.isSuccess && current.action?['type'] == 'verified') {
        _handleVerificationSuccess();
      }
    });

    return BaseScreen(
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: AppStrings.verificationTitle,
      authFlow: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Gap(40),
            const TextView(
              text: AppStrings.verificationEmoji,
              fontSize: 48,
            ),
            const Gap(16),
            const TextView(
              text: AppStrings.verificationTitle,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            const Gap(8),
            const TextView(
              text: AppStrings.verificationDesc,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            if (_email != null)
              TextView(
                text: 'Code sent to ${_maskEmail(_email!)}',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.metalPinkColour,
                textAlign: TextAlign.center,
              ),
            const Gap(40),
            // OTP Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) => _buildOtpBox(index)),
            ),
            const Gap(40),
            BaseButton(
              buttonText: AppStrings.verifyCode,
              loading: verificationState.isLoading,
              onPressed: verificationState.isLoading ? null : _verifyCode,
            ),
            const Gap(24),
            if (viewModel.remainingSeconds > 0)
              TextView(
                text: '${viewModel.remainingSeconds}s remaining',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.metalGray,
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const TextView(
                    text: AppStrings.didNotReceiveCode,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  GestureDetector(
                    onTap: verificationState.isLoading ? null : _resendCode,
                    child: const TextView(
                      text: AppStrings.tapToResendOTP,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.metalPinkColour,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 45,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.metalBlack,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.metalWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.metalGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.metalGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppColors.metalPinkColour, width: 2),
          ),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          }
          // Auto-verify when all fields are filled
          if (_otpCode.length == 6) {
            _verifyCode();
          }
        },
      ),
    );
  }
}
