import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/res/style/text_styles.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';

class AdsCard extends StatelessWidget {
  const AdsCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 27.h),
      margin: EdgeInsets.only(bottom: 40.h, left: 20.w, right: 20.w),
      // height: 100.h,
      decoration: BoxDecoration(
          color: AppColors.metalWhite,
          borderRadius: BorderRadius.circular(13.sp),
          boxShadow: [
            BoxShadow(
              blurRadius: 3,
              color: Colors.grey.withOpacity(0.5),
            )
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            Assets.images.ads.path,
            height: 314.h,
            width: 327.w,
          ),
          const Gap(10),
          TextView(
            text: 'Don’t want to see AD’s?',
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
          Gap(6.h),
          BaseButton(
            buttonText: "Upgrade to Metal Plus",
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
