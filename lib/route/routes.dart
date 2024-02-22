import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/presentation/forget.password/create.new.password.dart';
import 'package:metal/features/authentication/presentation/forget.password/forgot_password.otp.screen.dart';
import 'package:metal/features/authentication/presentation/forget.password/forgot_password.screen.dart';
import 'package:metal/features/authentication/presentation/home.address/home.address.dart';
import 'package:metal/features/authentication/presentation/home.address/location.dart';
import 'package:metal/features/authentication/presentation/home.address/notification.dart';
import 'package:metal/features/authentication/presentation/login/login.screen.dart';

import 'package:metal/features/authentication/presentation/profile.setting/about.you.dart';
import 'package:metal/features/authentication/presentation/profile.setting/choose.your.metal.dart';
import 'package:metal/features/authentication/presentation/profile.setting/connection.option.dart';
import 'package:metal/features/authentication/presentation/profile.setting/create.profile.dart';

import 'package:metal/features/authentication/presentation/profile.setting/more.about.you.dart';
import 'package:metal/features/authentication/presentation/profile.setting/passions.dart';
import 'package:metal/features/authentication/presentation/profile.setting/preference.metal.dart';
import 'package:metal/features/authentication/presentation/signup/account.setting.dart';
import 'package:metal/features/authentication/presentation/signup/verfication.argument.dart';
import 'package:metal/features/authentication/presentation/signup/verfication.page.dart';
import 'package:metal/features/authentication/presentation/welcome/presentation/welcome.page.dart';
import 'package:metal/features/chat/presentation/chat.window/chat.window.dart';
import 'package:metal/features/chat/presentation/games/games.page.dart';
import 'package:metal/features/chat/presentation/games/games.rule.dart';
import 'package:metal/features/dashboard.dart/dashboard.dart';
import 'package:metal/features/eyes/domain/entries/status.model.dart';
import 'package:metal/features/eyes/presentation/eye.preview.media.dart';
import 'package:metal/features/eyes/presentation/eye.select.media.dart';
import 'package:metal/features/eyes/presentation/eyes.intro.screen.dart';
import 'package:metal/features/eyes/presentation/view.eyes.dart';
import 'package:metal/features/feedback/feedback.page.dart';
import 'package:metal/features/home_page/domain/entries/all.user.model.dart';
import 'package:metal/features/home_page/melt.metal.dart';
import 'package:metal/features/home_page/push.metal.dart';
import 'package:metal/features/my.metals/my.melted.metals.dart';
import 'package:metal/features/my.metals/my.melted.user.dart';
import 'package:metal/features/my.metals/user.profile.dart';
import 'package:metal/features/notification/notification.page.dart';
import 'package:metal/features/onboarding/onboarding_page_view.dart';
import 'package:metal/features/profile/update.email/new.email.page.dart';
import 'package:metal/features/profile/update.email/update.email.page.dart';
import 'package:metal/features/profile/update.phone.number/new.phone.number.page.dart';
import 'package:metal/features/profile/update.phone.number/update.phone.number.page.dart';
import 'package:metal/features/refer.earn/refer.earn.dart';
import 'package:metal/features/settings/blocked.user.dart';
import 'package:metal/features/settings/settings.page.dart';

import 'package:metal/features/sparks_page/screens/buy.spark/buy.spark.dart';
import 'package:metal/features/sparks_page/screens/refer.earn/refer.earn.dart';
import 'package:metal/features/sparks_page/screens/send.spark/send.spark.dart';

import 'package:metal/features/upgrade/domain/entries/metal.plan.model.dart';

import 'package:metal/features/upgrade/make.payment.dart';
import 'package:metal/features/upgrade/upgrade.page.dart';
import 'package:metal/features/verification/verification.video.dart';
import 'package:metal/features/verification/video.preview.dart';

