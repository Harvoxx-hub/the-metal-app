import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/services/auth.pref.service.dart';

import 'package:metal/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:metal/route/routes.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

final navKey = GlobalKey<NavigatorState>();

NavigatorState? get nav => navKey.currentState;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // if (Platform.isIOS || Platform.isMacOS) {
  //   StoreConfig(
  //     store: Store.appStore,
  //     apiKey: "appl_FTkWKqtWAOYYGkGuYcKyfxQxduY",
  //   );
  // } else if (Platform.isAndroid) {
  //   StoreConfig(
  //     store: Store.playStore,
  //     apiKey: "appl_FTkWKqtWAOYYGkGuYcKyfxQxduY",
  //   );
  // }

  // await _configureSDK();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AuthManager.ensureInitialized();
  try {
    await Firebase.initializeApp();
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }

  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navKey);
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://db967fb52e009f50806bff1ee19d3588@o4507616949370880.ingest.us.sentry.io/4507616953499648';

      options.tracesSampleRate = 1.0;

      options.profilesSampleRate = 1.0;
    },
    appRunner: () => ZegoUIKit().initLog().then((value) {
      ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
        [ZegoUIKitSignalingPlugin()],
      );
      runApp(const ProviderScope(
        overrides: [],
        child: MyApp(),
      ));
    }),
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
      title: 'Metal',
      key: navKey,
      initialRoute: '/',
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
