import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/services/auth.pref.service.dart';
import 'package:metal/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:metal/route/routes.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:share_plus/share_plus.dart';
import 'package:upgrader/upgrader.dart';
import 'package:instabug_flutter/instabug_flutter.dart';

/// Global key for navigation
final navKey = GlobalKey<NavigatorState>();

/// Convenience getter for accessing the current [NavigatorState]
NavigatorState? get nav => navKey.currentState;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeFirebase();
  initializeAuthManager();

  Instabug.init(token: "35773fb6523ba7aa0ca63a8bb8d55099", invocationEvents: [
    InvocationEvent.shake,
    InvocationEvent.screenshot,
  ]);
  CrashReporting.setEnabled(true);
  runApp(
    ProviderScope(
      child: UpgradeAlert(
        dialogStyle: UpgradeDialogStyle.cupertino,
        child: const MyApp(),
      ),
    ),
  );
}

/// Initializes Firebase and sets analytics
Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  } catch (e) {}
}

Future<void> initializeAuthManager() async {
  await AuthManager.ensureInitialized();
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metal',
      key: navKey,
      initialRoute: '/',
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
