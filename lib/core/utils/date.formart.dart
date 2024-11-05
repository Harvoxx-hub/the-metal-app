import 'package:intl/intl.dart';

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


String formatToWhatsAppChatTime(String isoDateString) {
  // Parse the ISO 8601 date string and convert to local time
  DateTime date = DateTime.parse(isoDateString).toLocal();
  
  // Get the current time in local time zone
  DateTime now = DateTime.now();
  
  Duration diff = now.difference(date);
  
  if (diff.inDays == 0) {
    // Same day, show time as HH:mm
    return DateFormat('HH:mm').format(date);
  } else if (diff.inDays == 1) {
    // Yesterday
    return 'Yesterday';
  } else {
    // Older dates, show date as dd/MM/yy
    return DateFormat('dd/MM/yy').format(date);
  }
}

