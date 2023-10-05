import 'package:flutter/material.dart';

@immutable
class ThemeValue<T> extends ThemeExtension<ThemeValue<T>> {
  const ThemeValue(this.value);

  final T value;

  @override
  ThemeExtension<ThemeValue<T>> copyWith() {
    return ThemeValue<T>(value);
  }

  @override
  ThemeExtension<ThemeValue<T>> lerp(
    ThemeExtension<ThemeValue<T>>? other,
    double t,
  ) {
    return other is! ThemeValue<T> || t < 1 ? this : other;
  }
}
