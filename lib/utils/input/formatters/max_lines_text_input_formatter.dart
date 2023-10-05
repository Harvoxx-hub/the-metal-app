import 'package:flutter/services.dart';

/// Allows you to limit the number of lines entered by the user.
class MaxLinesTextInputFormatter extends TextInputFormatter {
  MaxLinesTextInputFormatter({
    required this.maxLines,
    // ignore: prefer_asserts_with_message
  }) : assert(maxLines > 0);

  static const String newLinePattern = r'[\n]';
  final int maxLines;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    final regex = RegExp(newLinePattern);
    final matchesCount = regex.allMatches(newText).length + 1;
    if (matchesCount <= maxLines) {
      return newValue;
    }

    return oldValue;
  }
}
