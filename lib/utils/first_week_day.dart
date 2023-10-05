import 'package:flutter/material.dart';

/// - 0 - monday
/// - 1 - tuesday
/// - 2 - wednesday
/// - 3 - thursday
/// - 4 - friday
/// - 5 - saturday
/// - 6 - sunday
int firstWeekDay(BuildContext context) {
  /// 0 for Sunday, and 6 for Saturday
  final index = MaterialLocalizations.of(context).firstDayOfWeekIndex;

  return (index - 1) % DateTime.daysPerWeek;
}
