import 'package:flutter/widgets.dart';

class TextEditingControllerSetPosition extends TextEditingController {
  TextEditingControllerSetPosition({super.text});

  void setTextAndPosition(String newText, {int? currentPosition}) {
    final offset = currentPosition ?? newText.length;
    value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }
}
