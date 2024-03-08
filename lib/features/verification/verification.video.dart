import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/presentation/widget/create.profile.header1.dart';
import 'package:metal/features/authentication/provider/verfication.notifier.dart';
import 'package:metal/features/dashboard.dart/dashboard.dart';
import 'package:metal/features/profile/widget/edit.field.dart';
import 'package:metal/features/upgrade/upgrade.page.dart';
import 'package:metal/features/verification/provider/verification.notifier.dart';
import 'package:metal/features/verification/video.preview.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text_views.dart';

class VerificationVideo extends ConsumerStatefulWidget {
  const VerificationVideo({super.key});
  static const name = 'VerificationVideo';
  static const route = '$name';

  @override
  ConsumerState<VerificationVideo> createState() => _VerificationVideoState();
}

class _VerificationVideoState extends ConsumerState<VerificationVideo> {
  File? _videoFile;
  @override
  Widget build(BuildContext context) {
    final verfication = ref.watch(verficationVideoProvider);

    ref.listen<VerificationState>(verficationVideoProvider, (prev, current) {
      if (current.isSuccess) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(
              content: verifyDialog(context),
            );
          },
        );

        context.pushReplacementNamed(DashboardPage.name);
      }
    });
    return BaseScreen(
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        Header: 'Verification',
        authFlow: true,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(42),
            const CreateProfileHeader1(
              title1: "👋 Hello",
              title2: "Please fill in the details",
              title3: 'your details are kept confidential with us',
            ),
            Gap(24.h),
            EditField(
                ontap: () {
                context.pushNamed(VideoPreview.name).then((value) {
                    if (value != null) {
                      setState(() {
                        _videoFile = value as File;
                      });
                    }
                  });
                },
                floatingLabel: "Full live video of yourself",
                sufixIcon: Assets.icons.videoCamera.svg(width: 24, height: 24),
                text: _videoFile == null
                    ? "Tap to take a live video of yourself"
                    : "MyVideo.MP4"),
            Gap(24.h),
            TextView(
              text:
                  "VIDEO CRITERIA \n - Please introduce yourself to us. \n - Show your full face on the camera. \n - Mention your name and country of residence \n - Video should be 1 Minute max ",
              fontSize: 14,
            ),
            Spacer(),
            Column(
              children: [
                TextView(
                  text: "This is for internal verification purposes",
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
                Gap(24.h),
                BaseButton(
                  loading: verfication.isLoading,
                  enabled: _videoFile != null,
                  buttonText: "Upload Your Video",
                  onPressed: _onNextPressed,
                ),
                Gap(24.h),
                TextView(
                  text: "Pravicy and Security Policy",
                  fontStyle: FontStyle.italic,
                  underline: true,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ],
            ),
          ],
        ));
  }

  void _onNextPressed() {
    ref.watch(verficationVideoProvider.notifier).verificationMe(_videoFile!);
  }

  Widget verifyDialog(BuildContext context) {
    return Column(
      children: [
        Gap(38.h),
        Assets.images.checkVerified.image(),
        Gap(15.h),
        TextView(
          text: "Video uploaded!",
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        Gap(15.h),
        TextView(
          text:
              "Your video has been uploaded successfully and verification is ongoing. You would receive a notification in (one) 1 week. Afterwards, your profile would show as verified",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        Gap(38.h),
        BaseButton(
            buttonText: "Upgrade to Metal Plus",
            onPressed: () {
              context.pushNamed(UpgradePage.name);
              //  confirm(context);
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
}
