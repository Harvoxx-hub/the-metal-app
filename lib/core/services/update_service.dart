<<<<<<< HEAD
 
=======
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:metal/core/services/firebase.remote.config.service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  final FirebaseRemoteConfig _remoteConfig =
      FirebaseRemoteConfigService().remoteConfig;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  UpdateService() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> checkForUpdates() async {
    await _remoteConfig.fetchAndActivate();
    final String latestVersion = _remoteConfig.getString('latest_version');
    final String updateMessage = _remoteConfig.getString('update_message');

    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String currentVersion = packageInfo.version;

    if (_isUpdateAvailable(currentVersion, latestVersion)) {
      _showUpdateNotification(updateMessage);
    }
  }

  bool _isUpdateAvailable(String currentVersion, String latestVersion) {
    final List<String> currentParts = currentVersion.split('.');
    final List<String> latestParts = latestVersion.split('.');

    for (int i = 0; i < latestParts.length; i++) {
      final int currentPart = int.parse(currentParts[i]);
      final int latestPart = int.parse(latestParts[i]);

      if (latestPart > currentPart) {
        return true;
      } else if (latestPart < currentPart) {
        return false;
      }
    }
    return false;
  }

  Future<void> _showUpdateNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'update_channel',
      'Update Notifications',
      channelDescription: 'Notifications for app updates',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _notificationsPlugin.show(
      0,
      'New Update Available',
      message,
      platformChannelSpecifics,
    );
  }
}
>>>>>>> dev
