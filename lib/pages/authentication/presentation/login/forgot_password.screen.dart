import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/pages/authentication/presentation/login/forgot_password.otp.screen.dart';
import 'package:metal/pages/authentication/presentation/signup/account.setting.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text.field/phone.number.input.dart';
import 'package:metal/widgets/text_views.dart';

class ForgetPasswordPage extends ConsumerWidget {
  ForgetPasswordPage({Key? key}) : super(key: key);
  static const name = 'forgetPasswordPage';
  static const route = '$name';
  static final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseScreen(
      authFlow: true,
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: 'Forgot Password',
      body: Column(children: [
        Gap(52.h),
        TextView(
          text:
              'Forgetting password is common and you are not alone. Let us help you recover your password.',
          fontSize: 13,
          fontWeight: FontWeight.w300,
        ),
        Gap(52.h),
        TextView(
          text:
              'Kindly enter the phone number or email address associated with *your* account and we`ll send you instructions on how to reset your password. ',
          fontSize: 13,
          fontWeight: FontWeight.w300,
        ),
        Gap(40.h),
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
                  // validator: EmailValidator.validate(email),

                  // fillColor: AppColors.appGrey,
                ),
                Gap(22.h),
                PhoneInput(
                  phoneController: _phoneController,
                ),
                Gap(32.h),
                BaseButton(
                  buttonText: 'Send Instructions',
                  onPressed: () {
                    context.pushNamed(ForgetPasswordOTPPage.name);
                  },
                ),
              ],
            )),
      ]),
    );
  }
}
