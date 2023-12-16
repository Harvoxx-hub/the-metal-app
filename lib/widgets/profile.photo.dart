import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:metal/gen/assets.gen.dart';

class ProfilePhoto extends StatelessWidget {
  final double size;
  final bool verfly;

  const ProfilePhoto({super.key, required this.size, required this.verfly});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: DottedBorder(
              borderType: BorderType.Circle,
              radius: Radius.circular(12),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                child: Container(
                  width: size,
                  height: size,
                  decoration: ShapeDecoration(
                    gradient: generateRandomGradient(),
                    shape: OvalBorder(),
                  ),
                  child: Center(
                    child: Image.asset(
                      Assets.images.silver.path,
                      height: size * 0.7,
                      width: size * 0.7,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
            bottom: 0,
            right: size >= 57 ? size / 1.3 : 0,
            child: verfly
                ? SvgPicture.asset(
                    Assets.icons.checkVerified.path,
                    height: 23,
                    width: 23,
                  )
                : SizedBox())
      ],
    );
  }
}

LinearGradient generateRandomGradient() {
  Color randomColor1 =
      Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(0.8);
  Color randomColor2 =
      Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(0.8);
  Color randomColor3 =
      Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(0.8);

  return LinearGradient(
    begin: Alignment(-0.40, -0.92),
    end: Alignment(0.4, 0.92),
    colors: [Colors.white, randomColor1, randomColor2, randomColor3],
  );
}
