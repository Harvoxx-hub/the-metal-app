import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/pages/authentication/presentation/home.address/home.address.dart';
import 'package:metal/pages/authentication/presentation/home.address/location.dart';
import 'package:metal/pages/authentication/presentation/home.address/notification.dart';
import 'package:metal/pages/authentication/presentation/login/create.new.password.dart';
import 'package:metal/pages/authentication/presentation/login/forgot_password.otp.screen.dart';
import 'package:metal/pages/authentication/presentation/profile.setting/about.you.dart';
import 'package:metal/pages/authentication/presentation/profile.setting/choose.your.metal.dart';
import 'package:metal/pages/authentication/presentation/profile.setting/connection.option.dart';
import 'package:metal/pages/authentication/presentation/profile.setting/create.profile.dart';
import 'package:metal/pages/authentication/presentation/login/forgot_password.screen.dart';
import 'package:metal/pages/authentication/presentation/login/login.screen.dart';
import 'package:metal/pages/authentication/presentation/profile.setting/create.profile.dob.dart';
import 'package:metal/pages/authentication/presentation/profile.setting/more.about.you.dart';
import 'package:metal/pages/authentication/presentation/profile.setting/passions.dart';
import 'package:metal/pages/authentication/presentation/profile.setting/preference.metal.dart';
import 'package:metal/pages/authentication/presentation/signup/account.setting.dart';
import 'package:metal/pages/authentication/presentation/signup/verfication.dart';
import 'package:metal/pages/authentication/presentation/welcome/presentation/welcome.page.dart';
import 'package:metal/pages/dashboard.dart/dashboard.dart';
import 'package:metal/pages/onboarding/onboarding_page_view.dart';
import 'package:metal/pages/sparks_page/buy.spark/buy.spark.dart';
import 'package:metal/pages/sparks_page/refer.earn/refer.earn.dart';
import 'package:metal/pages/sparks_page/send.spark/send.spark.dart';
import 'package:metal/pages/sparks_page/sparks_page.dart';

import '../pages/splash/splash.screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = RouterNotifier(ref);

  return GoRouter(
      debugLogDiagnostics: true,
      initialLocation: OnboardingPageView.route,
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
            builder: (context, state) => LoginPage(),
            path: LoginPage.route,
            routes: [
              GoRoute(
                name: ForgetPasswordPage.name,
                builder: (context, state) => ForgetPasswordPage(),
                path: ForgetPasswordPage.route,
              ),
              GoRoute(
                name: ForgetPasswordOTPPage.name,
                builder: (context, state) => ForgetPasswordOTPPage(),
                path: ForgetPasswordOTPPage.route,
              ),
              GoRoute(
                name: CreateNewPasswordPage.name,
                builder: (context, state) => CreateNewPasswordPage(),
                path: CreateNewPasswordPage.route,
              ),
            ]),
        GoRoute(
            name: AccountSetting.name,
            builder: (context, state) => AccountSetting(),
            path: AccountSetting.route,
            routes: [
              GoRoute(
                name: VerificationPage.name,
                builder: (context, state) => VerificationPage(),
                path: VerificationPage.route,
              ),
              GoRoute(
                name: WelcomePage.name,
                builder: (context, state) => WelcomePage(),
                path: WelcomePage.route,
              ),
              GoRoute(
                name: CreateProfilePage.name,
                builder: (context, state) => CreateProfilePage(),
                path: CreateProfilePage.route,
              ),
              GoRoute(
                name: PreferenceMetalPage.name,
                builder: (context, state) => PreferenceMetalPage(),
                path: PreferenceMetalPage.route,
              ),
              GoRoute(
                name: PassionsPage.name,
                builder: (context, state) => PassionsPage(),
                path: PassionsPage.route,
              ),
              GoRoute(
                name: MoreAboutYouPage.name,
                builder: (context, state) => MoreAboutYouPage(),
                path: MoreAboutYouPage.route,
              ),
              GoRoute(
                name: CreateProfileDobPage.name,
                builder: (context, state) => CreateProfileDobPage(),
                path: CreateProfileDobPage.route,
              ),
              GoRoute(
                name: ConnectionOptionsPage.name,
                builder: (context, state) => ConnectionOptionsPage(),
                path: ConnectionOptionsPage.route,
              ),
              GoRoute(
                name: ChooseYourMetalPage.name,
                builder: (context, state) => ChooseYourMetalPage(),
                path: ChooseYourMetalPage.route,
              ),
              GoRoute(
                name: AboutYouPage.name,
                builder: (context, state) => AboutYouPage(),
                path: AboutYouPage.route,
              ),
              GoRoute(
                name: NotificationEnablePage.name,
                builder: (context, state) => NotificationEnablePage(),
                path: NotificationEnablePage.route,
              ),
              GoRoute(
                name: LocationEnablePage.name,
                builder: (context, state) => LocationEnablePage(),
                path: LocationEnablePage.route,
              ),
              GoRoute(
                name: HomeAddressPage.name,
                builder: (context, state) => HomeAddressPage(),
                path: HomeAddressPage.route,
              ),
            ]),
        GoRoute(
            name: DashboardPage.name,
            builder: (context, state) => DashboardPage(),
            path: DashboardPage.route,
            routes: [
              GoRoute(
                name: SendSpark.name,
                builder: (context, state) => SendSpark(),
                path: SendSpark.route,
              ),
              GoRoute(
                name: BuySpark.name,
                builder: (context, state) => BuySpark(),
                path: BuySpark.route,
              ),
              GoRoute(
                name: ReferEarnSpark.name,
                builder: (context, state) => ReferEarnSpark(),
                path: ReferEarnSpark.route,
              ),
            ]),
      ];
}
