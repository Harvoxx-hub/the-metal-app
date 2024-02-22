import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
 
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/res/colors/cr_colors.dart';
 
import 'package:metal/widgets/text_views.dart';

class SingleSparkHeaderCard extends ConsumerWidget {
  const SingleSparkHeaderCard(
      {super.key, required this.title, required this.path});
  final String title;
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(authProvider);

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
          TextView(
            text: "Sparks Balance ✨",
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.metalWhite,
          ),
          TextView(
            text:  userData.data!.sparkBalance.toString(),
            fontSize: 40.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.metalWhite,
          ),
          Gap(16.h),
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
          )
        ],
      ),
    );
  }
}
