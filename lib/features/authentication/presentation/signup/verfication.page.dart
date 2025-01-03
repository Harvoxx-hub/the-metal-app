import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
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

enum RouteFrom {
  AccountSetting,
  UpdatePhoneNumber,
  UpdateEmail,
  ForgetPassword
}

class VerificationPage extends ConsumerStatefulWidget {
  VerificationPage(this.argument, {super.key});
  static const name = 'Verification';
  static const route = name;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(verficationProvider.notifier)
          .sendVerificationCode(widget.argument.email!);
    });
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
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<VerficationState>(verficationProvider, (prev, current) {
      if (current.isSuccess) {
        if (widget.argument.type == RouteFrom.AccountSetting) {
          Navigator.pushReplacementNamed(context, AppRoutes.welcomePage);
        }
        if (widget.argument.type == RouteFrom.UpdatePhoneNumber) {
          Navigator.pushReplacementNamed(context, AppRoutes.newPhoneNumberPage);
        }
        if (widget.argument.type == RouteFrom.UpdateEmail) {
          Navigator.pushReplacementNamed(context, AppRoutes.newEmailPage);
        }
        if (widget.argument.type == RouteFrom.ForgetPassword) {
          Navigator.pushReplacementNamed(context, AppRoutes.createNewPassword,
              arguments: widget.argument.uuid);
        }
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
            const Gap(43),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextView(
                  text: '👀',
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                ),
                const TextView(
                  text: 'We just want to verify it is you',
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
                TextView(
                  text:
                      'Please input the OTP code sent to \n*${widget.argument.email}*',
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300,
                ),
                SizedBox(
                  width: getDeviceWidth(context),
                )
              ],
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
            const Gap(36),
            const Gap(33),
            _secondsRemaining == 0
                ? Column(
                    children: [
                      const TextView(
                        text: "Didn’t receive the code? ",
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        textAlign: TextAlign.center,
                        fontStyle: FontStyle.italic,
                        color: AppColors.metalBrownColourForText,
                      ),
                      const TextView(
                        text: " Tap to resend the OTP",
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
                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(verficationProvider.notifier)
                                  .sendVerificationCode(widget.argument.email!);
                              setState(() {
                                _secondsRemaining = 60;
                                startTimer();
                              });
                            },
                            child: SvgPicture.asset(
                              Assets.icons.verificationText.path,
                              height: 50,
                              width: 50,
                            ),
                          ),
                          // Gap(10.w),
                          // SvgPicture.asset(
                          //   Assets.icons.verificationCall.path,
                          //   height: 50 ,
                          //   width: 50.w,
                          // ),
                        ],
                      ),
                    ],
                  )
                : TextView(
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
    ref
        .read(verficationProvider.notifier)
        .verifyCode(widget.argument.email!, value);
  }
}
