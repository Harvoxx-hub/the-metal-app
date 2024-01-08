//
import 'package:flutter/widgets.dart';

/// Does not allow showing the keyboard for any action over the input field.
/// Useful when you need to scroll through a value, but not open the keyboard.
///
/// `enabled: false` does not allow scrolling
class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
