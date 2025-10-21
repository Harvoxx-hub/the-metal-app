import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:metal/fcm/local_notifications.dart';
import 'package:metal/fcm/models/push_type.dart';
import 'package:synchronized/synchronized.dart';
import 'package:metal/core/services/notification_navigation_service.dart';
import 'package:metal/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

        // Process any pending notifications after initialization
        WidgetsBinding.instance.addPostFrameCallback((_) {
          processPendingNotifications();
        });

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

  /// Process pending notifications when app comes to foreground
  Future<void> onAppResumed() async {
    print('FCMClient: App resumed, processing pending notifications');
    await processPendingNotifications();
  }

  /// Handle push notification when the app in foreground state.
  Future<void> _onMessage(RemoteMessage message) async {
    print(
        'onMessage: title ${message.notification?.title}, body: ${message.notification?.body}');
    final payload = NotificationPayloadModel.fromRemoteMessage(message);
    final pushType = PushType.valueOf(payload.data?["type"]);

    // Handle melt notifications differently in foreground
    if (pushType == PushType.new_connection) {
      await _handleMeltNotificationInForeground(payload);
    } else {
      // Show local notification for other types
      await _localNotifications.show(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        payload: jsonEncode(payload.toJson()),
      );
    }
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
    await _handleNotificationNavigation(payload);
  }

  /// Handle notification navigation based on payload
  Future<void> _handleNotificationNavigation(
      NotificationPayloadModel payload) async {
    // Wait for context to be available with retry mechanism
    final context = await _waitForNavigationContext();
    if (context == null) {
      await _storePendingNotification(payload);
      return;
    }

    try {
      await NotificationNavigationService.instance
          .navigateFromPayload(payload, context);
    } catch (e) {
      await _storePendingNotification(payload);
    }
  }

  /// Wait for navigation context to be available with retry mechanism
  Future<BuildContext?> _waitForNavigationContext() async {
    const maxAttempts = 20; // Increased from 10 to 20
    const delay =
        Duration(milliseconds: 250); // Reduced delay for faster response

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      final context = navKey.currentContext;
      if (context != null) {
        return context;
      }

      await Future.delayed(delay);
    }

    return null;
  }

  /// Store pending notification for later processing
  Future<void> _storePendingNotification(
      NotificationPayloadModel payload) async {
    try {
      // Store in SharedPreferences for persistence across app restarts
      final prefs = await SharedPreferences.getInstance();
      final pendingNotifications =
          prefs.getStringList('pending_notifications') ?? [];

      final notificationData = {
        'payload': payload.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
        'attempts': 0,
      };

      pendingNotifications.add(jsonEncode(notificationData));
      await prefs.setStringList('pending_notifications', pendingNotifications);
    } catch (e) {
      print('FCMClient: Error storing pending notification: $e');
    }
  }

  /// Process any pending notifications when context becomes available
  Future<void> processPendingNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingNotifications =
          prefs.getStringList('pending_notifications') ?? [];

      if (pendingNotifications.isEmpty) {
        return;
      }

      final context = navKey.currentContext;
      if (context == null) {
        return;
      }

      final List<String> processedNotifications = [];

      for (final notificationJson in pendingNotifications) {
        try {
          final notificationData = jsonDecode(notificationJson);
          final payload =
              NotificationPayloadModel.fromJson(notificationData['payload']);
          final attempts = (notificationData['attempts'] ?? 0) + 1;

          // Limit retry attempts
          if (attempts > 3) {
            processedNotifications.add(notificationJson); // Mark as processed
            continue;
          }

          await NotificationNavigationService.instance
              .navigateFromPayload(payload, context);

          processedNotifications.add(notificationJson); // Mark as processed
        } catch (e) {
          // Update attempt count and keep for retry
          final notificationData = jsonDecode(notificationJson);
          notificationData['attempts'] =
              (notificationData['attempts'] ?? 0) + 1;
          processedNotifications.add(jsonEncode(notificationData));
        }
      }

      // Update stored notifications (remove processed ones)
      await prefs.setStringList(
          'pending_notifications',
          pendingNotifications
              .where((n) => !processedNotifications.contains(n))
              .toList());
    } catch (e) {}
  }

  /// Handle melt notification when app is in foreground
  Future<void> _handleMeltNotificationInForeground(
      NotificationPayloadModel payload) async {
    print('FCMClient: Handling melt notification in foreground');

    try {
      final context = await _waitForNavigationContext();
      if (context == null) {
        print('FCMClient: Context not available, showing notification');
        await _showFallbackNotification(payload);
        return;
      }

      // Use navigation service to handle the melt notification
      await NotificationNavigationService.instance
          .navigateFromPayload(payload, context);
    } catch (e) {
      print('FCMClient: Error handling melt notification: $e');
      await _showFallbackNotification(payload);
    }
  }

  /// Show fallback notification when navigation fails
  Future<void> _showFallbackNotification(
      NotificationPayloadModel payload) async {
    await _localNotifications.show(
      title: payload.title ?? 'New Connection',
      body: payload.body ?? 'Someone wants to melt metal with you!',
      payload: jsonEncode(payload.toJson()),
    );
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
