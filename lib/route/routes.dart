import 'package:flutter/material.dart';
import 'package:metal/features/authentication/presentation/forget.password/create.new.password.dart';
import 'package:metal/features/authentication/presentation/forget.password/forgot_password.otp.screen.dart';
import 'package:metal/features/authentication/presentation/forget.password/forgot_password.screen.dart';
import 'package:metal/features/authentication/presentation/login/login.screen.dart';
import 'package:metal/features/chat/domain/entries/game.model.dart';
import 'package:metal/features/chat/presentation/chat.window/chat.window.argument.dart';
import 'package:metal/features/home_page/domain/entries/melt.user.model.dart';
import 'package:metal/features/onboarding/onboarding_page_view.dart';
import 'package:metal/features/settings/edit.page.dart';
import 'package:metal/features/splash/splash.screen.dart';
import 'package:camera/camera.dart';

import 'package:metal/features/authentication/domain/entries/user.model.dart';

import 'package:metal/features/authentication/presentation/home.address/home.address.dart';
import 'package:metal/features/authentication/presentation/home.address/location.dart';
import 'package:metal/features/authentication/presentation/home.address/notification.dart';

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

import 'package:metal/features/profile/presentation/update.email/new.email.page.dart';
import 'package:metal/features/profile/presentation/update.email/update.email.page.dart';
import 'package:metal/features/profile/presentation/update.phone.number/new.phone.number.page.dart';
import 'package:metal/features/profile/presentation/update.phone.number/update.phone.number.page.dart';
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

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String forgetPassword = '/forgetPassword';
  static const String forgetPasswordOTP = '/forgetPasswordOTP';
  static const String createNewPassword = '/createNewPassword';
  static const String accountSetting = '/accountSetting';
  static const String verificationPage = '/verificationPage';
  static const String welcomePage = '/welcomePage';
  static const String createProfilePage = '/createProfilePage';
  static const String preferenceMetalPage = '/preferenceMetalPage';
  static const String passionsPage = '/passionsPage';
  static const String moreAboutYouPage = '/moreAboutYouPage';
  static const String connectionOptionsPage = '/connectionOptionsPage';
  static const String chooseYourMetalPage = '/chooseYourMetalPage';
  static const String aboutYouPage = '/aboutYouPage';
  static const String notificationEnablePage = '/notificationEnablePage';
  static const String locationEnablePage = '/locationEnablePage';
  static const String homeAddressPage = '/homeAddressPage';
  static const String dashboardPage = '/dashboardPage';
  static const String viewEyes = '/viewEyes';
  static const String eyesIntro = '/eyesIntro';
  static const String eyeSelectMedia = '/eyeSelectMedia';
  static const String eyePreviewMedia = '/eyePreviewMedia';
  static const String settingPage = '/settingPage';
  static const String verificationVideo = '/verificationVideo';
  static const String videoPreview = '/videoPreview';
  static const String meltMetal = '/meltMetal';
  static const String pushMetal = '/pushMetal';
  static const String feedBackPage = '/feedBackPage';
  static const String blockedUser = '/blockedUser';
  static const String notificationPage = '/notificationPage';
  static const String userProfilePage = '/userProfilePage';
  static const String upgradePage = '/upgradePage';
  static const String makePayment = '/makePayment';
  static const String referEarn = '/referEarn';
  static const String myMeltedMetals = '/myMeltedMetals';
  static const String myMeltedUser = '/myMeltedUser';
  static const String sendSpark = '/sendSpark';
  static const String buySpark = '/buySpark';
  static const String referEarnSpark = '/referEarnSpark';
  static const String chatWindowsPage = '/chatWindowsPage';
  static const String gamePage = '/gamePage';
  static const String gameRules = '/gameRules';
  static const String updatePhoneNumberPage = '/updatePhoneNumberPage';
  static const String updateEmailPage = '/updateEmailPage';
  static const String newPhoneNumberPage = '/newPhoneNumberPage';
  static const String newEmailPage = '/newEmailPage';
  static const String editPage = '/editPage';
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => SplashPage());
      case onboarding:
        return MaterialPageRoute(builder: (_) => OnboardingPageView());
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case forgetPassword:
        return MaterialPageRoute(builder: (_) => ForgetPasswordPage());
      case forgetPasswordOTP:
        return MaterialPageRoute(builder: (_) => ForgetPasswordOTPPage());
      case createNewPassword:
        return MaterialPageRoute(builder: (_) => CreateNewPasswordPage());
      case accountSetting:
        return MaterialPageRoute(builder: (_) => AccountSetting());
      case verificationPage:
        return MaterialPageRoute(
            builder: (_) => VerificationPage(
                settings.arguments as VerificationSentArgument));
      case welcomePage:
        return MaterialPageRoute(builder: (_) => WelcomePage());
      case createProfilePage:
        return MaterialPageRoute(builder: (_) => CreateProfilePage());
      case preferenceMetalPage:
        return MaterialPageRoute(builder: (_) => PreferenceMetalPage());
      case passionsPage:
        return MaterialPageRoute(builder: (_) => PassionsPage());
      case moreAboutYouPage:
        return MaterialPageRoute(builder: (_) => MoreAboutYouPage());
      case connectionOptionsPage:
        return MaterialPageRoute(builder: (_) => ConnectionOptionsPage());
      case chooseYourMetalPage:
        return MaterialPageRoute(builder: (_) => ChooseYourMetalPage());
      case aboutYouPage:
        return MaterialPageRoute(builder: (_) => AboutYouPage());
      case notificationEnablePage:
        return MaterialPageRoute(builder: (_) => NotificationEnablePage());
      case locationEnablePage:
        return MaterialPageRoute(builder: (_) => LocationEnablePage());
      case homeAddressPage:
        return MaterialPageRoute(builder: (_) => HomeAddressPage());
      case dashboardPage:
        return MaterialPageRoute(builder: (_) => DashboardPage());
      case viewEyes:
        return MaterialPageRoute(
            builder: (_) =>
                ViewEyes(eyes: settings.arguments as List<StatusModel>));
      case eyesIntro:
        return MaterialPageRoute(builder: (_) => EyesIntro());
      case eyeSelectMedia:
        return MaterialPageRoute(builder: (_) => EyeSelectMedia());
      case editPage:
        return MaterialPageRoute(builder: (_) => EditPage());
      case eyePreviewMedia:
        return MaterialPageRoute(
            builder: (_) =>
                EyePreviewMedia(media: settings.arguments as XFile));
      case settingPage:
        return MaterialPageRoute(builder: (_) => SettingPage());
      case verificationVideo:
        return MaterialPageRoute(builder: (_) => VerificationVideo());
      case videoPreview:
        return MaterialPageRoute(builder: (_) => VideoPreview());
      case meltMetal:
        return MaterialPageRoute(
            builder: (_) => MeltMetal(settings.arguments as ALLUserModel));
      case pushMetal:
        return MaterialPageRoute(
            builder: (_) =>
                PushMetal(user: settings.arguments as ALLUserModel));
      case feedBackPage:
        return MaterialPageRoute(builder: (_) => FeedBackPage());
      case blockedUser:
        MaterialPageRoute(builder: (_) => BlockedUser());
      case notificationPage:
        return MaterialPageRoute(builder: (_) => NotificationPage());
      case userProfilePage:
        return MaterialPageRoute(
            builder: (_) =>
                UserProfilePage(user: settings.arguments as UserModel));
      case upgradePage:
        return MaterialPageRoute(builder: (_) => UpgradePage());
      case makePayment:
        final arguments = settings.arguments as List<dynamic>;
        return MaterialPageRoute(
            builder: (_) => MakePayment(
                  price: arguments[1],
                  paymentType: arguments[0],
                ));
      case referEarn:
        return MaterialPageRoute(builder: (_) => ReferEarn());
      case myMeltedMetals:
        return MaterialPageRoute(builder: (_) => MyMeltedMetals());
      case myMeltedUser:
        return MaterialPageRoute(
            builder: (_) => MyMeltedUser(settings.arguments as String));
      case sendSpark:
        return MaterialPageRoute(builder: (_) => SendSpark());
      case buySpark:
        return MaterialPageRoute(builder: (_) => BuySpark());
      case referEarnSpark:
        return MaterialPageRoute(builder: (_) => ReferEarnSpark());
      case chatWindowsPage:
        return MaterialPageRoute(
            builder: (_) => ChatWindowsPage(
                  argument: settings.arguments as ChatWindowArgument,
                ));
      case gamePage:
        return MaterialPageRoute(builder: (_) => GamePage());
      case gameRules:
        return MaterialPageRoute(
            builder: (_) => GameRules(games: settings.arguments as GameModel));
      case updatePhoneNumberPage:
        return MaterialPageRoute(builder: (_) => UpdatePhoneNumberPage());
      case updateEmailPage:
        return MaterialPageRoute(builder: (_) => UpdateEmailPage());
      case newPhoneNumberPage:
        return MaterialPageRoute(builder: (_) => NewPhoneNumberPage());
      case newEmailPage:
        return MaterialPageRoute(builder: (_) => NewEmailPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('No route defined for ${settings.name}'),
        ),
      ),
    );
  }
}
