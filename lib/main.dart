import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:metal/core/services/auth.pref.service.dart';

import 'package:metal/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:metal/route/routes.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

final navKey = GlobalKey<NavigatorState>();

NavigatorState? get nav => navKey.currentState;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    await Firebase.initializeApp();
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }

  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navKey);

  ZegoUIKit().initLog().then((value) {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );
    runApp(const ProviderScope(
      overrides: [],
      child: MyApp(),
    ));
  });

  Stripe.publishableKey =
      'pk_test_51OvncmB4Vs68C7nEXcZWcjuZbUXDoj1G5RnDNCrKRGLHK2ZruyKIju4oqPxB0zSkameyQDseYsEBGwXqu5HWb93A00qifh7Rh2';

  await dotenv.load(fileName: "assets/env/.env");
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
    ref.watch(authManagerProvider);
    return MaterialApp(
      title: 'Metal',
      key: navKey,
      initialRoute: '/',
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
