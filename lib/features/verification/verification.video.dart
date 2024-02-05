import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/presentation/widget/create.profile.header1.dart';
import 'package:metal/features/profile/widget/edit.field.dart';
import 'package:metal/features/verification/video.preview.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';

class VerificationVideo extends StatefulWidget {
  const VerificationVideo({super.key});
  static const name = 'VerificationVideo';
  static const route = '$name';

  @override
  State<VerificationVideo> createState() => _VerificationVideoState();
}

class _VerificationVideoState extends State<VerificationVideo> {
  File? _videoFile;
  @override
  Widget build(BuildContext context) {
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
                text: "Tap to take a live video of yourself"),
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
    //  Navigator.pushNamed(context, VerificationVideo2.route);
  }
}
