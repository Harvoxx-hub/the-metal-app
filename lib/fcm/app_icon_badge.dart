import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Clears the launcher / home-screen icon badge without [app_badge_plus].
///
/// [app_badge_plus] was removed after TestFlight crashes at launch on iOS 18
/// (`swift_getObjectType` + null during plugin registration). This uses the
/// same [FlutterLocalNotificationsPlugin] singleton as FCM/local notifications.
abstract final class AppIconBadge {
  static const int _badgeClearNotificationId = 0xBAD9E001;

  /// Best-effort badge clear on iOS (Darwin), Android, and macOS.
  static Future<void> clear() async {
    if (kIsWeb) return;
    if (!(Platform.isIOS || Platform.isAndroid || Platform.isMacOS)) return;

    try {
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.initialize(
        InitializationSettings(
          android: Platform.isAndroid
              ? const AndroidInitializationSettings('@mipmap/launcher_icon')
              : null,
          iOS: Platform.isIOS
              ? const DarwinInitializationSettings(
                  requestAlertPermission: false,
                  requestBadgePermission: true,
                  requestSoundPermission: false,
                )
              : null,
          macOS: Platform.isMacOS
              ? const DarwinInitializationSettings(
                  requestAlertPermission: false,
                  requestBadgePermission: true,
                  requestSoundPermission: false,
                )
              : null,
        ),
      );

      if (Platform.isIOS || Platform.isMacOS) {
        const darwin = DarwinNotificationDetails(
          presentAlert: false,
          presentSound: false,
          presentBanner: false,
          presentList: false,
          presentBadge: true,
          badgeNumber: 0,
        );
        await plugin.show(
          _badgeClearNotificationId,
          '',
          '',
          NotificationDetails(
            iOS: Platform.isIOS ? darwin : null,
            macOS: Platform.isMacOS ? darwin : null,
          ),
        );
        await plugin.cancel(_badgeClearNotificationId);
      } else if (Platform.isAndroid) {
        await plugin.cancelAll();
      }
    } catch (_) {}
  }
}
