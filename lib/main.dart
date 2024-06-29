import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:metal/core/services/auth.pref.service.dart';

import 'package:metal/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:metal/route/routes.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:metal/store.config.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
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

  WidgetsFlutterBinding.ensureInitialized();

  // await _configureSDK();

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
}

// Future<void> _configureSDK() async {
//   // Enable debug logs before calling `configure`.
//   await Purchases.setLogLevel(LogLevel.debug);

//   PurchasesConfiguration configuration;
//   if (StoreConfig.isForAmazonAppstore()) {
//     configuration = AmazonConfiguration(StoreConfig.instance.apiKey)
//       ..appUserID = null
//       ..observerMode = false;
//   } else {
//     configuration = PurchasesConfiguration(StoreConfig.instance.apiKey)
//       ..appUserID = null
//       ..observerMode = false;
//   }
//   await Purchases.configure(configuration);
//   _logIn("1234542");
 
//     //   await RevenueCatUI.presentPaywallIfNeeded("Metal Plus Monthly");
//   // log(paywall.toString());
// }

// _logIn(String newAppUserID) async {
//   /*
//       How to login and identify your users with the Purchases SDK.

//       Read more about Identifying Users here: https://docs.revenuecat.com/docs/user-ids
//     */

//   try {
//     await Purchases.logIn(newAppUserID);
//     String appUserID = await Purchases.appUserID;
//   print(appUserID);
//          await RevenueCatUI.presentPaywall();
//   } on PlatformException catch (e) {
//     print(e.message);
//   }
// }

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
