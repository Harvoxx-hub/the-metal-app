import 'package:flutter/foundation.dart';

/// Signal for notification list refresh when FCM push is received.
/// FCM client fires this; NotificationView listens and refreshes.
class NotificationRefreshSignal {
  NotificationRefreshSignal._();
  static final NotificationRefreshSignal instance = NotificationRefreshSignal._();

  final ValueNotifier<int> _counter = ValueNotifier(0);

  /// Listen to trigger refresh when FCM push received
  void addListener(VoidCallback listener) {
    _counter.addListener(listener);
  }

  void removeListener(VoidCallback listener) {
    _counter.removeListener(listener);
  }

  /// Call when FCM message received (foreground or background)
  void notifyPushReceived() {
    _counter.value++;
  }
}
