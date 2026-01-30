import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/core/utils/strings/app_strings.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/auth/signup_viewmodel.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/res/res.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text.field/phone.number.input.dart';
import 'package:metal/widgets/text_views.dart';

/// Signup view using Clean Architecture
/// This view uses the new API-based authentication flow
class SignupView extends ConsumerStatefulWidget {
  const SignupView({super.key});
  static const name = 'signup';
  static const route = '/$name';

  @override
  ConsumerState<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends ConsumerState<SignupView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _referController = TextEditingController();
  String phoneNumber = "";

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _referController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Dismiss the keyboard
      FocusScope.of(context).unfocus();
      ref.read(signupViewModelProvider.notifier).signup(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            phoneNumber: phoneNumber,
            referralCode: _referController.text.trim().isEmpty
                ? null
                : _referController.text.trim(),
          );
    }
  }

  void _handleSignupSuccess(LoginResponseDto? signupResponse) async {
    if (signupResponse == null) return;

    final user = signupResponse.user;

    // Set user in global state
    ref.read(userStateProvider.notifier).setUser(user);

    // Navigate to verification page - just pass email
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.verificationPage,
        arguments: user.email,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupViewModelProvider);

    // Listen to state changes for navigation
    ref.listen(
      signupViewModelProvider,
      (previous, current) {
        if (current.isSuccess) {
          _handleSignupSuccess(current.data);
        } else if (current.isError) {
          // Error is already handled by BaseState (shows toast)
          debugPrint('Signup error: ${current.errorMessage}');
        }
      },
    );

    return BaseScreen(
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: 'Account setting',
      authFlow: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(43),
            const TextView(
              text: AppStrings.helloEmoji,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
            const TextView(
              text: AppStrings.setupAccount,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
            const TextView(
              text: AppStrings.setupTimeShort,
              fontSize: 14,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300,
            ),
            const Gap(40),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  EditFormField(
                    floatingLabel: AppStrings.emailAddress,
                    label: AppStrings.emailPlaceholder,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail(),
                    prefixWidget: Assets.icons.sms.svg(height: 24),
                  ),
                  const Gap(22),
                  EditFormField(
                    floatingLabel: AppStrings.password,
                    label: AppStrings.passwordPlaceholder,
                    obscureText: true,
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    validator: Validators.validatePlainPassword(),
                    prefixWidget: Assets.icons.passwordIcon.svg(height: 24),
                  ),
                  const Gap(16),
                  PhoneInput(
                    phoneController: _phoneController,
                    onPhoneNumberChanged: (phone) {
                      setState(() {
                        phoneNumber = phone;
                      });
                    },
                    validator: (phone) {
                      if (phone == null || phone.completeNumber.isEmpty) {
                        return 'Please enter a valid phone number';
                      }
                      // Validate that the phone number has at least 10 digits (country code + number)
                      final digitsOnly = phone.completeNumber.replaceAll(RegExp(r'[^\d]'), '');
                      if (digitsOnly.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const Gap(16),
                  EditFormField(
                    floatingLabel: AppStrings.referalCode,
                    label: AppStrings.referalCodePlaceholder,
                    controller: _referController,
                    keyboardType: TextInputType.text,
                  ),
                ],
              ),
            ),
            TextView(
              text: AppStrings.verificationNotice,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              color: AppColors.metalBrownColourForText.withOpacity(0.5),
            ),
            const Gap(27),
            BaseButton(
              buttonText: AppStrings.continueText,
              loading: signupState.isLoading,
              onPressed: signupState.isLoading ? null : _validateAndSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