import '../features/splash/splash.screen.dart';

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

  RouterNotifier(this._ref) {}

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
                builder: (context, state) =>
                    VerificationPage(state.extra as VerificationSentArgument),
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
                name: ViewEyes.name,
                builder: (context, state) => ViewEyes(
                  eyes: state.extra as List<StatusModel>,
                ),
                path: ViewEyes.route,
              ),
              GoRoute(
                name: EyesIntro.name,
                builder: (context, state) => EyesIntro(),
                path: EyesIntro.route,
              ),
               GoRoute(
                name: EyeSelectMedia.name,
                builder: (context, state) => EyeSelectMedia(),
                path: EyeSelectMedia.route,
                routes: [
                  GoRoute(
                    name: EyePreviewMedia.name,
                    builder: (context, state) => EyePreviewMedia(
                      media: state.extra as XFile,
                    ),
                    path: EyePreviewMedia.route,
                  ),
                ],
              ),
               GoRoute(
                name: SettingPage.name,
                builder: (context, state) => SettingPage(),
                path: SettingPage.route,
              ),
              GoRoute(
                  name: VerificationVideo.name,
                  builder: (context, state) => VerificationVideo(),
                  path: VerificationVideo.route,
                  routes: [
                    GoRoute(
                      name: VideoPreview.name,
                      builder: (context, state) => VideoPreview(),
                      path: VideoPreview.route,
                    ),
                  ]),
              GoRoute(
                name: MeltMetal.name,
                builder: (context, state) =>
                    MeltMetal(state.extra as ALLUserModel),
                path: MeltMetal.route,
              ),
              GoRoute(
                name: PushMetal.name,
                builder: (context, state) => PushMetal(
                  user: state.extra as ALLUserModel,
                ),
                path: PushMetal.route,
              ),
              GoRoute(
                name: FeedBackPage.name,
                builder: (context, state) => FeedBackPage(),
                path: FeedBackPage.route,
              ),
              GoRoute(
                name: BlockedUser.name,
                builder: (context, state) => BlockedUser(),
                path: BlockedUser.route,
              ),
              GoRoute(
                name: NotificationPage.name,
                builder: (context, state) => NotificationPage(),
                path: NotificationPage.route,
              ),
              GoRoute(
                name: UserProfilePage.name,
                builder: (context, state) => UserProfilePage(
                  user: state.extra as UserModel,
                ),
                path: UserProfilePage.route,
              ),
              GoRoute(
                name: UpgradePage.name,
                builder: (context, state) => UpgradePage(),
                path: UpgradePage.route,
              ),
              GoRoute(
                name: MakePayment.name,
                builder: (context, state) => MakePayment(
                  metalPlanModel: state.extra as MetalPlanModel,
                ),
                path: MakePayment.route,
              ),
              GoRoute(
                name: ReferEarn.name,
                builder: (context, state) => ReferEarn(),
                path: ReferEarn.route,
              ),
              GoRoute(
                  name: MyMeltedMetals.name,
                  builder: (context, state) => MyMeltedMetals(),
                  path: MyMeltedMetals.route,
                  routes: [
                    GoRoute(
                      name: MyMeltedUser.name,
                      builder: (context, state) => MyMeltedUser(
                        state.extra as String,
                      ),
                      path: MyMeltedUser.route,
                    ),
                  ]),
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
              GoRoute(
                name: ChatWindowsPage.name,
                builder: (context, state) =>
                    ChatWindowsPage(conversationID: state.extra as String),
                path: ChatWindowsPage.route,
              ),
              GoRoute(
                name: GamePage.name,
                builder: (context, state) => GamePage(),
                path: GamePage.route,
              ),
              GoRoute(
                name: GameRules.name,
                builder: (context, state) => GameRules(
                  games: state.extra as String,
                ),
                path: GameRules.route,
              ),
              GoRoute(
                name: UpdatePhoneNumberPage.name,
                builder: (context, state) => UpdatePhoneNumberPage(),
                path: UpdatePhoneNumberPage.route,
              ),
              GoRoute(
                name: UpdateEmailPage.name,
                builder: (context, state) => UpdateEmailPage(),
                path: UpdateEmailPage.route,
              ),
              GoRoute(
                name: NewPhoneNumberPage.name,
                builder: (context, state) => NewPhoneNumberPage(),
                path: NewPhoneNumberPage.route,
              ),
              GoRoute(
                name: NewEmailPage.name,
                builder: (context, state) => NewEmailPage(),
                path: NewEmailPage.route,
              ),
            ]),
      ];
}
