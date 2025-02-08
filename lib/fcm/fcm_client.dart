import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

class FCMClient {
  FCMClient._();

  static final FCMClient instance = FCMClient._();
  static bool _isInit = false;
  final container = ProviderContainer();

  /// Stream for detecting FCM token refresh
  Stream<String> get tokenRefreshStream => _firebaseMessaging.onTokenRefresh;

  Future<String?> init() async {
    if (_isInit) {
      return _firebaseMessaging.getToken();
    }

    // Request permission for notifications (optional, depending on your use case)
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Enable auto-init for Android (optional, depending on your use case)
    if (Platform.isAndroid) {
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((token) {
      print('FCM token refreshed: $token');
    });

    // Get the current FCM token
    final token = await _firebaseMessaging.getToken();
    print('FCM token: $token');
    _isInit = true;

    return token;
  }
}