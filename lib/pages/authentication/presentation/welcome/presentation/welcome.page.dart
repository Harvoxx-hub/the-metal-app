import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/pages/authentication/presentation/profile.setting/create.profile.dart';
import 'package:metal/utils/screen.size.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text_views.dart';

class WelcomePage extends ConsumerWidget {
  WelcomePage({Key? key}) : super(key: key);
  static const name = 'welcomePage';
  static const route = '$name';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseScreen(
        appBarEnabled: false,
        bgImage: Assets.images.bg2.path,
        authFlow: true,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Gap(49.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextView(
                  text: 'Welcome to Metal',
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
                Image.asset(
                  Assets.images.logo.path,
                  height: 27.h,
                  width: 23.w,
                )
              ],
            ),
            Gap(8.h),
            TextView(
              text: 'Please follow our house rules',
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
            Gap(40.h),
            welcomeItem(context, 'Be true to yourself',
                'Ensure that your pictures, age, and every information you put here is true to who you are. '),
            welcomeItem(context, 'Respect is reciprocal',
                'Have regards for each other during conversations as you would love to be treated well.'),
            welcomeItem(context, 'Prioritize your safety',
                ' - Don’t be so quick to share out your personal information. \n\n - Book your first date in an open space. \n\n - Do not hesitate to report bad behaviour. Be proactive'),
            Gap(40.h),
            BaseButton(
                buttonText: 'I understand',
                onPressed: () {
                  context.pushNamed(CreateProfilePage.name);
                })
          ],
        ));
  }

  Widget welcomeItem(BuildContext context, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(20.w),
          SvgPicture.asset(
            Assets.icons.welcomeItem.path,
            height: 20.h,
            width: 20.w,
          ),
          Gap(10.w),
          SizedBox(
            width: getDeviceWidth(context) * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                  text: title,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
                Gap(6.h),
                TextView(
                  text: subtitle,
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
