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
