import 'package:flutter/material.dart';

import 'package:metal/features/authentication/domain/entries/metal.properties.model.dart';

import 'package:metal/res/colors/cr_colors.dart';

import 'package:metal/widgets/text_views.dart';

class ChooseMetalCard extends StatelessWidget {
  const ChooseMetalCard({
    super.key,
    required this.model,
    this.selected = false,
    required this.onTap,
  });
  final Metal model;
  final bool selected;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: selected
            ? ShapeDecoration(
                color: const Color(0xFFFBF0F8),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFFF5553)),
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
        child: Column(
          children: [
            Row(
              children: [
                TextView(
                  text: model.title!,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                const Spacer(),
                
                Image.network(
                  model.img!,
                  height: 40,
                  width: 40,
                )
              ],
            ),
            TextView(
              text: model.desc!,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.metalBrownColourForText.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
