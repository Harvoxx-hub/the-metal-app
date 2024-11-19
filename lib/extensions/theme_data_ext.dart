import 'package:flutter/material.dart';
import 'package:metal/res/theme/theme_value.dart';

extension ThemeDataExt on ThemeData {
  T? value<T>() => extension<ThemeValue<T>>()?.value;

  T? call<T>() => extension<ThemeValue<T>>()?.value;
}
