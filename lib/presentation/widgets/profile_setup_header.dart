import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/widgets/text_views.dart';

/// Header style 1 - for basic info screen
class ProfileSetupHeader1 extends StatelessWidget {
  const ProfileSetupHeader1({
    super.key,
    required this.title1,
    required this.title2,
    required this.title3,
  });

  final String title1;
  final String title2;
  final String title3;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(
          text: title1,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
        const Gap(3),
        TextView(
          text: title2,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
        const Gap(3),
        TextView(
          text: title3,
          fontSize: 14,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w300,
        ),
      ],
    );
  }
}

/// Header style 2 - for other profile setup screens
class ProfileSetupHeader2 extends StatelessWidget {
  const ProfileSetupHeader2({
    super.key,
    required this.path,
    required this.title,
    required this.subtitle,
  });

  final String path;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          path,
          height: 73,
          width: 73,
        ),
        const Gap(16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextView(
              text: title,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
            TextView(
              text: subtitle,
              fontSize: 13,
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.italic,
            ),
          ],
        ),
      ],
    );
  }
}
