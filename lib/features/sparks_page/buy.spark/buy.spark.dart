import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/sparks_page/send.spark/widget/send.card.dart';
import 'package:metal/features/sparks_page/widget/single.spark.card.dart';
import 'package:metal/features/sparks_page/widget/spark.card.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

class BuySpark extends StatelessWidget {
  BuySpark({super.key});
  static const name = 'buySpark';
  static const route = '$name';
  static final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final TextEditingController _sendSparkController = TextEditingController();
  final TextEditingController _sparkNumberController = TextEditingController();
  final TextEditingController _transferFeeController = TextEditingController();
  final TextEditingController _TotalSparkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        appBarState: AppBarState.BackWithHeader,
        Header: "Buy Spark",
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
                          title: "Buy \n Sparks",
                          path: Assets.images.buySpark.path,
                        ),
                        Gap(15),
                        EditFormField(
                          floatingLabel: 'Number of sparks to buy',
                          label: 'Type number of sparks to buy',
                          controller: _sendSparkController,
                          keyboardType: TextInputType.name,

                          prefixWidget: SvgPicture.asset(
                            Assets.icons.iconlyLightProfile.path,
                            height: 24,
                            width: 24,
                          ),
                          // validator: EmailValidator.validate(email),
                          radius: 10,
                        ),
                        Gap(15),
                        EditFormField(
                          floatingLabel: 'Dollar equivalence',
                          label: 'Dollar equivalence',
                          controller: _sparkNumberController,
                          keyboardType: TextInputType.name,
                          prefixWidget: SvgPicture.asset(
                            Assets.icons.star05.path,
                            height: 24,
                            width: 24,
                          ),
                          radius: 10,
                        ),
                        Gap(15),
                        BaseButton(
                          buttonText: "Buy",
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomDialog(
                                  content: confirmationDialog(context),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ));
  }

  Widget confirmationDialog(BuildContext context) {
    return Column(
      children: [
        Gap(38.h),
        Image.asset(Assets.images.eyesEmoji.path),
        Gap(15.h),
        TextView(
          text: "Confirmation",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        Gap(15.h),
        TextView(
          text:
              "Confirm you want to buy *200 sparks* with Dollar equivalence of *500*",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        Gap(38.h),
        BaseButton(buttonText: "Confirm", onPressed: () {}),
        Gap(23.h),
        TextView(
          text: "Not Now",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          onTap: () => context.pop(),
        ),
        Gap(21.h),
      ],
    );
  }
}
