import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/features/home_page/domain/entries/all.user.model.dart';
import 'package:metal/features/home_page/provider/melt.user.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/home_page/melt.metal.dart';
import 'package:metal/features/home_page/push.metal.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/res/style/text_styles.dart';
import 'package:metal/widgets/text_views.dart';

class MetalUserCard extends ConsumerWidget {
  const MetalUserCard({
    super.key,
    required this.user,
  });
  final ALLUserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          const Gap(30),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 140.w,
              width: 140.w,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.metalBlack.withOpacity(0.1)),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(70.w),
                  child: Image.network(
                    user.metal!.img!,
                    fit: BoxFit.cover,
                  )),
            ),
          ),
          const Gap(20),
          Row(
            children: [
              TextView(
                text: '@${user.username}',
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
              Gap(10.w),
              user.verfied
                  ? SvgPicture.asset(
                      Assets.icons.checkVerified.path,
                      height: 24,
                      width: 24,
                    )
                  : const SizedBox.shrink(),
              SvgPicture.asset(
                Assets.icons.checkVerified.path,
                height: 24,
                width: 24,
              ),
            ],
          ),
          Gap(6.h),
          _buildSubItem('Gender', user.gender!),
          _buildSubItem('Age range', user.age_range ?? ""),
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
              'Ready to Melt with  ${user.connection_option!.join(', ')}',
              style: TextStyles.text(weight: FontWeight.w500),
            ),
          ),
          Gap(15.h),
          Text(
            'Interests: ${user.passion!.join(', ')}',
            style: TextStyles.text(fontStyle: FontStyle.italic),
          ),
          Gap(15.h),
          Padding(
            padding: EdgeInsets.only(right: 15.w),
            child: const Divider(thickness: 1.5),
          ),
          Gap(8.h),
          Text(
            user.description!,
            style: TextStyles.text(),
          ),
          Gap(30.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  context.pushNamed(MeltMetal.name, extra: user);
                },
                child: Image.asset(Assets.images.melt.path),
              ),
              GestureDetector(
                onTap: () {},
                child: Image.asset(Assets.images.like.path),
              ),
              GestureDetector(
                onTap: () {
                  context.pushNamed(PushMetal.name);
                },
                child: Image.asset(Assets.images.push.path),
              )
            ],
          )
        ],
      ),
    );
  }

  Text _buildSubItem(String key, String value) {
    return Text.rich(TextSpan(
        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w300),
        text: '$key: ',
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          )
        ]));
  }
}
