import 'package:flutter/widgets.dart';
import 'package:metal/features/home_page/data/repositories/home.repository.dart';

class AppLifecycleHandler extends WidgetsBindingObserver {
  final String userId;

  AppLifecycleHandler(this.userId);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final repo = HomeRepository();

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      repo.markUserOffline(userId);
    } else if (state == AppLifecycleState.resumed) {
      
      repo.markUserOnline(userId);
    }
  }
}
