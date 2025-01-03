import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/services/auth.pref.service.dart';
import 'package:metal/core/services/firebase.remote.config.service.dart';
import 'package:metal/core/utils/handler/app.lifeycle.handler.dart';
import 'package:metal/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:metal/route/routes.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:instabug_flutter/instabug_flutter.dart';

final navKey = GlobalKey<NavigatorState>();
NavigatorState? get nav => navKey.currentState;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeFirebase();
    await initializeAuthManager();
    debugPrint("Initialization Firebase");
  } catch (e, stacktrace) {
    debugPrint("Initialization error: $e");
    debugPrint(stacktrace.toString());
  }

  Instabug.init(
    token: "35773fb6523ba7aa0ca63a8bb8d55099",
    invocationEvents: [
      InvocationEvent.shake,
      InvocationEvent.screenshot,
    ],
  );
  CrashReporting.setEnabled(true);

  runApp(const ProviderScope(child: MyApp()));

  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId != null) {
    WidgetsBinding.instance.addObserver(AppLifecycleHandler(userId));
  }
}

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    await FirebaseRemoteConfigService().initialize();
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }
}

Future<void> initializeAuthManager() async {
  try {
    await AuthManager.ensureInitialized();
  } catch (e) {
    debugPrint('Error initializing AuthManager: $e');
  }
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
