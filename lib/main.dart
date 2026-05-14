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
import 'package:metal/core/services/shorebird_update_service.dart';

import 'package:metal/fcm/app_icon_badge.dart';
import 'package:metal/core/services/deep_link_service.dart';
import 'package:metal/core/di/provider_setup.dart';
import 'package:metal/core/utils/permission_helper.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Only initialize if not already done (e.g. Android can auto-initialize via google-services)
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  try {
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  } catch (e) {
    debugPrint('Firebase Analytics setup failed: $e');
  }
  try {
    await FirebaseRemoteConfigService().initialize();
  } catch (e) {
    debugPrint('Firebase Remote Config initialization failed (app will continue): $e');
    // Remote Config can fail on Android due to network/API; don't block startup
  }
  // Set the background messaging handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize FCM client early to avoid APNS token issues
  try {
    await FCMClient.instance.init();
  } catch (e) {
    print('FCM initialization in main failed: $e');
    // Continue app startup even if FCM fails
  }

  // Initialize Shorebird Code Push for OTA updates
  // CRITICAL: Initialize Shorebird BEFORE running the app to prevent splash screen hang
  // With auto_update enabled in shorebird.yaml, patches will be automatically downloaded
  // but we need to wait for initialization to complete to prevent the app from getting stuck
  try {
    debugPrint('Initializing Shorebird before app startup...');
    // Initialize and wait for Shorebird to be ready
    // This prevents the app from getting stuck on splash screen after patch application
    await ShorebirdUpdateService.instance.initialize();
    debugPrint('Shorebird initialization complete');
  } catch (e) {
    debugPrint('Shorebird initialization/update check failed: $e');
    // Continue app startup even if Shorebird fails to prevent app from hanging
  }

  // Initialize SharedPreferences eagerly before app starts
  SharedPreferences sharedPreferences;
  try {
    sharedPreferences = await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('SharedPreferences init failed: $e');
    rethrow;
  }

  // Initialize the lifecycle handler (handles its own auth state changes)
  final lifecycleHandler = AppLifecycleHandler();
  WidgetsBinding.instance.addObserver(lifecycleHandler);
  try {
    await lifecycleHandler.initialize();
  } catch (e) {
    debugPrint('AppLifecycleHandler init failed: $e');
    // Continue so app still launches
  }

  // Clear any stale app icon badge from previous sessions
  await AppIconBadge.clear();

  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://f13d648fc1ed4066516aa53c150ae36c@o4510908276801536.ingest.us.sentry.io/4511325235052544';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
    },
    appRunner: () {
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        Sentry.captureException(
          details.exception,
          stackTrace: details.stack,
        );
      };
      runApp(
        SentryWidget(
          child: ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            ],
            child: const MyApp(),
          ),
        ),
      );
    },
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  static const int _maxDeepLinkInitRetries = 10;

  @override
  void initState() {
    super.initState();
    //  ref.read(authProvider.notifier).initZIMKIt();
    // ref.read(updateProfileProvider.notifier);

    // Request microphone and camera permissions on iOS after app is initialized
    // Using post-frame callback to ensure app is fully running
    WidgetsBinding.instance.addPostFrameCallback((_) => _onFirstFrameReady(ref));
  }

  /// Called after first frame. Initializes DeepLinkService only when navigator
  /// context is available (avoids crash on Android where context can be null
  /// on first frame in release builds).
  void _onFirstFrameReady(WidgetRef ref, [int retryCount = 0]) async {
    try {
      await PermissionHelper.requestIOSMediaPermissionsOnLaunch();
    } catch (e) {
      print('iOS media permissions request failed: $e');
    }

    final context = navKey.currentContext;
    if (context != null && context.mounted) {
      try {
        final secureStorage = ref.read(secureStorageHelperProvider);
        final sharedPrefs = ref.read(sharedPrefsHelperProvider);
        DeepLinkService.instance.initialize(
          context,
          secureStorage: secureStorage,
          sharedPrefs: sharedPrefs,
        );
      } catch (e) {
        print('DeepLinkService initialization failed: $e');
      }
      return;
    }

    if (retryCount < _maxDeepLinkInitRetries && mounted) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _onFirstFrameReady(ref, retryCount + 1),
      );
    }
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
