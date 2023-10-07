 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/pages/authentication/presentation/login/login.screen.dart';
import 'package:metal/pages/main_activity/main_activity.dart';
import 'package:metal/pages/onboarding/onboarding_page_view.dart';

import '../pages/splash/splash.screen.dart';
 

final routerProvider = Provider<GoRouter>((ref) {
  final router = RouterNotifier(ref);
 
  return GoRouter(
      debugLogDiagnostics: true,
   initialLocation:  OnboardingPageView.route,
      refreshListenable: router,
      // redirect: (context, state) {
      //   final authState = ref.watch(authenticationNotifierProvider);
      //   if (!authState.isAuthenticated && state.location != OnboardingPageView.route && state.location != SplashScreen.route) {
      //     return WelcomePage.route;
      //   }
      //   return state.location;
      
      // },
      //observers: [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),],
      routes: router._routes);
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    // _ref.listen<AuthenticationState>(
    //   authenticationNotifierProvider,
    //   (_, __) => notifyListeners(),
      
    // );
    

  }

  List<GoRoute> get _routes => [
        GoRoute(
            name: SplashPage.routeName,
            builder: (context, state) => const SplashPage(),
            path: '/',
            ),

        GoRoute(
            name: OnboardingPageView.route,
            builder: (context, state) => const OnboardingPageView(),
            path: OnboardingPageView.route,
          ),

            GoRoute(
             name: LoginPage.name,
            builder: (context, state) =>  LoginPage(),
            path: LoginPage.route,
         ),
        GoRoute(
          name: MainActivityPage.name,
          builder: (context, state) => MainActivityPage(),
          path: MainActivityPage.route,
        ),

         
       
          ];
}
