import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';

class AdsCard extends StatelessWidget {
  const AdsCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 27),
      margin: EdgeInsets.only(bottom: 40, left: 20.w, right: 20.w),
      // height: 100 ,
      decoration: BoxDecoration(
          color: AppColors.metalWhite,
          borderRadius: BorderRadius.circular(13),
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
            height: 314,
            width: 327.w,
          ),
          const Gap(10),
          const TextView(
            text: 'Don’t want to see AD’s?',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          const Gap(6),
          BaseButton(
            buttonText: "Upgrade to Metal Plus",
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
