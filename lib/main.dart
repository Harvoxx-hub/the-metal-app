import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/services/auth.pref.service.dart';
import 'package:metal/core/services/firebase.remote.config.service.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/core/utils/handler/app.lifeycle.handler.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:metal/route/routes.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

/// Global key for navigation
final navKey = GlobalKey<NavigatorState>();

/// Convenience getter for accessing the current [NavigatorState]
NavigatorState? get nav => navKey.currentState;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeFirebase();
  initializeAuthManager();

  // Create a ProviderContainer to access providers outside the widget tree
  final container = ProviderContainer();
  final authNotifier = container.read(authProvider.notifier);

  // Fetch the current user
  authNotifier.getCurrentUser();
  final userData = container.read(authProvider).data;

  if (userData != null) {
    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: 918677174,
      appSign:
          'a593a3eacbd96523d72730d336acaf02574848a9fda4f4fdb3110cb18b3c23f0',
      userID: userData.id!,
      userName: userData.username!,
      plugins: [ZegoUIKitSignalingPlugin()],
    );

    // Add app lifecycle handler
    WidgetsBinding.instance.addObserver(AppLifecycleHandler(userData.id!));
  } else {
    debugPrint("Failed to initialize call service. No user data found.");
  }

  DateTime now = DateTime.now();

  String postFromNigeria = formatTime(
    datetime: now,
  );

  String postFromCanada = formatTime(
    datetime: now.subtract(const Duration(hours: 2)),
  );

  debugPrint('Post from Nigeria: $postFromNigeria');
  debugPrint('Post from Canada: $postFromCanada');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId != null)
    WidgetsBinding.instance.addObserver(AppLifecycleHandler(userId));
}

/// Initializes Firebase and sets analytics
Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    await FirebaseRemoteConfigService().initialize();
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
