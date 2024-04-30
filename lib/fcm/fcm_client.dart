// todo starter: uncomment code when google services files are added (.json and .plist)

// todo starter: also enable google gms plugin at [android/app/build.gradle]
// todo starter: enable firebase messaging implementation at [android/app/build.gradle]
// todo starter: uncomment code at SAApp.kt
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/fcm/local_notifications.dart';
 
import 'package:synchronized/synchronized.dart';

import 'abstract_notification_dispatcher.dart';
import 'models/notification_payload_model.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

 
class FCMClient {
  FCMClient._();

 

  static final FCMClient instance = FCMClient._();
  static bool _isInit = false;
  final container = ProviderContainer();
 
  final _fCMLock = Lock();

  final _localNotifications = LocalNotifications();

  /// Stream of messages when app is opened in foreground.
  late StreamSubscription _onMessageSub;

  /// Stream of messages when app is in background and opened from notification.
  late StreamSubscription _onMessageOpenedAppSub;

  // todo: after fcm init on splash check this message is not null and do navigation if needed.
  RemoteMessage? initialMessage;

  /// Stream for detecting FCM token refresh
  Stream<String> get tokenRefreshStream => _firebaseMessaging.onTokenRefresh;

 
  Future<String?> init() async {
    return _fCMLock.synchronized(() async {
      if (_isInit) {
        return _firebaseMessaging.getToken();
      }
 
      await _firebaseMessaging.requestPermission();

      _firebaseMessaging.onTokenRefresh.listen((token) {
         print('fcm token refreshed: $token');
      });

   
      initialMessage = await _firebaseMessaging.getInitialMessage();
      _log(initialMessage, name: 'initialMessage');

      if (initialMessage != null) {
        final payload =
            NotificationPayloadModel.fromRemoteMessage(initialMessage!);
        Future.delayed(
            const Duration(seconds: 2), () => _onTapNotification(payload));
      }

      _onMessageSub = FirebaseMessaging.onMessage.listen(_onMessage);
      _onMessageOpenedAppSub =
          FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);


      await _localNotifications.init(
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

     await _firebaseMessaging.subscribeToTopic("dev");

      final token = await _firebaseMessaging.getToken();
      print('fcm token: $token');
      _isInit = true;

      if (token != null)
        // container
        //     .read(authenticationNotifierProvider.notifier)
        //     .updateToken(token);
      // _auth.updateToken(token);

      tokenRefreshStream.listen((event) {
        // container
        //     .read(authenticationNotifierProvider.notifier)
        //     .updateToken(event);
      });

      return token;
    });
  }

  void disableMessagesHandle() {
    _onMessageSub.cancel();
    _onMessageOpenedAppSub.cancel();
  }

  /// Handle push notification when the app in foreground state.
  ///
  /// In this method, we can show local notification when the app
  /// is running and on screen.
  ///
  /// Sequencing:
  /// 1. The app in foreground state
  /// 2. [_onMessage] runs.
  /// FCM doesn't show push notification automatically
  Future<void> _onMessage(RemoteMessage message) async {
    _log(message, name: 'onMessage');
    final payload = NotificationPayloadModel.fromRemoteMessage(message);
    await _localNotifications.show(
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      payload: payload.toJson(),
    );
  }

  /// Handle tap on notification when the app is open from background state.
  ///
  /// Sequencing:
  /// 1. The app in background state (not terminated/killed)
  /// 2. FCM shows push notification
  /// 3. User taps notification
  /// 4. The app is open
  /// 5. [_onMessageOpenedApp] runs
  void _onMessageOpenedApp(RemoteMessage message) {
    _log(message, name: 'onMessageOpenedApp');
    final payload = NotificationPayloadModel.fromRemoteMessage(message);
    _onTapNotification(payload);
  }

  /// Handle tap on notification that we shown in [_onMessage].
  ///
  /// Sequencing:
  /// 1. We show local notification by [LocalNotifications.show]
  /// 2. User taps notification
  /// 3. If the app in background, it opens and comes to foreground
  /// 4. [_onDidReceiveNotificationResponse] runs
  Future<void> _onDidReceiveNotificationResponse(
    NotificationResponse? notificationResponse,
  ) async {
    final payloadModel =
        NotificationPayloadModel.fromJson(notificationResponse?.payload ?? '');
    await _onTapNotification(payloadModel);
  }

  /// Handle tap on notification when the app in background or foreground.
  ///
  /// For handle tap when the app is terminated/killed, use [initialMessage].
  Future<void> _onTapNotification(NotificationPayloadModel payload) async {
    print('232 this is onTap payload : $payload');
    await PushDispatcher.dispatchNotification(payload, removeUntil: true);
  }

  void _log(RemoteMessage? message, {String? name}) {
    if (message != null) {
      print(
        '$name: title ${message.notification?.title}, '
        'body: ${message.notification?.body}, '
        'data: ${message.data}',
      );
    }
  }
}
