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
  // Parse the date: API timestamps are typically UTC (ISO with Z). Convert to local for display.
  DateTime date = datetime ?? _parseToLocal(isoDateString ?? DateTime.now().toIso8601String());

  // Ensure we compare local time to local "now" for correct relative strings
  final localDate = date.isUtc ? date.toLocal() : date;

  return timeago.format(localDate, locale: locale);
}

/// Parse ISO string (UTC or local) and return as local DateTime for consistent display.
DateTime _parseToLocal(String isoDateString) {
  final date = DateTime.parse(isoDateString);
  return date.isUtc ? date.toLocal() : date;
}

String ActiveTime({
  String? isoDateString,
  DateTime? datetime,
  String locale = 'en',
}) {
  String time = formatTime(
    isoDateString: isoDateString,
    datetime: datetime,
    locale: locale,
  );
  if (time == "a moment ago") {
    return "active";
  } else {
    return time;
  }
}

/// Determines the accurate online status based on both isOnline flag and lastActive timestamp
/// This prevents showing "active" for users who went offline but have stale isOnline=true
String getAccurateOnlineStatus({
  required bool isOnline,
  required bool showOnline,
  String? lastActive,
  int maxOfflineMinutes = 5, // Consider offline after 5 minutes of inactivity
  String locale = 'en',
}) {
  // If user has disabled showing online status
  if (!showOnline) {
    return "Offline";
  }

  // If no lastActive data, fall back to isOnline flag
  if (lastActive == null || lastActive.isEmpty) {
    return isOnline ? "active" : "Offline";
  }

  try {
    // Parse lastActive (API sends UTC). Compare in local time.
    final lastActiveTime = _parseToLocal(lastActive);
    final now = DateTime.now();
    final timeDifference = now.difference(lastActiveTime);

    // If lastActive is more than maxOfflineMinutes ago, definitely offline
    if (timeDifference.inMinutes > maxOfflineMinutes) {
      return ActiveTime(isoDateString: lastActive, locale: locale);
    }

    // If recent activity AND isOnline flag is true, show active
    if (isOnline && timeDifference.inMinutes <= maxOfflineMinutes) {
      return "active";
    }

    // If isOnline is false or activity is getting stale, show time-based status
    return ActiveTime(isoDateString: lastActive, locale: locale);
  } catch (e) {
    // Fallback to isOnline flag if parsing fails
    return isOnline ? "active" : "Offline";
  }
}

int daysRemaining(String isoDateString, int durationInDays) {
  // Get the current date in local time
  DateTime now = DateTime.now();
  // Parse the ISO 8601 date string and convert it to local time
  DateTime date =
      isoDateString == "" ? now : DateTime.parse(isoDateString).toLocal();

  // Calculate the difference in days since connection
  int daysSinceConnection = now.difference(date).inDays;

  // Return completed days, capped at the required duration
  final days = daysSinceConnection >= durationInDays
      ? durationInDays
      : daysSinceConnection;
  print('days: $days');
  return days;
}

bool hasDurationReached(String isoDateString, int durationInDays) {
  // Parse the ISO 8601 date string and convert it to local time
  DateTime date = DateTime.parse(isoDateString).toLocal();

  // Calculate the target date by adding the duration to the parsed date
  // DateTime targetDate = date.add(Duration(days: durationInDays));

  // Get the current date in local time
  DateTime now = DateTime.now();

  return now.difference(date).inDays >= durationInDays;

  // Check if the current date has reached or surpassed the target date
  // return now.isAfter(targetDate) || now.isAtSameMomentAs(targetDate);
}
