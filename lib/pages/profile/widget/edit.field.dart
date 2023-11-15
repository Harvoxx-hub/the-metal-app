import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

class EditField extends StatelessWidget {
  const EditField(
      {super.key,
      required this.floatingLabel,
      required this.subLabel,
      required this.text,
      required this.onSubLabel});
  final String floatingLabel;
  final String subLabel;
  final String text;
  final Function() onSubLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextView(
              text: floatingLabel,
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              color: AppColors.metalBrownColourForText,
              textAlign: TextAlign.left,
            ),
            Spacer(),
            TextView(
              text: subLabel,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.blueAccent,
              underline: true,
              onTap: onSubLabel,
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Container(
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border:
                    Border.all(color: AppColors.metalButtonStroke, width: 1.0)),
            child: Center(
              child: TextView(
                text: text,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            )),
      ],
    );
  }
}
