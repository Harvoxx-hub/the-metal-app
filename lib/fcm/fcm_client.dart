import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/fcm/local_notifications.dart';
 
import 'package:metal/core/services/notification_handler.dart';
import 'package:synchronized/synchronized.dart';

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

  /// Stream for detecting FCM token refresh
  Stream<String> get tokenRefreshStream => _firebaseMessaging.onTokenRefresh;

  Future<String?> init() async {
    return _fCMLock.synchronized(() async {
      if (_isInit) {
        return _firebaseMessaging.getToken();
      }

      try {
        // Request notification permissions first
        await _firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        if (Platform.isAndroid) {
          await FirebaseMessaging.instance.setAutoInitEnabled(true);
        }

        // For iOS, ensure APNS token is set before getting FCM token
        if (Platform.isIOS) {
          await _ensureAPNSToken();
        }

        // Set the foreground notification presentation options
        FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        // Handle initial message
        final initialMessage = await _firebaseMessaging.getInitialMessage();
        if (initialMessage != null) {
          final payload =
              NotificationPayloadModel.fromRemoteMessage(initialMessage);
          Future.delayed(
            const Duration(seconds: 2),
            () => _onTapNotification(payload),
          );
        }

        // Set up message listeners
        _onMessageSub = FirebaseMessaging.onMessage.listen(_onMessage);
        _onMessageOpenedAppSub =
            FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

        // Initialize local notifications
        await _localNotifications.init(
          onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
        );

        // Subscribe to dev topic
        await _firebaseMessaging.subscribeToTopic("dev");

        // Get and handle FCM token with proper error handling
        String? token;
        try {
          token = await _firebaseMessaging.getToken();
        } catch (e) {
          print('Error getting FCM token: $e');
          // If it's an APNS token error, try to get the APNS token first
          if (Platform.isIOS && e.toString().contains('APNS token')) {
            try {
              // Wait a bit for APNS token to be set
              await Future.delayed(const Duration(seconds: 2));
              token = await _firebaseMessaging.getToken();
            } catch (retryError) {
              print('Retry getting FCM token failed: $retryError');
              // Return null but don't fail the initialization
              token = null;
            }
          } else {
            // For other errors, return null but don't fail the initialization
            token = null;
          }
        }

        if (token != null) {
          await _updateFCMToken(token);

          // Listen for token refresh
          tokenRefreshStream.listen(_updateFCMToken);
        }

        _isInit = true;
        return token;
      } catch (e) {
        print('Error initializing FCM: $e');
        // Return null but don't throw to prevent app crashes
        return null;
      }
    });
  }

  Future<void> _updateFCMToken(String token) async {
    try {
      // Uncomment this to update the FCM token in your backend
      // await container
      //     .read(authenticationNotifierProvider.notifier)
      //     .updateToken(token);

      // TODO: Implement proper token update once you know the correct provider
      print('FCM token updated: $token');
    } catch (e) {
      print('Error updating FCM token: $e');
    }
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
      payload: jsonEncode(payload.toJson()),
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
    if (notificationResponse?.payload == null) return;

    final payloadModel = NotificationPayloadModel.fromJson(
      jsonDecode(notificationResponse!.payload!),
    );
    await _onTapNotification(payloadModel);
  }

  /// Handle tap on notification when the app in background or foreground.
  ///
  /// For handle tap when the app is terminated/killed, use [initialMessage].
  Future<void> _onTapNotification(NotificationPayloadModel payload) async {
    print('Handling notification tap with payload: $payload');
    await NotificationHandlerService.instance
        .handleFCMNotification(payload, removeUntil: true);
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

  /// Ensure APNS token is set for iOS
  Future<void> _ensureAPNSToken() async {
    if (!Platform.isIOS) return;

    try {
      // Get the APNS token
      final apnsToken = await _firebaseMessaging.getAPNSToken();
      print('APNS token: $apnsToken');

      if (apnsToken == null) {
        // Wait a bit and try again
        await Future.delayed(const Duration(seconds: 1));
        final retryToken = await _firebaseMessaging.getAPNSToken();
        print('Retry APNS token: $retryToken');
      }
    } catch (e) {
      print('Error getting APNS token: $e');
    }
  }
}
