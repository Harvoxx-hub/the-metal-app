import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:metal/fcm/local_notifications.dart';
import 'package:synchronized/synchronized.dart';
import 'package:metal/core/services/notification_navigation_service.dart';
import 'package:metal/main.dart';

import 'models/notification_payload_model.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

class FCMClient {
  FCMClient._();

  static final FCMClient instance = FCMClient._();
  static bool _isInit = false;
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
        // Request notification permissions
        await _requestPermissions();

        // Set platform-specific settings
        await _configurePlatformSettings();

        // Handle initial message
        await _handleInitialMessage();

        // Set up message listeners
        _setupMessageListeners();

        // Initialize local notifications
        await _localNotifications.init(
          onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
        );

        // Subscribe to dev topic
        await _firebaseMessaging.subscribeToTopic("dev");

        // Get FCM token
        final token = await _getFCMToken();
        if (token != null) {
          await _updateFCMToken(token);
          tokenRefreshStream.listen(_updateFCMToken);
        }

        _isInit = true;
        return token;
      } catch (e) {
        print('Error initializing FCM: $e');
        return null;
      }
    });
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  /// Configure platform-specific settings
  Future<void> _configurePlatformSettings() async {
    if (Platform.isAndroid) {
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
    }

    if (Platform.isIOS) {
      await _ensureAPNSToken();
    }

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Handle initial message when app is opened from notification
  Future<void> _handleInitialMessage() async {
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      final payload =
          NotificationPayloadModel.fromRemoteMessage(initialMessage);
      Future.delayed(
        const Duration(seconds: 2),
        () => _onTapNotification(payload),
      );
    }
  }

  /// Set up message listeners
  void _setupMessageListeners() {
    _onMessageSub = FirebaseMessaging.onMessage.listen(_onMessage);
    _onMessageOpenedAppSub =
        FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
  }

  /// Get FCM token with error handling
  Future<String?> _getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      if (Platform.isIOS && e.toString().contains('APNS token')) {
        await Future.delayed(const Duration(seconds: 2));
        try {
          return await _firebaseMessaging.getToken();
        } catch (retryError) {
          print('Retry getting FCM token failed: $retryError');
          return null;
        }
      }
      return null;
    }
  }

  /// Update FCM token in backend
  Future<void> _updateFCMToken(String token) async {
    try {
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
  Future<void> _onMessage(RemoteMessage message) async {
    print(
        'onMessage: title ${message.notification?.title}, body: ${message.notification?.body}');
    final payload = NotificationPayloadModel.fromRemoteMessage(message);
    await _localNotifications.show(
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      payload: jsonEncode(payload.toJson()),
    );
  }

  /// Handle tap on notification when the app is open from background state.
  void _onMessageOpenedApp(RemoteMessage message) {
    print(
        'onMessageOpenedApp: title ${message.notification?.title}, body: ${message.notification?.body}');
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
    await _handleNotificationNavigation(payload);
  }

  /// Handle notification navigation based on payload
  Future<void> _handleNotificationNavigation(
      NotificationPayloadModel payload) async {
    final context = navKey.currentContext;
    if (context == null) {
      print(
          'No navigation context available for notification: ${payload.action?.value}');
      return;
    }

    try {
      await NotificationNavigationService.instance
          .navigateFromPayload(payload, context);
      print('Notification navigation completed for: ${payload.action?.value}');
    } catch (e) {
      print('Error navigating from notification: $e');
    }
  }

  /// Ensure APNS token is set for iOS
  Future<void> _ensureAPNSToken() async {
    if (!Platform.isIOS) return;

    try {
      final apnsToken = await _firebaseMessaging.getAPNSToken();
      if (apnsToken == null) {
        await Future.delayed(const Duration(seconds: 1));
        await _firebaseMessaging.getAPNSToken();
      }
    } catch (e) {
      print('Error getting APNS token: $e');
    }
  }
}
