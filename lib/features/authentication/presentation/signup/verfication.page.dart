import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/core/utils/screen.size.dart';
import 'package:metal/features/authentication/presentation/signup/verfication.argument.dart';
import 'package:metal/features/authentication/provider/verfication.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
 
import 'package:metal/res/res.dart';
import 'package:metal/route/routes.dart';

import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

enum RouteFrom { AccountSetting, UpdatePhoneNumber, UpdateEmail }

class VerificationPage extends ConsumerStatefulWidget {
  VerificationPage(this.argument, {Key? key}) : super(key: key);
  static const name = 'Verification';
  static const route = '$name';
  VerificationSentArgument argument;

  @override
  ConsumerState<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends ConsumerState<VerificationPage> {
  final TextEditingController _otpController = TextEditingController();

  int _secondsRemaining = 60;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
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
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<VerficationState>(verficationProvider, (prev, current) {
      if (current.isSuccess) {
                Navigator.pushReplacementNamed(context, AppRoutes.welcomePage);
 
      }
    });

    return BaseScreen(
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: 'Verification',
      authFlow: true,
      body: SingleChildScrollView(
        child: Column(
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
                  text:
                      'Please input the OTP code sent to \n*${widget.argument.phoneNumber}*',
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
                fieldWidth: 40,
              ),
              keyboardType: TextInputType.number,
              showCursor: false,

              length: 6,
              animationType: AnimationType.scale,
              //ignore: no-empty-block
              onChanged: (_) {},
              onCompleted: (value) {
                checkCode(value, context);
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
            _secondsRemaining == 0
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        Assets.icons.verificationText.path,
                        height: 50.h,
                        width: 50.w,
                      ),
                      // Gap(10.w),
                      // SvgPicture.asset(
                      //   Assets.icons.verificationCall.path,
                      //   height: 50.h,
                      //   width: 50.w,
                      // ),
                    ],
                  )
                : Gap(0),
            Gap(23.h),
            TextView(
              text:
                  "${formatDuration(Duration(seconds: _secondsRemaining))} Remaining",
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              textAlign: TextAlign.center,
              color: AppColors.metalBrownColourForText,
            ),
            Gap(27.h),
            BaseButton(
              buttonText: "Verify Code",
              loading: ref.watch(verficationProvider).isLoading,
              onPressed: () {
                checkCode(_otpController.text, context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void checkCode(String value, context) {
    if (value == widget.argument.code.toString()) {
      if (widget.argument.type == RouteFrom.AccountSetting) {
        ref.read(verficationProvider.notifier).activateAccount(
              widget.argument.uuid!,
        );
      }
      if (widget.argument.type == RouteFrom.UpdatePhoneNumber) {
        Navigator.pushReplacementNamed(context, AppRoutes.newPhoneNumberPage);
      
      }
      if (widget.argument.type == RouteFrom.UpdateEmail) {
                Navigator.pushReplacementNamed(context, AppRoutes.newEmailPage);
        
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid Code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
