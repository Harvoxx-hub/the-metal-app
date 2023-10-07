import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../res/colors/cr_colors.dart';
import '../../res/style/text_styles.dart';

class SparksPage extends StatelessWidget {
  const SparksPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        margin: EdgeInsets.only(left: 20.w, right: 20.w),
        decoration: BoxDecoration(
            color: AppColors.metalWhite,
            borderRadius: BorderRadius.circular(13.sp)),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                height: 221.h,
                decoration: BoxDecoration(
                    color: AppColors.metalPinkColour,
                    borderRadius: BorderRadius.circular(10.sp),
                    boxShadow: [BoxShadow()]),
              ),
              Gap(15.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                alignment: Alignment.center,
                child: Text(
                  'Transaction History',
                  style: TextStyles.text(weight: FontWeight.w600),
                ),
                decoration: BoxDecoration(
                  color: AppColors.metalPinkColour.withOpacity(0.1),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MetalUserCard extends StatelessWidget {
  const MetalUserCard({
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(30),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 140.w,
              width: 140.w,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.metalBlack.withOpacity(0.1)),
            ),
          ),
          Gap(20),
          Row(
            children: [
              Text(
                '@love123_aluminium',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Gap(10.w),
              Icon(Icons.cloud_done_rounded)
            ],
          ),
          Gap(6.h),
          _buildSubItem('Gender', 'Female'),
          _buildSubItem('Age range', '25 - 30years'),
          Gap(12.h),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 7.w,
              vertical: 4.w,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.sp),
                color: AppColors.metalPinkColour60.withOpacity(0.2)),
            child: Text(
              'Ready to Melt with Father figure',
              style: TextStyles.text(weight: FontWeight.w500),
            ),
          ),
          Gap(15.h),
          Text(
            'Interests: Travelling, Photography etc',
            style: TextStyles.text(fontStyle: FontStyle.italic),
          ),
          Gap(15.h),
          Padding(
            padding: EdgeInsets.only(right: 15.w),
            child: Divider(thickness: 1.5),
          ),
          Gap(8.h),
          Text(
            'I term myself an Aluminium because I am light and emotional. I like to be cared for as I have some tendencies to get rusty. It would be great to connect with you! Let’s melt!',
            style: TextStyles.text(),
          ),
          Gap(30.h),
          Row(
            children: [],
          )
        ],
      ),
    );
  }

  Text _buildSubItem(String key, String value) {
    return Text.rich(
        TextSpan(style: TextStyle(fontSize: 15.sp), text: '$key: ', children: [
      TextSpan(
        text: value,
        style: TextStyle(fontWeight: FontWeight.w500),
      )
    ]));
  }
}
