import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text.field/phone.number.input.dart';
import 'package:metal/widgets/text_views.dart';

class NewPhoneNumberPage extends StatelessWidget {
  NewPhoneNumberPage({super.key});
  static const name = 'newPhoneNumberPage';
  static const route = '$name';
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBarState: AppBarState.BackWithHeader,
      Header: "Update phone number",
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 220.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment(0.00, -1.00),
                        end: Alignment(0, 1),
                        colors: [Color(0xFFDB217A), Color(0xFFF00E3E)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(35.sp),
                        bottomRight: Radius.circular(35.sp),
                      )),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 24.0, right: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 29, left: 9, right: 9),
              child: Container(
                padding: const EdgeInsets.only(top: 55, left: 22, right: 22),
                decoration: const BoxDecoration(
                    color: AppColors.metalWhite,
                    borderRadius: BorderRadius.all(
                      Radius.circular(35),
                    )),
                child: Column(
                  children: [
                    SvgPicture.asset(
                      Assets.icons.iconlyLightProfile.path,
                      height: 50,
                      width: 50,
                    ),
                    Gap(22.h),
                    TextView(
                      text: "Email address verified",
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                    Gap(5.h),
                    TextView(
                      text:
                          "Please input the *new phone number* you are migrating to",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      textAlign: TextAlign.center,
                    ),
                    Gap(35.h),
                    PhoneInput(
                      floatingLabel: "New Phone number",
                      phoneController: _phoneController,
                    ),
                    Gap(45.h),
                    BaseButton(
                      buttonText: "Update  phone number",
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialog(
                              content: phoneUpdatedDialog(context),
                            );
                          },
                        );
                        //   context.pushNamed(DashboardPage.name);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget phoneUpdatedDialog(BuildContext context) {
    return Column(
      children: [
        Gap(38.h),
        SvgPicture.asset(
          Assets.icons.profilePhone.path,
          height: 50,
          width: 50,
        ),
        Gap(15.h),
        TextView(
          text: "Phone number updated",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        Gap(15.h),
        TextView(
          text: "Your phone number has been updated successfully",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        Gap(38.h),
        BaseButton(
            buttonText: "OK. Got it! ",
            onPressed: () {
              context.pop();
            }),
        Gap(21.h),
      ],
    );
  }
}
