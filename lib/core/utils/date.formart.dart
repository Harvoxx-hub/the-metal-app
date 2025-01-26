import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

String formatDateDDMMYY(String inputDate) {
  DateTime date = DateTime.parse(inputDate);
  String formattedDate = DateFormat('dd/MM/yyyy').format(date);
  return formattedDate;
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String minutes = twoDigits(duration.inMinutes.remainder(60));
  String seconds = twoDigits(duration.inSeconds.remainder(60));
  return '$minutes:$seconds';
}

String formatTime({
  String? isoDateString,
  DateTime? datetime,
  String locale = 'en',
}) {
  // Parse the date and convert to local time
  DateTime date = datetime ??
      DateTime.parse(isoDateString ?? DateTime.now().toIso8601String());

  // Convert to local time for display
  DateTime localDate = date.toLocal();

  // Return relative time string based on local time
  return timeago.format(localDate, locale: locale);
}

String ActiveTime({String? isoDateString, DateTime? datetime}) {
  String time = formatTime(isoDateString: isoDateString);
  if (time == "a moment ago") {
    return "active";
  } else {
    return time;
  }
}

int daysRemaining(String isoDateString, int durationInDays) {
  // Get the current date in local time
  DateTime now = DateTime.now();
  // Parse the ISO 8601 date string and convert it to local time
  DateTime date =
      isoDateString == "" ? now : DateTime.parse(isoDateString).toLocal();

  // Calculate the target date by adding the duration to the parsed date
  DateTime targetDate = date.add(Duration(days: durationInDays));

  // Calculate the difference in days
  int remainingDays = targetDate.difference(now).inDays;

  // If the duration has passed, return 0 (no days remaining)
  return remainingDays > 0 ? remainingDays : 0;
}

bool hasDurationReached(String isoDateString, int durationInDays) {
  // Parse the ISO 8601 date string and convert it to local time
  DateTime date = DateTime.parse(isoDateString).toLocal();

  // Calculate the target date by adding the duration to the parsed date
  DateTime targetDate = date.add(Duration(days: durationInDays));

  // Get the current date in local time
  DateTime now = DateTime.now();

  // Check if the current date has reached or surpassed the target date
  return now.isAfter(targetDate) || now.isAtSameMomentAs(targetDate);
}
