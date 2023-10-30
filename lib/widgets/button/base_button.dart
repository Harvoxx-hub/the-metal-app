import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../res/colors/cr_colors.dart';

import '../text_views.dart';

class BaseButton extends StatelessWidget {
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

  BaseButton({
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
        width: width!.w,
        height: height!.h,
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment(1.00, -0.03),
            end: Alignment(-1, 0.03),
            colors: enabled // Use enabled state to determine gradient colors
                ? [Color(0xFFCE0D87), Color(0xFFFF5553), Color(0xFFD2128B)]
                : [
                    Color(0xFFCE0D87).withOpacity(0.3),
                    Color(0xFFFF5553).withOpacity(0.3),
                    Color(0xFFD2128B).withOpacity(0.3)
                  ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: thickBorder
                ? BorderSide(color: Colors.black, width: 2.0)
                : BorderSide.none,
          ),
        ),
        child: loading
            ? Center(
                child: SizedBox(
                  height: 25.h,
                  width: 25.w,
                  child: const CircularProgressIndicator(
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
