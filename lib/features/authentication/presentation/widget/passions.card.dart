import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/authentication/domain/entries/metal.properties.model.dart';
import 'package:metal/features/authentication/domain/entries/passion.card.model.dart';

import 'package:metal/res/colors/cr_colors.dart';

import 'package:metal/widgets/text_views.dart';

class PassionsCard extends StatelessWidget {
  const PassionsCard({
    super.key,
    required this.model,
    this.selected = false,
    required this.onTap,
  });
  final Passion model;
  final bool selected;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: selected
            ? ShapeDecoration(
                color: Color(0xFFFBF0F8),
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: Color(0xFFFF5553)),
                  borderRadius: BorderRadius.circular(10),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 1,
                    offset: Offset(0, 2),
                    spreadRadius: 0,
                  )
                ],
              )
            : ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x0C076DF3),
                    blurRadius: 40,
                    offset: Offset(0, 30),
                    spreadRadius: 0,
                  )
                ],
              ),
        child: Row(
          children: [
            SvgPicture.network(
              model.img!,
              height: 20,
              width: 20,
            ),
            Gap(8.w),
            TextView(
              text: model.title!,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
