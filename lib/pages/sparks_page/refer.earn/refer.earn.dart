import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/pages/sparks_page/send.spark/widget/send.card.dart';
import 'package:metal/pages/sparks_page/widget/single.spark.card.dart';
import 'package:metal/pages/sparks_page/widget/spark.card.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/utils/screen.size.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/button/outiline.button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text.field/phone.number.input.dart';
import 'package:metal/widgets/text_views.dart';

class ReferEarnSpark extends StatelessWidget {
  ReferEarnSpark({super.key});
  static const name = 'referEarnSpark';
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
                        SingleSparkCard(
                          title: "Refer \n& Earn",
                          path: Assets.images.buySpark.path,
                        ),
                        Gap(15),
                        PhoneInput(
                          phoneController: _phoneController,
                        ),
                        Gap(getDeviceHeight(context) * 0.2),
                        BaseButton(
                          buttonText: "Invite to Metal",
                          onPressed: () {},
                        ),
                        Gap(16.h),
                        OutilineButton(
                          buttonText: "Copy invite Link ",
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
