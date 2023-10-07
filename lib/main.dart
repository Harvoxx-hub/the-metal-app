import 'package:connectivity_plus/connectivity_plus.dart';
 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
 
import 'package:metal/route/routes.dart';
import 'package:oktoast/oktoast.dart';

 
// Future<void> backgroundHandler(RemoteMessage message) async {}
 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // try {
  //   await Firebase.initializeApp();
  //   FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  // } catch(e) {
  //   print("Failed to initialize Firebase: $e");
  // }
  

//  setupLocator();
 // FirebaseMessaging.onBackgroundMessage(backgroundHandler);
//  DependencyInitializer.initDependencies();

  runApp(ProviderScope(
    overrides: [
     // authenticationNotifierProvider
      ],
    child: MyApp(),
  ));
}
 final _navKey = GlobalKey<NavigatorState>();

/// Static getter for convenient route navigation.
///
/// E.g. nav.pushNamed(routeName)
///
/// Can be used anywhere in the app
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
