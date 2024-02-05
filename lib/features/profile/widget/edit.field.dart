import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

class EditField extends StatelessWidget {
  const EditField({
    super.key,
    this.floatingLabel,
    this.subLabel,
    required this.text,
    this.onSubLabel,
    this.sufixIcon,
    this.ontap,
    this.prefixIcon,
  });
  final String? floatingLabel;
  final String? subLabel;
  final String text;
  final Widget? sufixIcon;
  final Widget? prefixIcon;

  final Function()? onSubLabel;
  final Function()? ontap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            floatingLabel != null
                ? TextView(
                    text: floatingLabel!,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: AppColors.metalBrownColourForText,
                    textAlign: TextAlign.left,
                  )
                : const SizedBox(),
            const Spacer(),
            TextView(
              text: subLabel ?? "",
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.blueAccent,
              underline: true,
              onTap: onSubLabel,
            ),
          ],
        ),
        floatingLabel != null
            ? const SizedBox(
                height: 8,
              )
            : const SizedBox(),
        GestureDetector(
          onTap: ontap,
          child: Container(
              padding: const EdgeInsets.only(left: 10, top: 16, bottom: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: AppColors.metalButtonStroke, width: 1.0)),
              child: Row(
                children: [
                  sufixIcon ?? const SizedBox(),
                  const Gap(10),
                  TextView(
                    text: text,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  const Spacer(),
                  prefixIcon ?? const SizedBox(),
                  Gap(10),
                ],
              )),
        ),
      ],
    );
  }
}
