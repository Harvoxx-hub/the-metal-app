import 'package:flutter/material.dart';

class TextStyles {
  ///
  ///font size = [15 ]
  static text(
      {double? fontDiff,
      FontWeight? weight,
      TextDecoration? decoration,
      FontStyle? fontStyle}) {
    return TextStyle(
        fontSize: (15 + (fontDiff ?? 0)),
        fontWeight: weight,
        decoration: decoration,
        fontStyle: fontStyle);
  }
}
