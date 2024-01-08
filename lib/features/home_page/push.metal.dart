import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/home_page/melt.metal.dart';
import 'package:metal/features/sparks_page/refer.earn/refer.earn.dart';
import 'package:metal/features/upgrade/make.payment.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/core/utils/utils/screen.size.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/button/outiline.button.dart';
import 'package:metal/widgets/text_views.dart';

class PushMetal extends StatelessWidget {
  const PushMetal({super.key});
  static const name = 'pushMetal';
  static const route = '$name';

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        appBarState: AppBarState.BackWithHeader,
        Header: "Push profile",
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
                        Gap(28),
                        Image.asset(Assets.images.pushMelt.path),
                        Gap(20),
                        TextView(
                          textAlign: TextAlign.center,
                          text: "Push my profile to \n @love123_aluminium",
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        Gap(16),
                        SizedBox(
                          width: 288.w,
                          child: TextView(
                            text:
                                "Pushing would get your profile noticed by @abel_cobalt. You will be ranked top in her dashboard view, which indicates that you are ready to melt!",
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Gap(19),
                        TextView(
                          text:
                              "Push is a paid feature and it is \nfor a specific metal per time",
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          textAlign: TextAlign.center,
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
                                text: "Price per push",
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              Gap(8),
                              TextView(
                                text: "2.00",
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w800,
                              )
                            ],
                          ),
                        ),
                        Gap(getDeviceHeight(context) * 0.1),
                        BaseButton(
                          buttonText: "Pay to Push",
                          onPressed: () {
                            context.pushNamed(MakePayment.name);
                          },
                        ),
                        Gap(16.h),
                        OutilineButton(
                          buttonText: "Melt for free",
                          onPressed: () {
                            context.pushNamed(MeltMetal.name);
                          },
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ));
  }
}
