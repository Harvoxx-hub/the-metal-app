import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/core/utils/strings/app_strings.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/auth/forgot_password_viewmodel.dart';
import 'package:metal/res/res.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

/// Forgot password view - handles all 3 steps
class ForgotPasswordView extends ConsumerStatefulWidget {
  const ForgotPasswordView({super.key});

  static const String name = 'forgot-password';
  static const String route = '/forgot-password';

  @override
  ConsumerState<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends ConsumerState<ForgotPasswordView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  final _formKey = GlobalKey<FormState>();

  String _verifiedCode = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var n in _otpFocusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  void _sendOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      ref
          .read(forgotPasswordViewModelProvider.notifier)
          .sendOtp(_emailController.text.trim());
    }
  }

  void _verifyOtp() {
    final code = _otpCode;
    if (code.length != 6) {
      Fluttertoast.showToast(msg: 'Please enter 6-digit code');
      return;
    }
    FocusScope.of(context).unfocus();
    _verifiedCode = code;
    ref.read(forgotPasswordViewModelProvider.notifier).verifyOtp(code);
  }

  void _resetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_passwordController.text != _confirmPasswordController.text) {
        Fluttertoast.showToast(msg: 'Passwords do not match');
        return;
      }
      FocusScope.of(context).unfocus();
      ref
          .read(forgotPasswordViewModelProvider.notifier)
          .resetPassword(_verifiedCode, _passwordController.text);
    }
  }

  void _resendOtp() {
    ref.read(forgotPasswordViewModelProvider.notifier).resendOtp();
  }

  void _handleBack() {
    final viewModel = ref.read(forgotPasswordViewModelProvider.notifier);
    if (viewModel.currentStep == ForgotPasswordStep.email) {
      Navigator.pop(context);
    } else {
      viewModel.goBack();
      // Clear OTP fields when going back
      for (var c in _otpControllers) {
        c.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordViewModelProvider);
    final viewModel = ref.read(forgotPasswordViewModelProvider.notifier);

    // Listen for state changes
    ref.listen(forgotPasswordViewModelProvider, (previous, current) {
      if (current.isSuccess && current.action?['type'] == 'password_reset') {
        Fluttertoast.showToast(msg: 'Password reset successful!');
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    });

    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: BaseScreen(
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        Header: AppStrings.forgotPasswordTitle,
        authFlow: true,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: _buildCurrentStep(state, viewModel),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(
      BaseState<void> state, ForgotPasswordViewModel viewModel) {
    switch (viewModel.currentStep) {
      case ForgotPasswordStep.email:
        return _buildEmailStep(state);
      case ForgotPasswordStep.otp:
        return _buildOtpStep(state, viewModel);
      case ForgotPasswordStep.newPassword:
        return _buildPasswordStep(state);
    }
  }

  Widget _buildEmailStep(BaseState<void> state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Gap(40),
        const TextView(
          text: '🔐',
          fontSize: 48,
        ),
        const Gap(16),
        const TextView(
          text: AppStrings.forgotPasswordTitle,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        const Gap(8),
        const TextView(
          text: AppStrings.forgotPasswordDesc,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          textAlign: TextAlign.center,
        ),
        const Gap(40),
        EditFormField(
          floatingLabel: AppStrings.emailAddress,
          label: AppStrings.enterEmailAddress,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixWidget: Assets.icons.sms.svg(height: 24),
          validator: Validators.validateEmail(),
        ),
        const Gap(40),
        BaseButton(
          buttonText: AppStrings.sendInstructions,
          loading: state.isLoading,
          onPressed: state.isLoading ? null : _sendOtp,
        ),
        const Gap(24),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const TextView(
            text: 'Back to Login',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.metalPinkColour,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpStep(BaseState<void> state, ForgotPasswordViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Gap(40),
        const TextView(
          text: AppStrings.verificationEmoji,
          fontSize: 48,
        ),
        const Gap(16),
        const TextView(
          text: 'Verify Your Email',
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        const Gap(8),
        TextView(
          text: 'Enter the 6-digit code sent to\n${viewModel.email}',
          fontSize: 14,
          fontWeight: FontWeight.w400,
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
          buttonText: 'Verify Code',
          loading: state.isLoading,
          onPressed: state.isLoading ? null : _verifyOtp,
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
          GestureDetector(
            onTap: state.isLoading ? null : _resendOtp,
            child: const TextView(
              text: 'Resend Code',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.metalPinkColour,
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordStep(BaseState<void> state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Gap(40),
        const TextView(
          text: '🔒',
          fontSize: 48,
        ),
        const Gap(16),
        const TextView(
          text: AppStrings.createNewPasswordTitle,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        const Gap(8),
        const TextView(
          text: AppStrings.useRememberablePassword,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          textAlign: TextAlign.center,
        ),
        const Gap(40),
        EditFormField(
          floatingLabel: 'New Password',
          label: AppStrings.passwordPlaceholder,
          controller: _passwordController,
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
          prefixWidget: Assets.icons.passwordIcon.svg(height: 24),
          validator: Validators.validatePlainPassword(),
        ),
        const Gap(16),
        EditFormField(
          floatingLabel: 'Confirm Password',
          label: AppStrings.passwordPlaceholder,
          controller: _confirmPasswordController,
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
          prefixWidget: Assets.icons.passwordIcon.svg(height: 24),
          validator: Validators.validatePlainPassword(),
        ),
        const Gap(40),
        BaseButton(
          buttonText: AppStrings.resetPassword,
          loading: state.isLoading,
          onPressed: state.isLoading ? null : _resetPassword,
        ),
      ],
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 45,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
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
            _otpFocusNodes[index + 1].requestFocus();
          }
          // Auto-verify when all fields filled
          if (_otpCode.length == 6) {
            _verifyOtp();
          }
        },
      ),
    );
  }
}

