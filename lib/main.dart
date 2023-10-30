import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:metal/route/routes.dart';
import 'package:oktoast/oktoast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ProviderScope(
    overrides: [
      // authenticationNotifierProvider
    ],
    child: MyApp(),
  ));
}

final _navKey = GlobalKey<NavigatorState>();

NavigatorState? get nav => _navKey.currentState;

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    // Connectivity().onConnectivityChanged.listen(_checkNetwork);

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return ScreenUtilInit(
        useInheritedMediaQuery: true,
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (BuildContext context, Widget? child) {
          return OKToast(
            child: MaterialApp.router(
              title: 'Metal',
              key: _navKey,
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routeInformationParser: router.routeInformationParser,
              routerDelegate: router.routerDelegate,
              debugShowCheckedModeBanner: false,
            ),
          );
        });
  }

// Future<void> _checkNetwork(ConnectivityResult event) async {
//     if (event != ConnectivityResult.none) {
//       /// When connection is active or reestablished init FCM
//       /// if it's already inited nothing will happen
//       FCMClient.instance.init(); // ignore: unawaited_futures
//     }
//   }
}
