import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';
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
        Gap(16.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextView(
              text: title,
              fontSize: 20.sp,
              fontWeight: FontWeight.w400,
            ),
            TextView(
              text: subtitle,
              fontSize: 13.sp,
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.italic,
            ),
          ],
        ),
      ],
    );
  }
}
