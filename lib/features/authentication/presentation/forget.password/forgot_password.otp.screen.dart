import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/presentation/forget.password/create.new.password.dart';

import 'package:metal/gen/assets.gen.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';

import 'package:metal/widgets/text_views.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ForgetPasswordOTPPage extends ConsumerWidget {
  ForgetPasswordOTPPage({Key? key}) : super(key: key);
  static const name = 'forgetPasswordOtpPage';
  static const route = '$name';
  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseScreen(
      authFlow: true,
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: 'Forgot Password',
      body: Column(children: [
        Gap(25.h),
        TextView(
          text:
              'Forgetting password is common and you are not alone. Let us help you recover your password.',
          fontSize: 13,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w300,
        ),
        Gap(52.h),
        TextView(
          text: 'Please input the OTP code sent to *+18100110011*',
          fontSize: 14,
          fontWeight: FontWeight.w300,
        ),
        Gap(40.h),
        PinCodeTextField(
          controller: _otpController,
          appContext: context,
          useHapticFeedback: true,
          pinTheme: PinTheme(
            activeColor: AppColors.metalPinkColour,
            disabledColor: AppColors.metalButtonStroke,
            selectedColor: AppColors.metalPinkColour,
            inactiveColor: AppColors.metalButtonStroke,
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(10),
            borderWidth: 0.5,
            fieldWidth: 52,
          ),
          keyboardType: TextInputType.number,
          showCursor: false,

          length: 5,
          animationType: AnimationType.scale,
          //ignore: no-empty-block
          onChanged: (_) {},
          onCompleted: (value) {
            //  onCompleted(value, context);
          },
        ),
        Gap(36.h),
        TextView(
          text: "Didn’t receive the code? ",
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          textAlign: TextAlign.center,
          fontStyle: FontStyle.italic,
          color: AppColors.metalBrownColourForText,
        ),
        TextView(
          text: " Tap to resend via SMS or Phone call",
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          textAlign: TextAlign.center,
          fontStyle: FontStyle.italic,
          color: AppColors.metalBrownColourForText,
        ),
        Gap(33.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              Assets.icons.verificationText.path,
              height: 50.h,
              width: 50.w,
            ),
            Gap(10.w),
            SvgPicture.asset(
              Assets.icons.verificationCall.path,
              height: 50.h,
              width: 50.w,
            ),
          ],
        ),
        Gap(27.h),
        TextView(
          text: "00:58 secounds",
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          textAlign: TextAlign.center,
          color: AppColors.metalBrownColourForText,
        ),
        Gap(27.h),
        BaseButton(
          buttonText: "Verify Code",
          onPressed: () {
            context.pushNamed(CreateNewPasswordPage.name);
          },
          // enabled: _emailController.text.isNotEmpty &&
          //     _passwordController.text.isNotEmpty,
        ),
      ]),
    );
  }
}
