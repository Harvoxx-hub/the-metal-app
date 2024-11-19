import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/date.formart.dart';

import 'package:metal/gen/assets.gen.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';

import 'package:metal/widgets/text_views.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ForgetPasswordOTPPage extends ConsumerStatefulWidget {
  ForgetPasswordOTPPage({super.key});
  static const name = 'forgetPasswordOtpPage';
  static const route = name;

  @override
  ConsumerState<ForgetPasswordOTPPage> createState() =>
      _ForgetPasswordOTPPageState();
}

class _ForgetPasswordOTPPageState extends ConsumerState<ForgetPasswordOTPPage> {
  final TextEditingController _otpController = TextEditingController();
  int _secondsRemaining = 60;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      authFlow: true,
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: 'Forgot Password',
      body: Column(children: [
        const Gap(25),
        const TextView(
          text:
              'Forgetting password is common and you are not alone. Let us help you recover your password.',
          fontSize: 13,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w300,
        ),
        const Gap(52),
        const TextView(
          text: 'Please input the OTP code sent to *+18100110011*',
          fontSize: 14,
          fontWeight: FontWeight.w300,
        ),
        const Gap(40),
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
        const Gap(36),
        const TextView(
          text: "Didn’t receive the code? ",
          fontSize: 12,
          fontWeight: FontWeight.w400,
          textAlign: TextAlign.center,
          fontStyle: FontStyle.italic,
          color: AppColors.metalBrownColourForText,
        ),
        const TextView(
          text: " Tap to resend via Email",
          fontSize: 12,
          fontWeight: FontWeight.w400,
          textAlign: TextAlign.center,
          fontStyle: FontStyle.italic,
          color: AppColors.metalBrownColourForText,
        ),
        const Gap(33),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              Assets.icons.verificationText.path,
              height: 50,
              width: 50,
            ),
            Gap(10),
            SvgPicture.asset(
              Assets.icons.verificationCall.path,
              height: 50,
              width: 50,
            ),
          ],
        ),
        const Gap(27),
        TextView(
          text:
              "${formatDuration(Duration(seconds: _secondsRemaining))} Remaining",
          fontSize: 12,
          fontWeight: FontWeight.w400,
          textAlign: TextAlign.center,
          color: AppColors.metalBrownColourForText,
        ),
        const Gap(27),
        BaseButton(
          buttonText: "Verify Code",
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.createNewPassword);
          },
          // enabled: _emailController.text.isNotEmpty &&
          //     _passwordController.text.isNotEmpty,
        ),
      ]),
    );
  }
}
