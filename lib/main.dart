import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/services/firebase.remote.config.service.dart';
import 'package:metal/core/utils/handler/app.lifeycle.handler.dart';

import 'package:metal/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:metal/firebase_options_dev.dart' show DefaultFirebaseOptionDev;
import 'package:metal/route/routes.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:metal/fcm/fcm_client.dart';
import 'package:metal/app_config.dart';
import 'package:metal/core/services/firebase_test_service.dart';

/// Global key for navigation
final navKey = GlobalKey<NavigatorState>();

// Convenience getter for accessing the current [NavigatorState]
//NavigatorState? get nav => navKey.currentState;

// Must be top-level function (not a class method)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // Ensure Firebase is initialized in the background isolate
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print("Handling a background message: ${message.messageId}");
  print('Message data: ${message.data}');
  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification}');
  }
  // You might need to add specific Zego handling here if just receiving the message isn't enough,
  // but often, Zego's SDK handles the call UI presentation automatically once the message is delivered.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock app to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize app configuration based on environment
  // This should be set via build arguments or environment variables
  const environment = String.fromEnvironment('FLAVOR', defaultValue: 'prod');
  AppConfig.init(flavour: Flavour.valueOf(environment));

  await initializeFirebase(
      environment); // Pass environment to Firebase initialization

  // Test Firebase connection
  await FirebaseTestService.testFirebaseConnection();
  FirebaseTestService.printEnvironmentInfo();

  // Set the background messaging handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize FCM client early to avoid APNS token issues
  try {
    await FCMClient.instance.init();
  } catch (e) {
    print('FCM initialization in main failed: $e');
    // Continue app startup even if FCM fails
  }

// // Initialize Shorebird
//   final shorebirdCodePush = ShorebirdCodePush();
//   await shorebirdCodePush.downloadUpdateIfAvailable();

  // Set navigator key
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navKey);

  await ZegoUIKit().initLog().then((value) {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );
  });

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId != null) {
    WidgetsBinding.instance.addObserver(AppLifecycleHandler(userId));
  }
}

/// Initializes Firebase and sets analytics based on environment
Future<void> initializeFirebase(String environment) async {
  try {
    if (environment == 'dev') {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptionDev.currentPlatform);
    } else {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    }
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    await FirebaseRemoteConfigService().initialize();
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
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
    //  ref.read(authProvider.notifier).initZIMKIt();
    // ref.read(updateProfileProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navKey,
      title: 'Metal',
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            ZegoUIKitPrebuiltCallMiniOverlayPage(
              contextQuery: () => navKey.currentState!.context,
            ),
          ],
        );
      },
      initialRoute: '/',
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
