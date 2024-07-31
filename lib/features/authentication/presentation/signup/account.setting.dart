import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/features/authentication/presentation/signup/verfication.argument.dart';
import 'package:metal/features/authentication/presentation/signup/verfication.page.dart';
import 'package:metal/features/authentication/provider/account.setting.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/res.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text.field/phone.number.input.dart';
import 'package:metal/widgets/text_views.dart';

class AccountSetting extends ConsumerStatefulWidget {
  const AccountSetting({super.key});
  static const name = 'createAccount';
  static const route = '/$name';

  @override
  ConsumerState<AccountSetting> createState() => _AccountSettingState();
}

class _AccountSettingState extends ConsumerState<AccountSetting> {
  static final GlobalKey<FormState> _form = GlobalKey<FormState>();

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

  @override
  Widget build(BuildContext context) {
    ref.listen<AccountSettingState>(accountSettingProvider, (prev, current) {
      if (current.isSuccess) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.verificationPage,
          arguments: VerificationSentArgument(
              type: RouteFrom.AccountSetting,
              code: current.data!['OTP'],
              uuid: current.data!['UUID'],
              phoneNumber: _phoneController.text,
              email: _emailController.text),
        );
      }
    });

    final accountSettingState = ref.watch(accountSettingProvider);

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
              text: '👋　Hello',
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
            const TextView(
              text: 'Let’s set up your account.',
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
            const TextView(
              text: 'It takes only 3 minutes!',
              fontSize: 14,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300,
            ),
            const Gap(40),
            Form(
              key: _form,
              child: Column(
                children: [
                  EditFormField(
                    floatingLabel: 'Email address',
                    label: 'someone@gmail.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail(),
                    prefixWidget: Assets.icons.sms.svg(height: 24),
                  ),
                  const Gap(22),
                  EditFormField(
                    floatingLabel: 'Password',
                    label: '**********',
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
                        phoneNumber = phone;
                      }),
                  const Gap(16),
                  EditFormField(
                    floatingLabel: 'Referal Code (Optional)',
                    label: 'Referal Code',
                    controller: _referController,
                    keyboardType: TextInputType.text,
                  ),
                ],
              ),
            ),
            TextView(
              text:
                  'A verification code will be sent to this number. Message and data rates may apply.',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              color: AppColors.metalBrownColourForText.withOpacity(0.5),
            ),
            const Gap(27),
            BaseButton(
                buttonText: "Continue",
                loading: accountSettingState.isLoading,
                onPressed: _validateAndSubmit),
          ],
        ),
      ),
    );
  }

  void _validateAndSubmit() {
    if (_form.currentState?.validate() ?? false) {
      // Dismiss the keyboard
      FocusScope.of(context).unfocus();
      ref.read(accountSettingProvider.notifier).signup(
            email: _emailController.text,
            password: _passwordController.text,
            phoneNumber: phoneNumber,
            referal: _referController.text,
          );
    }
  }
}
