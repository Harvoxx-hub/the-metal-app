import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/core/utils/strings/app_strings.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/auth/login_viewmodel.dart';
import 'package:metal/presentation/viewmodels/profile/profile_viewmodel_providers.dart';
import 'package:metal/res/res.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

/// Login view using Clean Architecture
/// This view uses the new API-based authentication flow
class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});
  static const name = 'login_api';
  static const route = '/$name';

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Dismiss the keyboard
      FocusScope.of(context).unfocus();
      ref.read(loginViewModelProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  void _handleLoginSuccess(LoginResponseDto? loginResponse) async {
    if (loginResponse == null) return;

    final user = loginResponse.user;

    // Fetch user profile to maintain state throughout the app
    await ref.read(profileViewModelProvider.notifier).fetchUserProfile();

    // Navigate based on user state
    if (user.emailVerified == false) {
      // User needs email verification - just pass email
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.verificationPage,
        arguments: user.email,
      );
    } else {
      // User is verified, go to dashboard or welcome based on profile completion
      Navigator.pushReplacementNamed(
        context,
        user.profileUpdated == true
            ? AppRoutes.dashboardPage
            : AppRoutes.welcomePage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewModelProvider);

    // Listen to state changes for navigation
    ref.listen(
      loginViewModelProvider,
      (previous, current) {
        if (current.isSuccess) {
          _handleLoginSuccess(current.data);
        } else if (current.isError) {
          // Error is already handled by BaseState (shows toast)
          // You can add additional error handling here if needed
          debugPrint('Login error: ${current.errorMessage}');
        }
      },
    );

    return BaseScreen(
      authFlow: true,
      Header: "Login",
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Gap(52),
            Image.asset(
              Assets.images.logo.path,
              height: 53,
              width: 53,
            ),
            const Gap(22),
            const TextView(
              text: AppStrings.welcomeBack,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
            const Gap(8),
            const TextView(
              text: AppStrings.loginDesc,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            const Gap(52),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EditFormField(
                    floatingLabel: AppStrings.emailAddress,
                    label: AppStrings.enterEmailAddress,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixWidget: Assets.icons.sms.svg(height: 24),
                    validator: Validators.validateEmail(),
                  ),
                  const Gap(16),
                  EditFormField(
                    floatingLabel: AppStrings.password,
                    label: AppStrings.passwordPlaceholder,
                    obscureText: true,
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    prefixWidget: Assets.icons.passwordIcon.svg(height: 24),
                    validator: Validators.validatePlainPassword(),
                  ),
                  const Gap(16),
                  CustomCheckWidget(
                    title: AppStrings.keepLoggedIn,
                    initialValue: false,
                    onChanged: (bool value) {
                      // Handle keep logged in preference
                      debugPrint('Keep logged in: $value');
                    },
                  ),
                  const Gap(64),
                ],
              ),
            ),
            BaseButton(
              buttonText: AppStrings.login,
              loading: loginState.isLoading,
              onPressed: loginState.isLoading ? null : _validateAndSubmit,
            ),
            const Gap(31),
            TextView(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.forgetPassword);
              },
              text: AppStrings.forgotPassword,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            const Gap(14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TextView(
                  text: AppStrings.notAUser,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.metaltext,
                ),
                TextView(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.accountSetting);
                  },
                  text: "  ${AppStrings.createAccount}",
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
