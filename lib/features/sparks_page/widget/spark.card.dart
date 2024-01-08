import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/sparks_page/buy.spark/buy.spark.dart';
import 'package:metal/features/sparks_page/refer.earn/refer.earn.dart';
import 'package:metal/features/sparks_page/send.spark/send.spark.dart';
import 'package:metal/features/sparks_page/widget/spark.card.item.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

class SparkCard extends StatelessWidget {
  const SparkCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 229.h,
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
          color: AppColors.metalPinkColour,
          borderRadius: BorderRadius.circular(10.sp),
          boxShadow: [BoxShadow()]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextView(
            text: "Sparks Balance ✨",
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.metalWhite,
          ),
          TextView(
            text: "10,240",
            fontSize: 40.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.metalWhite,
          ),
          Gap(16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SparkCardItem(
                title: "Send Sparks",
                path: Assets.images.sendSpark.path,
                onTap: () => context.pushNamed(SendSpark.name),
              ),
              SparkCardItem(
                  title: "Buy Sparks",
                  onTap: () => context.pushNamed(BuySpark.name),
                  path: Assets.images.buySpark.path),
              SparkCardItem(
                  title: "Refer & Earn",
                  onTap: () => context.pushNamed(ReferEarnSpark.name),
                  path: Assets.images.refer.path),
            ],
          )
        ],
      ),
    );
  }
}
