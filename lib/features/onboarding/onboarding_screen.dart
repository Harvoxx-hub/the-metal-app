import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
 

import '../../widgets/text_views.dart';

class OnboardingWidget extends StatefulWidget {
  final String imageUrl;
  final String headerText;
  final String descriptionText;

  const OnboardingWidget({
    super.key,
    required this.imageUrl,
    required this .headerText,
    required this.descriptionText,
  });

  @override
  State<OnboardingWidget> createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(128),
        Image.asset(
          widget.imageUrl,
          width: 172,
          height: 172,
        ),
        TextView(
          text: widget .headerText,
          fontSize: 30,
          fontWeight: FontWeight.normal,
        ),
        const Gap(20),
        TextView(
          text: widget.descriptionText,
          fontSize: 16,
          fontFamily: 'Merri_weather',
          fontWeight: FontWeight.normal,
        ),
      ],
    );
  }
}
