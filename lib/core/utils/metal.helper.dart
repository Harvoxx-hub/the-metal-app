import 'package:metal/features/home_page/domain/entries/thought.model.dart';
import 'package:metal/features/notification/domain/entries/notification.model.dart';

class MetalHelper {
  static List<ThoughtModel> sortThoughtsByDate(List<ThoughtModel> thoughts) {
    thoughts.sort((a, b) {
      DateTime? dateA =
          a.created_at != null ? DateTime.parse(a.created_at!) : null;
      DateTime? dateB =
          b.created_at != null ? DateTime.parse(b.created_at!) : null;

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateB.compareTo(dateA);
    });

    return thoughts;
  }

  static List<NotificationModel> sortNotificationByDate(
      List<NotificationModel> thoughts) {
    thoughts.sort((a, b) {
      DateTime? dateA =
          a.created_at != null ? DateTime.parse(a.created_at!) : null;
      DateTime? dateB =
          b.created_at != null ? DateTime.parse(b.created_at!) : null;

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateB.compareTo(dateA);
    });

    return thoughts;
  }
}
