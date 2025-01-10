import 'package:flutter/material.dart';

import '../../res/colors/cr_colors.dart';

import '../text_views.dart';

class PlainButton extends StatelessWidget {
  final String buttonText;
  final TextOverflow? textOverflow;
  final TextAlign? textAlign;
  final Color? textColor;
  final double fontSize;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final Color? color;
  final bool loading;
  final Function()? onPressed;
  final double? height;
  final double? width;
  final double? radius;
  final bool outlined;
  final bool lowerCase;
  final bool thickBorder;
  final Widget? child;
  final bool enabled;
  final Widget? leftIcon;

  final Widget? rightIcon;

  const PlainButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.textOverflow = TextOverflow.clip,
    this.textAlign = TextAlign.left,
    this.color = AppColors.metalPinkColour,
    this.height = 52.0,
    this.width = double.infinity * 0.8,
    this.fontSize = 12.0,
    this.radius = 12.0,
    this.leftIcon,
    this.rightIcon,
    this.loading = false,
    this.fontWeight = FontWeight.w400,
    this.fontStyle = FontStyle.normal,
    this.textColor = AppColors.metalWhite,
    this.outlined = false,
    this.thickBorder = false,
    this.lowerCase = true,
    this.child,
    this.enabled = true, // Default to true
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null, // Disable onTap if not enabled
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: enabled // Use enabled state to determine gradient colors
              ? color
              : color?.withOpacity(0.07),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: thickBorder
                ? const BorderSide(color: Colors.black, width: 2.0)
                : BorderSide.none,
          ),
        ),
        child: loading
            ? const Center(
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(
                    color: AppColors.metalWhite,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  leftIcon ?? const SizedBox.shrink(),
                  child ??
                      TextView(
                        text: lowerCase ? buttonText : buttonText.toUpperCase(),
                        fontWeight: fontWeight,
                        fontSize: fontSize,
                        color: outlined ? color : textColor,
                        textAlign: textAlign,
                      ),
                  rightIcon ?? const SizedBox.shrink(),
                ],
              ),
      ),
    );
  }
}
