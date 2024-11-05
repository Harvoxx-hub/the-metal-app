import 'package:cr_logger/cr_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/services/auth.pref.service.dart';
import 'package:metal/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:metal/route/routes.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:upgrader/upgrader.dart';

/// Global key for navigation
final navKey = GlobalKey<NavigatorState>();

/// Convenience getter for accessing the current [NavigatorState]
NavigatorState? get nav => navKey.currentState;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeFirebase();
  await initializeAuthManager();
  await initializeCRLogger();
  await initializeSentry();

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
  } catch (e) {
  log.i("Failed to initialize Firebase: $e");
  }
}

/// Ensures that the [AuthManager] is properly initialized
Future<void> initializeAuthManager() async {
  await AuthManager.ensureInitialized();
}

/// Initializes CRLogger with custom settings
Future<void> initializeCRLogger() async {
  await CRLoggerInitializer.instance.init(
    useDatabase: true,
    printLogs: true,
    printLogsCompactly: true,
    useCrLoggerInReleaseBuild: true,
    theme: ThemeData.light(),
    levelColors: {
      Level.debug: Colors.lightGreenAccent,
      Level.warning: Colors.orange,
      Level.trace: Colors.blueAccent,
      Level.info: Colors.blueAccent,
      Level.error: Colors.red,
      Level.fatal: Colors.red.shade900,
      Level.off: Colors.grey.shade300,
      Level.all: Colors.grey.shade300,
    },
    hiddenFields: [
      'Test',
      'Test3',
      'Test7',
      'freeform',
      'qwe',
    ],
    hiddenHeaders: [
      'content-type',
      'Test3',
      'Authorization',
    ],
    logFileName: 'my_logs',
  );

  // Set application-specific information for logging
  CRLoggerInitializer.instance.appInfo = {
    'Build type': 'release',
    'Endpoint': 'https://metal-server.vercel.app/api/v1',
  };

  // Optionally set up proxy for logging (e.g., Charles Proxy)
  final proxy = CRLoggerInitializer.instance.getProxySettings();
  if (proxy != null) {
    // RestClient.instance.initDioProxyForCharles(proxy);
  }

  // Define what happens when logs are shared
  CRLoggerInitializer.instance.onShareLogsFile = (String path) async {
    await Share.shareXFiles([XFile(path)]);
  };
}

/// Initializes Sentry for error tracking and performance monitoring
Future<void> initializeSentry() async {
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://db967fb52e009f50806bff1ee19d3588@o4507616949370880.ingest.us.sentry.io/4507616953499648';
      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;
    },
  );
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
        builder: (context, child) => CrInspector(child: child!),
      title: 'Metal',
      key: navKey,
      initialRoute: '/',
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
