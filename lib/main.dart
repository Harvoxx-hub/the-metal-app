import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/services/auth.pref.service.dart';
import 'package:metal/core/services/firebase.remote.config.service.dart';
import 'package:metal/core/services/update_service.dart';
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

  final navigatorKey = GlobalKey<NavigatorState>();
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize ZegoUIKit with signaling plugin and system calling UI
  await ZegoUIKit().initLog();
  ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
    [ZegoUIKitSignalingPlugin()],
  );

  await initializeFirebase();
  initializeAuthManager();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
  // final userId = FirebaseAuth.instance.currentUser?.uid;

  // if (userId != null) {
  //   WidgetsBinding.instance.addObserver(AppLifecycleHandler(userId));
  // }
}

/// Initializes Firebase and sets analytics
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

  final UpdateService _updateService = UpdateService();

  @override
  Widget build(BuildContext context) {
    _updateService.checkForUpdates();
    return MaterialApp(
      title: 'Metal',
      key: navKey,
      initialRoute: '/',
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
