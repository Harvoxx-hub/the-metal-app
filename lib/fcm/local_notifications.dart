import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Wrapper for [FlutterLocalNotificationsPlugin]
class LocalNotifications {
  // Android notification settings
  static const _androidChannelId = 'high_importance_channel';
  static const _androidChannelName = 'High Importance Notifications';
  static const _androidChannelDescription =
      'This channel is used for important notifications.';

  static int _lastNotificationId = 0;

  final _localNotifications = FlutterLocalNotificationsPlugin();

  static int get lastNotificationId => _lastNotificationId;

  /// Arguments:
  /// ---
  ///
  /// [onDidReceiveNotificationResponse]
  ///
  /// Callback for handling tap on notification that was shown by
  /// [show] method with provided payload.
  /// ---
  ///
  /// [androidDefaultIcon]
  ///
  /// Used in [AndroidInitializationSettings].
  Future<void> init({
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    String androidDefaultIcon = '@mipmap/launcher_icon',
  }) async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _androidChannelId, // id
      _androidChannelName, // name
      description: _androidChannelDescription, // description
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _localNotifications.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings(androidDefaultIcon),
        iOS: const DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  Future<void> show({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    await _localNotifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
    _lastNotificationId = id;
  }

  Future<void> cancel(int id, {String? tag}) =>
      _localNotifications.cancel(id, tag: tag);

  Future<void> cancelAll() => _localNotifications.cancelAll();
}
