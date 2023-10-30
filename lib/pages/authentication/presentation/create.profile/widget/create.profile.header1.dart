import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:metal/widgets/text_views.dart';

class CreateProfileHeader1 extends StatelessWidget {
  const CreateProfileHeader1({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(
          text: '👋 Hello',
          fontSize: 20.sp,
          fontWeight: FontWeight.w400,
        ),
        TextView(
          text: 'Let’s set up your profile',
          fontSize: 20.sp,
          fontWeight: FontWeight.w400,
        ),
        TextView(
          text: 'It takes only 3 minutes!',
          fontSize: 14.sp,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w300,
        ),
      ],
    );
  }
}
