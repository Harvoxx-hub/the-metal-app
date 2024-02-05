import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';

import 'package:metal/widgets/text_views.dart';

class CreateNewPasswordPage extends ConsumerWidget {
  CreateNewPasswordPage({Key? key}) : super(key: key);
  static const name = 'createNewPassword';
  static const route = '$name';
  static final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseScreen(
      authFlow: true,
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: 'Create New Password',
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Gap(43.h),
        TextView(
          text: '👋 Welcome Back',
          fontSize: 22.sp,
          fontWeight: FontWeight.w500,
        ),
        TextView(
          text: 'Please use a password you can remember',
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
        ),
        Gap(40.h),
        Form(
            key: _form,
            child: Column(
              children: [
                EditFormField(
                  floatingLabel: 'Create New Password',
                  label: 'Create new password',
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                ),
                Gap(22.h),
                EditFormField(
                  floatingLabel: 'Retype New Password',
                  label: 'Retype new password',
                  controller: _confirmController,
                  keyboardType: TextInputType.visiblePassword,
                ),
                Gap(32.h),
                BaseButton(
                  buttonText: 'Reset Password',
                  onPressed: () {
                    //  context.pushNamed(AccountSetting.name);
                  },
                ),
              ],
            )),
      ]),
    );
  }
}
