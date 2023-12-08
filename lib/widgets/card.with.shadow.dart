import 'package:flutter/material.dart';

class CardWithShadow extends StatelessWidget {
  final Widget child;
  final double height;
  final double? width;
  final Function()? onTap;

  const CardWithShadow(
      {super.key,
      required this.height,
      required this.child,
      this.width,
      this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.only(top: 10.0, bottom: 10, left: 10, right: 10),
        child: Expanded(
          child: Container(
            width: width ?? double.infinity,
            height: height,
            padding: const EdgeInsets.all(8),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
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
            child: child,
          ),
        ),
      ),
    );
  }
}
