import 'package:flutter/services.dart';

/// Does not allow you to enter more or less than a certain interval.
///
/// Otherwise, the input will be ignored.
class NumberRangeTextFormatter extends TextInputFormatter {
  NumberRangeTextFormatter({
    required this.maxInclusive,
    this.min = 0,
  });

  final int min;
  final int maxInclusive;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final value = int.tryParse(newValue.text);
    if (value == null) {
      return const TextEditingValue();
    } else if (value > min && value <= maxInclusive) {
      return newValue.copyWith(text: newValue.text);
    }

    return oldValue;
  }
}
