import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/pages/authentication/presentation/welcome/presentation/welcome.page.dart';
import 'package:metal/pages/profile/update.email/new.email.page.dart';
import 'package:metal/pages/profile/update.email/update.email.page.dart';
import 'package:metal/pages/profile/update.phone.number/new.phone.number.page.dart';
import 'package:metal/pages/profile/update.phone.number/update.phone.number.page.dart';
import 'package:metal/res/res.dart';
import 'package:metal/utils/screen.size.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

enum RouteFrom { AccountSetting, UpdatePhoneNumber, UpdateEmail }

class VerificationPage extends ConsumerWidget {
  VerificationPage(this.routeFrom, {Key? key}) : super(key: key);
  static const name = 'Verification';
  static const route = '$name';
  final String routeFrom;
  static final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseScreen(
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: 'Verification',
      authFlow: true,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Gap(43.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextView(
                text: '👀',
                fontSize: 30.sp,
                fontWeight: FontWeight.w400,
              ),
              TextView(
                text: 'We just want to verify it is you',
                fontSize: 20.sp,
                fontWeight: FontWeight.w400,
              ),
              TextView(
                text: 'Please input the OTP code sent to \n*+10341100119*',
                fontSize: 14.sp,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w300,
              ),
              SizedBox(
                width: getDeviceWidth(context),
              )
            ],
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
              onCompleted(value, context);
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
              if (routeFrom == RouteFrom.AccountSetting.name) {
                context.pushNamed(WelcomePage.name);
              }
              if (routeFrom == RouteFrom.UpdatePhoneNumber.name) {
                context.pushNamed(NewPhoneNumberPage.name);
              }
              if (routeFrom == RouteFrom.UpdateEmail.name) {
                context.pushNamed(NewEmailPage.name);
              }
            },
            // enabled: _emailController.text.isNotEmpty &&
            //     _passwordController.text.isNotEmpty,
          ),
        ],
      ),
    );
  }

  void onCompleted(String value, context) {
    print(value);
    context.pushNamed(WelcomePage.name);
  }
}
