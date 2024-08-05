import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';

import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/features/authentication/presentation/signup/verfication.argument.dart';
import 'package:metal/features/authentication/presentation/signup/verfication.page.dart';
import 'package:metal/features/authentication/provider/forget.password.notifier.dart';

import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';

import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
 
import 'package:metal/widgets/text_views.dart';

class ForgetPasswordPage extends ConsumerWidget {
  ForgetPasswordPage({super.key});
  static const name = 'forgetPasswordPage';
  static const route = name;
  static final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forgetData = ref.watch(forgetPasswordProvider);

    ref.listen<ForgetPasswordStates>(forgetPasswordProvider, (prev, current) {
      if (current.isSuccess) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.verificationPage,
          arguments: VerificationSentArgument(
              type: RouteFrom.ForgetPassword,
              code: current.data!['OTP'],
              uuid: current.data!['id'],
              email: _emailController.text),
        );
      }
    });
    return BaseScreen(
      authFlow: true,
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: 'Forgot Password',
      body: SingleChildScrollView(
        child: Column(children: [
          const Gap(52),
          const TextView(
            text:
                'Forgetting password is common and you are not alone. Let us help you recover your password.',
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
          const Gap(52),
          const TextView(
            text:
                'Kindly enter the phone number or email address associated with *your* account and we`ll send you instructions on how to reset your password. ',
            fontSize: 13,
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
                    prefixWidget: SvgPicture.asset(
                      Assets.icons.sms.path,
                      height: 24,
                      width: 24,
                    ),
                    validator: Validators.validateEmail(),
                  ),
                  const Gap(32),
                  BaseButton(
                    loading: forgetData.isLoading,
                    buttonText: 'Send Instructions',
                    onPressed: () {
                      ref
                          .read(forgetPasswordProvider.notifier)
                          .forgetPassword(email: _emailController.text);
                      //  Navigator.pushNamed(context, AppRoutes.forgetPasswordOTP);
                    },
                  ),
                ],
              )),
        ]),
      ),
    );
  }
}
