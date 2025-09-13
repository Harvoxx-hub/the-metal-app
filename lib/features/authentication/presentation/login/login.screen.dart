import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/core/utils/strings/app_strings.dart';
import 'package:metal/features/authentication/presentation/signup/verfication.argument.dart';
import 'package:metal/features/authentication/presentation/signup/verfication.page.dart';
import 'package:metal/features/authentication/provider/login.notifier.dart';

import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/res.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/agree.click.dart';

import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';

import 'package:metal/widgets/text_views.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  static const name = 'login';
  static const route = '/$name';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
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
      ref.read(loginProvider.notifier).login(
            email: _emailController.text,
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Build was called...');
    ref.listen<LoginStates>(loginProvider, (prev, current) {
      debugPrint('Login state changed: $current');
      if (current.isSuccess) {
        debugPrint('Login success. Proceeding to next page.');
        !(current.data!.emailVerified ?? false)
            ? Navigator.pushReplacementNamed(
                context,
                AppRoutes.verificationPage,
                arguments: VerificationSentArgument(
                    type: RouteFrom.AccountSetting,
                    uuid: current.data?.id ?? "",
                    email: current.data!.email!),
              )
            : Navigator.pushReplacementNamed(
                context,
                current.data?.profileUpdated ?? false
                    ? AppRoutes.dashboardPage
                    : AppRoutes.welcomePage,
              );
      }
      debugPrint('Navigating to the last');
    });

    final loginState = ref.watch(loginProvider);

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
                      print('Value changed to $value');
                    },
                  ),
                  const Gap(64),
                ],
              ),
            ),
            BaseButton(
              buttonText: AppStrings.login,
              loading: loginState.isLoading,
              onPressed: _validateAndSubmit,
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
