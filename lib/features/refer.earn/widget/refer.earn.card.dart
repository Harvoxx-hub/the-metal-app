import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/sparks_page/send.spark/send.spark.dart';
import 'package:metal/features/sparks_page/widget/spark.card.item.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

class ReferEarnCard extends StatelessWidget {
  const ReferEarnCard({super.key, required this.title, required this.path});
  final String title;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
          color: AppColors.metalPinkColour,
          borderRadius: BorderRadius.circular(10.sp),
          boxShadow: [BoxShadow()]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                children: [
                  Image.asset(path),
                  TextView(
                    text: title,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.metalWhite,
                  )
                ],
              ),
            ],
          ),
          TextView(
            text: "Sparks Balance from Referrals✨",
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.metalWhite,
          ),
          TextView(
            text: "0.00",
            fontSize: 40.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.metalWhite,
          ),
          Gap(16.h),
        ],
      ),
    );
  }
}
