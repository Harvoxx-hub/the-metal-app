import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/authentication/presentation/signup/verfication.page.dart';
import 'package:metal/features/profile/update.email/new.email.page.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text.field/phone.number.input.dart';
import 'package:metal/widgets/text_views.dart';

class UpdateEmailPage extends StatelessWidget {
  UpdateEmailPage({super.key});
  static const name = 'updateEmailPage';
  static const route = '$name';
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBarState: AppBarState.BackWithHeader,
      Header: "Update email address",
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
                      Assets.icons.profileMail01.path,
                      height: 50,
                      width: 50,
                    ),
                    Gap(22.h),
                    TextView(
                      text: "Update your email?",
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                    Gap(5.h),
                    TextView(
                      text:
                          "To update your email address please input your Metal password. A verification code will be sent to your phone number",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      textAlign: TextAlign.center,
                    ),
                    Gap(35.h),
                    PhoneInput(
                      floatingLabel: "Phone number",
                      phoneController: _phoneController,
                    ),
                    Gap(22.h),
                    EditFormField(
                      floatingLabel: 'Current Password',
                      label: 'Type your Metal password',
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      prefixWidget: SvgPicture.asset(
                        Assets.icons.passwordIcon.path,
                        height: 24,
                        width: 24,
                      ),
                      radius: 10,
                    ),
                    Gap(45.h),
                    BaseButton(
                      buttonText: "Confirm password",
                      onPressed: () {
                                          Navigator.pushNamed(context, AppRoutes.verificationPage,
                                          arguments: RouteFrom.UpdateEmail.name
                );
 
                        
                      },
                    ),
                    Gap(11.h),
                    TextView(
                      text: "Still having issues? We are happy to help",
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.italic,
                      textAlign: TextAlign.center,
                    ),
                    TextView(
                      text: "Contact us",
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      underline: true,
                      color: AppColors.metalPinkColour,
                      textAlign: TextAlign.center,
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
}
