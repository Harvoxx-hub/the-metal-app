import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/text_views.dart';

class ForgetPasswordPage extends ConsumerWidget {
  ForgetPasswordPage({Key? key}) : super(key: key);
  static const name = 'forgetPasswordPage';
  static const route = '$name';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseScreen(
      authFlow: true,
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: 'Forgot Password',
      body: Column(children: [
        Gap(52.h),
        TextView(text: 'Forgetting password is common and you are not alone. Let us help you recover your password.', fontSize: 13, fontWeight: FontWeight.w300, ),

        Gap(52.h),
        TextView(text: 'Kindly enter the phone number or email address associated with *your* account and we`ll send you instructions on how to reset your password. ',   fontSize: 13, fontWeight: FontWeight.w300, ),
      ]),
    );
  }
}
