import 'package:flutter/material.dart';
import 'package:metal/features/authentication/presentation/forget.password/create.new.password.dart';
import 'package:metal/features/authentication/presentation/forget.password/forgot_password.otp.screen.dart';
import 'package:metal/features/authentication/presentation/forget.password/forgot_password.screen.dart';
import 'package:metal/features/authentication/presentation/login/login.screen.dart';
import 'package:metal/features/chat/domain/entries/game.model.dart';

import 'package:metal/features/home_page/post_thought.dart';
import 'package:metal/features/my.metals/melt.metal.dart';

import 'package:metal/features/onboarding/onboarding_page_view.dart';
import 'package:metal/features/settings/presentation%20/delete.screen.dart';
import 'package:metal/features/settings/presentation%20/edit.page.dart';
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

import 'package:metal/features/my.metals/my.melted.metals.dart';
import 'package:metal/features/my.metals/my.melted.user.dart';
import 'package:metal/features/my.metals/user.profile.dart';
import 'package:metal/features/notification/notification.page.dart';

import 'package:metal/features/profile/presentation/update.email/new.email.page.dart';
import 'package:metal/features/profile/presentation/update.email/update.email.page.dart';
import 'package:metal/features/profile/presentation/update.phone.number/new.phone.number.page.dart';
import 'package:metal/features/profile/presentation/update.phone.number/update.phone.number.page.dart';
import 'package:metal/features/refer.earn/refer.earn.dart';
import 'package:metal/features/settings/presentation%20/blocked.user.dart'
    as block;
import 'package:metal/features/settings/presentation%20/settings.page.dart';

import 'package:metal/features/sparks_page/screens/buy.spark/buy.spark.dart';
import 'package:metal/features/sparks_page/screens/refer.earn/refer.earn.dart';
import 'package:metal/features/sparks_page/screens/send.spark/send.spark.dart';

import 'package:metal/features/upgrade/make.payment.dart';

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
  static const String delete = '/deletePage';
  static const String postThought = '/postThought';
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPageView());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case forgetPassword:
        return MaterialPageRoute(builder: (_) => ForgetPasswordPage());
      case forgetPasswordOTP:
        return MaterialPageRoute(builder: (_) => ForgetPasswordOTPPage());
      case createNewPassword:
        return MaterialPageRoute(
            builder: (_) => CreateNewPasswordPage(
                  userid: settings.arguments as String,
                ));
      case accountSetting:
        return MaterialPageRoute(builder: (_) => const AccountSetting());
      case verificationPage:
        return MaterialPageRoute(
            builder: (_) => VerificationPage(
                settings.arguments as VerificationSentArgument));
      case welcomePage:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      case createProfilePage:
        return MaterialPageRoute(builder: (_) => const CreateProfilePage());
      case preferenceMetalPage:
        return MaterialPageRoute(builder: (_) => const PreferenceMetalPage());
      case passionsPage:
        return MaterialPageRoute(builder: (_) => const PassionsPage());
      case moreAboutYouPage:
        return MaterialPageRoute(builder: (_) => const MoreAboutYouPage());
      case connectionOptionsPage:
        return MaterialPageRoute(builder: (_) => const ConnectionOptionsPage());
      case chooseYourMetalPage:
        return MaterialPageRoute(builder: (_) => const ChooseYourMetalPage());
      case aboutYouPage:
        return MaterialPageRoute(builder: (_) => const AboutYouPage());
      case notificationEnablePage:
        return MaterialPageRoute(
            builder: (_) => const NotificationEnablePage());
      case locationEnablePage:
        return MaterialPageRoute(builder: (_) => const LocationEnablePage());
      case homeAddressPage:
        return MaterialPageRoute(builder: (_) => const HomeAddressPage());
      case dashboardPage:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      case viewEyes:
        return MaterialPageRoute(
            builder: (_) =>
                ViewEyes(eyes: settings.arguments as List<StatusModel>));
      case eyesIntro:
        return MaterialPageRoute(builder: (_) => const EyesIntro());
      case eyeSelectMedia:
        return MaterialPageRoute(builder: (_) => const EyeSelectMedia());
      case editPage:
        return MaterialPageRoute(builder: (_) => const EditPage());
      case eyePreviewMedia:
        return MaterialPageRoute(
            builder: (_) =>
                EyePreviewMedia(media: settings.arguments as XFile));
      case settingPage:
        return MaterialPageRoute(builder: (_) => const SettingPage());
      case verificationVideo:
        return MaterialPageRoute(builder: (_) => const VerificationVideo());
      case videoPreview:
        return MaterialPageRoute(builder: (_) => const VideoPreview());

      case feedBackPage:
        return MaterialPageRoute(builder: (_) => FeedBackPage());
      case blockedUser:
        return MaterialPageRoute(builder: (_) => const block.BlockedUser());
      case notificationPage:
        return MaterialPageRoute(builder: (_) => const NotificationPage());
      case userProfilePage:
        return MaterialPageRoute(
            builder: (_) =>
                UserProfilePage(user: settings.arguments as UserModel));
      // case upgradePage:
      //   return MaterialPageRoute(builder: (_) => const UpgradePage());
      case makePayment:
        final arguments = settings.arguments as List<dynamic>;
        return MaterialPageRoute(
            builder: (_) => MakePayment(
                  price: arguments[1],
                  paymentType: arguments[0],
                ));
      case referEarn:
        return MaterialPageRoute(builder: (_) => const ReferEarn());
      case myMeltedMetals:
        return MaterialPageRoute(builder: (_) => const MyMeltedMetals());
      case myMeltedUser:
        return MaterialPageRoute(
            builder: (_) => MyMeltedUser(
                  metalId: settings.arguments as String,
                ));

      case meltMetal:
        return MaterialPageRoute(
            builder: (_) => MeltMetal(
                  id: settings.arguments as String,
                ));
      case sendSpark:
        return MaterialPageRoute(builder: (_) => const SendSpark());
      case buySpark:
        return MaterialPageRoute(builder: (_) => BuySpark());
      case referEarnSpark:
        return MaterialPageRoute(builder: (_) => const ReferEarnSpark());
      case chatWindowsPage:
        return MaterialPageRoute(
            builder: (_) => ChatWindowsPage(
                  metalId: settings.arguments as String,
                ));
      case gamePage:
        return MaterialPageRoute(builder: (_) => const GamePage());
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
      case delete:
        return MaterialPageRoute(builder: (_) => DeleteScreen());

      case postThought:
        return MaterialPageRoute(
            builder: (_) => PostThought(
                  userModel: settings.arguments as UserModel,
                ));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
