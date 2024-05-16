import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/widgets/text_views.dart';

class CreateProfileHeader2 extends StatelessWidget {
  const CreateProfileHeader2(
      {super.key,
      required this.path,
      required this.title,
      required this.subtitle});
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
