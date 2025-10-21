import 'package:flutter/widgets.dart';
import 'package:metal/features/thought/repositories/home.repository.dart';
import 'package:metal/fcm/fcm_client.dart';

class AppLifecycleHandler extends WidgetsBindingObserver {
  final String userId;
  DateTime? _lastOfflineTime;
  DateTime? _lastOnlineTime;

  AppLifecycleHandler(this.userId);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final repo = HomeRepository();
    final now = DateTime.now();

    // Add debouncing to prevent rapid state changes
    switch (state) {
      case AppLifecycleState.resumed:
        // User is back and app is active
        _lastOnlineTime = now;
        repo.markUserOnline(userId).catchError((error) {
          print(
              'Error marking user online (user may have been deleted): $error');
        });

        // Process any pending notifications when app resumes
        FCMClient.instance.onAppResumed().catchError((error) {
          print('Error processing pending notifications: $error');
        });
        break;

      case AppLifecycleState.inactive:
        // App is inactive but still visible (e.g., incoming call, control center)
        // Don't mark offline immediately - this is often temporary
        print('App is inactive - not marking offline yet');
        break;

      case AppLifecycleState.hidden:
        // App is hidden but not paused (iOS specific)
        // Don't mark offline immediately - user might come back quickly
        print('App is hidden - not marking offline yet');
        break;

      case AppLifecycleState.paused:
        // App is paused and not visible
        _markUserOfflineWithDelay(repo, now);
        break;

      case AppLifecycleState.detached:
        // App is detached from the engine (closing)
        _lastOfflineTime = now;
        repo.markUserOffline(userId).catchError((error) {
          print(
              'Error marking user offline (user may have been deleted): $error');
        });
        break;
    }
  }

  void _markUserOfflineWithDelay(HomeRepository repo, DateTime pauseTime) {
    // Add a small delay to handle quick app switches
    Future.delayed(const Duration(seconds: 2), () {
      // Only mark offline if we haven't come back online in the meantime
      if (_lastOnlineTime == null || _lastOnlineTime!.isBefore(pauseTime)) {
        _lastOfflineTime = pauseTime;
        repo.markUserOffline(userId).catchError((error) {
          print(
              'Error marking user offline (user may have been deleted): $error');
        });
      }
    });
  }
}
