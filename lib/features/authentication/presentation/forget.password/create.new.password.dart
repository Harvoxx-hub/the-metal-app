import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/features/authentication/provider/change.password.notifier.dart';

import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';

import 'package:metal/widgets/text_views.dart';

class CreateNewPasswordPage extends ConsumerWidget {
  CreateNewPasswordPage({required this.userid, super.key});
  static const name = 'createNewPassword';
  static const route = name;
  final String userid;
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changePassword = ref.watch(changePasswordProvider);
    ref.listen<ChangePasswordStates>(changePasswordProvider, (prev, current) {
      if (current.isSuccess) {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.login,
        );
      }
    });
    return BaseScreen(
      authFlow: true,
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      // header: 'Create New Password',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(43),
            const TextView(
              text: '👋 Welcome Back',
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
            const TextView(
              text: 'Please use a password you can remember',
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            Gap(40),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  EditFormField(
                    floatingLabel: 'Create New Password',
                    label: 'Create new password',
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    validator: Validators.validatePlainPassword(),
                    prefixWidget: Assets.icons.passwordIcon.svg(height: 24),
                  ),
                  Gap(22),
                  EditFormField(
                    floatingLabel: 'Retype New Password',
                    label: 'Retype new password',
                    controller: _confirmController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please retype your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    prefixWidget: Assets.icons.passwordIcon.svg(height: 24),
                  ),
                  Gap(32),
                  BaseButton(
                    loading: changePassword.isLoading,
                    buttonText: 'Reset Password',
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        ref
                            .read(changePasswordProvider.notifier)
                            .changePassword(
                              id: userid,
                              password: _passwordController.text,
                            );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
