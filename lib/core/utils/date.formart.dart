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

String formatTime({String? isoDateString, DateTime? datetime}) {
  // Parse the ISO 8601 date string to a DateTime object
  DateTime date = datetime ?? DateTime.parse(isoDateString!).toLocal();

  // Use timeago to generate a relative time string
  return timeago.format(date,
      locale: 'en'); // Change 'en' to other locales if needed
}
