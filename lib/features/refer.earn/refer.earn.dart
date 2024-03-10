import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/core/utils/screen.size.dart';
import 'package:metal/features/sparks_page/screens/refer.earn/refer.earn.dart';
import 'package:metal/features/sparks_page/screens/widget/single.spark.header.card.dart';
import 'package:metal/gen/assets.gen.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';

import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/button/outiline.button.dart';

import 'package:metal/widgets/text_views.dart';

class ReferEarn extends StatelessWidget {
  ReferEarn({super.key});
  static const name = 'referEarn';
  static const route = '$name';
  static final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        appBarState: AppBarState.BackWithHeader,
        Header: "Refer & Earn",
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 220.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: AppColors.metalPinkColour,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(35.sp),
                          bottomRight: Radius.circular(35.sp),
                        )),
                  ),

                  // This container is for the background image decoration
                  Container()
                ],
              ),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.w),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                    margin: EdgeInsets.only(left: 10.w, right: 10.w),
                    decoration: BoxDecoration(
                        color: AppColors.metalWhite,
                        borderRadius: BorderRadius.circular(13.sp)),
                    child: Column(
                      children: [
                        SingleSparkHeaderCard(
                          title: "Refer \n& Earn",
                          path: Assets.images.refer.path,
                        ),
                        Gap(56),
                        SizedBox(
                          width: 218,
                          child: TextView(
                              textAlign: TextAlign.center,
                              text:
                                  "You’re doing great! Your counts are increasing. Invite more friends to earn more sparks with Metal."),
                        ),
                        Gap(29),
                        Container(
                          width: 200,
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: AppColors.metalTabBg,
                              borderRadius: BorderRadius.circular(5)),
                          child: Column(
                            children: [
                              TextView(
                                text: "Referral count",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              Gap(8),
                              TextView(
                                text: "21",
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              )
                            ],
                          ),
                        ),
                        Gap(getDeviceHeight(context) * 0.1),
                        BaseButton(
                          buttonText: "Refer friends",
                          onPressed: () {
                            Navigator.pushNamed(
                                context, AppRoutes.referEarnSpark);
                          },
                        ),
                        Gap(16.h),
                        OutilineButton(
                          buttonText: "View last 30 days",
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ));
  }
}
