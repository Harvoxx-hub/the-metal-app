import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/res/res.dart';
import 'package:metal/widgets/text_views.dart';

class OnboardingWidget extends StatelessWidget {
  final String imageUrl;
  final String headerText;
  final String descriptionText;
  final bool checkMetal;
  final String? subHeader;

  const OnboardingWidget({
    super.key,
    required this.imageUrl,
    required this.headerText,
    required this.descriptionText,
    this.checkMetal = false,
    this.subHeader,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(108),
        const TextView(
          text: "Metal Blind Connect",
          color: AppColors.metalPinkColour,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        const Gap(20),
        Image.asset(
          imageUrl,
          width: 172,
          height: 172,
        ),
        TextView(
          text: headerText,
          fontSize: 30,
          fontWeight: FontWeight.normal,
        ),
        const Gap(20),
        TextView(
          text: descriptionText,
          fontSize: 16,
          fontFamily: 'Merri_weather',
          fontWeight: FontWeight.normal,
        ),
        const Gap(20),
        if (checkMetal)
          TextView(
            text: subHeader ?? '',
            fontSize: 16,
            fontFamily: 'Merri_weather',
            fontWeight: FontWeight.w600,
          ),
      ],
    );
  }
}

