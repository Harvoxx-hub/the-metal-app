import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/text_views.dart';

class MeltNotifcationItem extends StatelessWidget {
  const MeltNotifcationItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        decoration: ShapeDecoration(
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
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(Assets.images.profileNotification.path),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  // alignment: Alignment.bottomRight,
                  child: Image.asset(Assets.images .sparkNotification.path),
                )
              ],
            ),
            Gap(18.w),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    text: "@*elizabeth_gold* pushed your profile",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  Row(
                    children: [
                      Spacer(),
                      TextView(
                        text: "Mon at 8:14am",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
