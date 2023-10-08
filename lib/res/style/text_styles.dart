import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextStyles {
  ///
  ///font size = [15.sp]
  static text(
      {double? fontDiff,
      FontWeight? weight,
      TextDecoration? decoration,
      FontStyle? fontStyle}) {
    return TextStyle(
        fontSize: (15 + (fontDiff ?? 0)).sp,
        fontWeight: weight,
        decoration: decoration,
        fontStyle: fontStyle);
  }
}
