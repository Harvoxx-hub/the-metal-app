import 'package:flutter/material.dart';
import 'package:metal/features/authentication/presentation/forget.password/create.new.password.dart';
import 'package:metal/features/authentication/presentation/forget.password/forgot_password.otp.screen.dart';
import 'package:metal/features/authentication/presentation/forget.password/forgot_password.screen.dart';
import 'package:metal/features/authentication/presentation/login/login.screen.dart';
import 'package:metal/features/chat/domain/entries/game.model.dart';
import 'package:metal/features/thought/data/domain/entries/thought.model.dart';
import 'package:metal/features/settings/presentation/edit.preferences.dart';

import 'package:metal/features/thought/post_thought.dart';
import 'package:metal/features/my.metals/melt.metal.dart';

import 'package:metal/features/onboarding/onboarding_page_view.dart';

import 'package:metal/features/settings/presentation/delete.screen.dart';
import 'package:metal/features/settings/presentation/edit.page.dart';
import 'package:metal/features/splash/splash.screen.dart';
import 'package:camera/camera.dart';

import 'package:metal/features/authentication/domain/entries/user.model.dart';

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
import 'package:metal/features/settings/presentation/blocked.user.dart'
    as block;
import 'package:metal/features/settings/presentation/settings.page.dart';

import 'package:metal/features/sparks_page/screens/buy.spark/buy.spark.dart';
import 'package:metal/features/sparks_page/screens/refer.earn/refer.earn.dart';
import 'package:metal/features/sparks_page/screens/send.spark/send.spark.dart';

import 'package:metal/features/upgrade/make.payment.dart';

import 'package:metal/features/thought/presentation/thought_details.page.dart';
import 'package:metal/features/profile/presentation/pages/work_email_page.dart';
import 'package:metal/features/community/presentation/screens/community_discovery_screen.dart';
import 'package:metal/features/community/presentation/screens/community_profile_screen.dart';
import 'package:metal/features/community/presentation/screens/create_community_screen.dart';
import 'package:metal/features/community/data/domain/entries/community.model.dart';
import 'package:metal/features/community/data/domain/entries/community_metadata.model.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String onboardingTutorialView = '/onboardingTutorialView';
  static const String unmetalView = '/unmetal';
  static const String metalPlusView = '/metalPlusView';
  static const String sparkInfoSwitchView = '/sparkInfoSwitchView';
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
  static const String editPreferences = '/editPreferences';
  static const String delete = '/deletePage';
  static const String postThought = '/postThought';
  static const String thoughtDetails = '/thoughtDetails';
  static const String workEmail = '/work-email';
  static const String communityDiscovery = '/communityDiscovery';
  static const String communityProfile = '/communityProfile';
  static const String createCommunity = '/createCommunity';
  // Dashboard tab indices
  static const int homeTab = 0;
  static const int thoughtsTab = 1;
  static const int sparksTab = 2;
  static const int messagesTab = 3;
  static const int profileTab = 4;

  // Helper methods to navigate to specific tabs
  static void navigateToHome(BuildContext context, {bool replace = false}) {
    if (replace) {
      Navigator.pushReplacementNamed(context, dashboardPage,
          arguments: homeTab);
    } else {
      Navigator.pushNamed(context, dashboardPage, arguments: homeTab);
    }
  }

  static void navigateToSparks(BuildContext context, {bool replace = false}) {
    if (replace) {
      Navigator.pushReplacementNamed(context, dashboardPage,
          arguments: sparksTab);
    } else {
      Navigator.pushNamed(context, dashboardPage, arguments: sparksTab);
    }
  }

  static void navigateToMessages(BuildContext context, {bool replace = false}) {
    if (replace) {
      Navigator.pushReplacementNamed(context, dashboardPage,
          arguments: messagesTab);
    } else {
      Navigator.pushNamed(context, dashboardPage, arguments: messagesTab);
    }
  }

  static void navigateToProfile(BuildContext context, {bool replace = false}) {
    if (replace) {
      Navigator.pushReplacementNamed(context, dashboardPage,
          arguments: profileTab);
    } else {
      Navigator.pushNamed(context, dashboardPage, arguments: profileTab);
    }
  }

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
        return MaterialPageRoute(builder: (_) => const ForgetPasswordOTPPage());
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

      case dashboardPage:
        // Check if arguments contain a tab index
        final args = settings.arguments;
        if (args is int) {
          return MaterialPageRoute(
              builder: (_) => DashboardPage(initialPageIndex: args));
        } else if (args is Map<String, dynamic> &&
            args.containsKey('tabIndex')) {
          return MaterialPageRoute(
              builder: (_) =>
                  DashboardPage(initialPageIndex: args['tabIndex']));
        }
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
      case editPreferences:
        return MaterialPageRoute(builder: (_) => const EditPreferences());
      case eyePreviewMedia:
        return MaterialPageRoute(
            builder: (_) =>
                EyePreviewMedia(media: settings.arguments as XFile));
      case settingPage:
        return MaterialPageRoute(builder: (_) => const SettingPage());

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
                  metalDetials: settings.arguments as Map<String, dynamic>,
                ));

      case meltMetal:

//"NUFXmf3EzrOAiw7k9PQsVzf7x7B3"
        return MaterialPageRoute(
            builder: (_) => MeltMetal(
                  id: settings.arguments as String,
                ));
      case sendSpark:
        return MaterialPageRoute(
            builder: (_) => SendSpark(
                recipient: settings.arguments != null
                    ? (settings.arguments as UserModel)
                    : null));
      case buySpark:
        return MaterialPageRoute(builder: (_) => BuySpark());
      case referEarnSpark:
        return MaterialPageRoute(builder: (_) => const ReferEarnSpark());
      case chatWindowsPage:
        return MaterialPageRoute(
            builder: (_) => ChatWindowsPage(
                  connectionId: settings.arguments as String,
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
        final args = settings.arguments;
        ThoughtModel? thoughtModel;
        CommunityMetadata? communityMetadata;

        if (args is Map<String, dynamic>) {
          thoughtModel = args['thoughtModel'] as ThoughtModel?;
          if (args['communityMetadata'] != null) {
            communityMetadata =
                CommunityMetadata.fromJson(args['communityMetadata']);
          }
        } else if (args is ThoughtModel) {
          thoughtModel = args;
        }

        return MaterialPageRoute(
            builder: (_) => PostThought(
                  thoughtModel: thoughtModel,
                  communityMetadata: communityMetadata,
                ));
      case thoughtDetails:
        return MaterialPageRoute(
          builder: (_) => ThoughtDetailsPage(),
          settings: settings,
        );
      case workEmail:
        return MaterialPageRoute(
          builder: (_) => const WorkEmailPage(),
        );
      case communityDiscovery:
        return MaterialPageRoute(
          builder: (_) => const CommunityDiscoveryScreen(),
        );
      case communityProfile:
        return MaterialPageRoute(
          builder: (_) => CommunityProfileScreen(
            communityId: settings.arguments as String,
          ),
        );
      case createCommunity:
        return MaterialPageRoute(
          builder: (_) => const CreateCommunityScreen(),
        );
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
