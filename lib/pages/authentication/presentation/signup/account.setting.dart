import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/pages/authentication/presentation/signup/verfication.dart';
import 'package:metal/pages/authentication/presentation/welcome/presentation/welcome.page.dart';
import 'package:metal/res/res.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text.field/phone.number.input.dart';
import 'package:metal/widgets/text_views.dart';

class AccountSetting extends ConsumerWidget {
  AccountSetting({Key? key}) : super(key: key);
  static const name = 'createAccount';
  static const route = '/$name';
  static final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseScreen(
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: 'Account setting',
      authFlow: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(43.h),
          TextView(
            text: '👋　Hello',
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
          ),
          TextView(
            text: 'Let’s set up your account.',
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
          ),
          TextView(
            text: 'It takes only 3 minutes!',
            fontSize: 14.sp,
            fontStyle: FontStyle.italic,
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
                  EditFormField(
                    floatingLabel: 'Password',
                    label: '**********',
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    prefixWidget: SvgPicture.asset(
                      Assets.icons.passwordIcon.path,
                      height: 24,
                      width: 24,
                    ),
                  ),
                ],
              )),
          // TextView(
          //   text:
          //       'A verification code will be sent to this number. Message and data rates may apply. Learn what happens what your number changes',
          //   fontSize: 12.sp,
          //   fontWeight: FontWeight.w400,
          //   fontStyle: FontStyle.italic,
          //   color: AppColors.metalBrownColourForText.withOpacity(0.5),
          // ),
          Gap(27.h),
          BaseButton(
            buttonText: "Continue",
            onPressed: () {
              context.pushNamed(WelcomePage.name);
              // context.pushNamed(VerificationPage.name,
              //     extra: RouteFrom.AccountSetting.name);
            },
            // enabled: _emailController.text.isNotEmpty &&
            //     _passwordController.text.isNotEmpty,
          ),
        ],
      ),
    );
  }
}
