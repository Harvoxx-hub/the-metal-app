import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/sparks_page/send.spark/widget/send.card.dart';
import 'package:metal/features/sparks_page/widget/spark.card.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

class SendSpark extends StatelessWidget {
  SendSpark({super.key});
  static const name = 'sendSpark';
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
        Header: "Send Spark",
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
                        const SendSparkCard(),
                        Gap(15),
                        EditFormField(
                          floatingLabel: 'I want to send Sparks to',
                          label: 'Type name of recipient',
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
                          floatingLabel: 'Number of Sparks to send',
                          label: 'Number of sparks to send',
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
                        EditFormField(
                          floatingLabel: 'I want to send Sparks to',
                          label: '0.00',
                          controller: _transferFeeController,
                          keyboardType: TextInputType.number,
                          prefixWidget: SvgPicture.asset(
                            Assets.icons.star05.path,
                            height: 24,
                            width: 24,
                          ),
                          radius: 10,
                        ),
                        Gap(15),
                        EditFormField(
                          floatingLabel: 'Total Sparks used ',
                          label: '0.00',
                          controller: _TotalSparkController,
                          keyboardType: TextInputType.number,
                          prefixWidget: SvgPicture.asset(
                            Assets.icons.star05.path,
                            height: 24,
                            width: 24,
                          ),
                          radius: 10,
                        ),
                        Gap(15),
                        BaseButton(
                          buttonText: "Send spark",
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
          text: "Confirm you want to send *22 Sparks* to *@sarah_aluminium*",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        Gap(38.h),
        BaseButton(
            buttonText: "Confirm",
            onPressed: () {
              confirm(context);
            }),
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

  Widget successDialog(BuildContext context) {
    return Column(
      children: [
        Gap(38.h),
        Image.asset(Assets.images.partpoppercelebrationemoji.path),
        Gap(15.h),
        TextView(
          text: "Success",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        Gap(15.h),
        TextView(
          text: "*20 sparks* successfully sent to *@sarah_aluminium*",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        Gap(58.h),
        BaseButton(
            buttonText: "Go back to dashboard",
            onPressed: () {
              context.pop();
              context.pop();
            })
      ],
    );
  }

  void confirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          content: successDialog(context),
        );
      },
    );
  }
}
