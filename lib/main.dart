import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metal/core/services/firebase.remote.config.service.dart';
import 'package:metal/core/utils/handler/app.lifeycle.handler.dart';

import 'package:metal/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:metal/route/routes.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:metal/fcm/fcm_client.dart';

import 'package:metal/core/services/deep_link_service.dart';
import 'package:metal/core/di/provider_setup.dart';
import 'package:metal/core/utils/permission_helper.dart';

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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  await FirebaseRemoteConfigService().initialize();
  // Set the background messaging handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize FCM client early to avoid APNS token issues
  try {
    await FCMClient.instance.init();
  } catch (e) {
    print('FCM initialization in main failed: $e');
    // Continue app startup even if FCM fails
  }

  // Initialize SharedPreferences eagerly before app starts
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize the lifecycle handler (handles its own auth state changes)
  final lifecycleHandler = AppLifecycleHandler();
  WidgetsBinding.instance.addObserver(lifecycleHandler);
  await lifecycleHandler.initialize();

  runApp(
    ProviderScope(
      overrides: [
        // Override sharedPreferencesProvider with pre-initialized instance
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );

  // Initialize deep link service
  WidgetsBinding.instance.addPostFrameCallback((_) {
    DeepLinkService.instance.initialize(navKey.currentContext!);
  });
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

    // Request microphone and camera permissions on iOS after app is initialized
    // Using post-frame callback to ensure app is fully running
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await PermissionHelper.requestIOSMediaPermissionsOnLaunch();
      } catch (e) {
        print('iOS media permissions request failed: $e');
      }
    });
  }

  /// Check if a route name is numeric (likely an ID from deep link)
  bool _isNumericRoute(String routeName) {
    // Remove leading slash and check if it's a numeric string
    final cleanRoute =
        routeName.startsWith('/') ? routeName.substring(1) : routeName;
    return RegExp(r'^\d+$').hasMatch(cleanRoute);
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
            // ZegoUIKitPrebuiltCallMiniOverlayPage(
            //   contextQuery: () => navKey.currentState!.context,
            // ),
          ],
        );
      },
      initialRoute: '/',
      onGenerateRoute: (settings) {
        print('settings.name: ${settings.name}');

        // Block Flutter's automatic routing for deep link paths
        // These paths should be handled by DeepLinkService instead
        final routeName = settings.name;
        if (routeName != null) {
          // Block routes that match deep link patterns
          // But allow /thoughtDetails when it comes from deep link service
          if (routeName.startsWith('/thought/') ||
              routeName.startsWith('/user/') ||
              routeName.startsWith('/community/') ||
              _isNumericRoute(routeName)) {
            print('Blocking automatic route for deep link: $routeName');
            return null; // Let DeepLinkService handle this
          }
        }

        return AppRoutes.generateRoute(settings);
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
