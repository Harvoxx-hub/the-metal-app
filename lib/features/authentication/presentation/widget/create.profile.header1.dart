import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:metal/widgets/text_views.dart';

class CreateProfileHeader1 extends StatelessWidget {
  const CreateProfileHeader1(
      {super.key,
      required this.title1,
      required this.title2,
      required this.title3});
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
        Gap(3),
        TextView(
          text: title2,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
        Gap(3),
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
