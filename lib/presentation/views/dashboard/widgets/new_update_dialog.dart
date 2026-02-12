import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:url_launcher/url_launcher.dart';

class NewUpdateDialog extends StatelessWidget {
  const NewUpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    String updateLink;

    if (Platform.isAndroid) {
      updateLink =
          'https://play.google.com/store/apps/details?id=com.bwh.metal_app';
    } else if (Platform.isIOS) {
      updateLink = 'https://apps.apple.com/gm/app/the-metal-app/id6499093482';
    } else {
      updateLink = 'https://yourappwebsite.com';
    }
    return Column(
      children: [
        const Gap(38),
        Assets.images.meltProfile.image(),
        const Gap(15),
        const TextView(
          text: "Update Available! 🚀",
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        const Gap(15),
        const TextView(
          text:
              "Experience the latest Metal App update! Discover new features, faster performance, and bug fixes for an even better user experience.",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(38),
        BaseButton(
            buttonText: "Update Now",
            onPressed: () async {
              // Launch the appropriate update link
              launchUrl(Uri.parse(updateLink));
            }),
        const Gap(23),
      ],
    );
  }
}
