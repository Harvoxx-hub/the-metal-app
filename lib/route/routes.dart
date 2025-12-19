import 'package:flutter/material.dart';
import 'package:metal/features/thought/data/domain/entries/thought.model.dart';

import 'package:metal/features/my.metals/melt.metal.dart';

import 'package:metal/features/settings/presentation/delete.screen.dart';
import 'package:camera/camera.dart';

// New Clean Architecture views
import 'package:metal/presentation/views/splash/splash_view.dart';
import 'package:metal/presentation/views/onboarding/onboarding_view.dart';
import 'package:metal/presentation/views/auth/login_view.dart';
import 'package:metal/presentation/views/auth/signup_view.dart';
import 'package:metal/presentation/views/auth/verification_view.dart';
import 'package:metal/presentation/views/auth/forgot_password_view.dart';
import 'package:metal/presentation/views/welcome/welcome_view.dart';
import 'package:metal/presentation/views/profile/basic_info_view.dart';
import 'package:metal/presentation/views/profile/choose_metal_view.dart';
import 'package:metal/presentation/views/profile/passions_view.dart';
import 'package:metal/presentation/views/profile/about_you_view.dart';
import 'package:metal/presentation/views/profile/more_about_you_view.dart';
import 'package:metal/presentation/views/profile/connection_options_view.dart';
import 'package:metal/presentation/views/profile/preferences_view.dart';
import 'package:metal/presentation/views/settings/settings_view.dart';
import 'package:metal/presentation/views/settings/edit_profile_view.dart';
import 'package:metal/presentation/views/settings/edit_preferences_view.dart';
import 'package:metal/presentation/views/chat/chat_window_view.dart';
import 'package:metal/presentation/views/dashboard/dashboard_view.dart';

// New Clean Architecture Connection views
import 'package:metal/presentation/views/connection/connection_list_screen.dart';
import 'package:metal/presentation/views/connection/connection_detail_screen.dart';
import 'package:metal/features/my.metals/user.profile.dart';

// Notification view
import 'package:metal/presentation/views/notification/notification_view.dart';

// Settings
import 'package:metal/features/settings/presentation/blocked.user.dart'
    as block;

// Spark features (to be migrated)
import 'package:metal/features/sparks_page/screens/buy.spark/buy.spark.dart';
import 'package:metal/features/sparks_page/screens/send.spark/send.spark.dart';

import 'package:metal/features/upgrade/make.payment.dart';

import 'package:metal/features/profile/presentation/pages/work_email_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String onboardingTutorialView = '/onboardingTutorialView';
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
  static const String settingPage = '/settingPage';

  static const String meltMetal = '/meltMetal';
  static const String pushMetal = '/pushMetal';
  static const String blockedUser = '/blockedUser';
  static const String notificationPage = '/notificationPage';
  static const String userProfilePage = '/userProfilePage';
  static const String upgradePage = '/upgradePage';
  static const String makePayment = '/makePayment';
  static const String myMeltedMetals = '/myMeltedMetals';
  static const String myMeltedUser = '/myMeltedUser';
  static const String sendSpark = '/sendSpark';
  static const String buySpark = '/buySpark';
  static const String chatWindowView = '/chatWindowView'; // New API-based chat
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
      // Core auth flow - Clean Architecture
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashView());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingView());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case accountSetting:
        return MaterialPageRoute(builder: (_) => const SignupView());
      case verificationPage:
        // Just pass email as string argument
        return MaterialPageRoute(
          builder: (_) => const VerificationView(),
          settings: settings,
        );
      case forgetPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordView());
      case welcomePage:
        return MaterialPageRoute(builder: (_) => const WelcomeView());

      // New Clean Architecture Profile Setup Routes
      case BasicInfoView.route:
        return MaterialPageRoute(builder: (_) => const BasicInfoView());
      case ChooseMetalView.route:
        return MaterialPageRoute(builder: (_) => const ChooseMetalView());
      case PassionsView.route:
        return MaterialPageRoute(builder: (_) => const PassionsView());
      case AboutYouView.route:
        return MaterialPageRoute(builder: (_) => const AboutYouView());
      case MoreAboutYouView.route:
        return MaterialPageRoute(builder: (_) => const MoreAboutYouView());
      case ConnectionOptionsView.route:
        return MaterialPageRoute(builder: (_) => const ConnectionOptionsView());
      case PreferencesView.route:
        return MaterialPageRoute(builder: (_) => const PreferencesView());

      case dashboardPage:
        // Check if arguments contain a tab index
        final args = settings.arguments;
        if (args is int) {
          return MaterialPageRoute(
              builder: (_) => DashboardView(initialPageIndex: args));
        } else if (args is Map<String, dynamic> &&
            args.containsKey('tabIndex')) {
          return MaterialPageRoute(
              builder: (_) =>
                  DashboardView(initialPageIndex: args['tabIndex']));
        }
        return MaterialPageRoute(builder: (_) => const DashboardView());
      case editPage:
        return MaterialPageRoute(builder: (_) => const EditProfileView());
      case editPreferences:
        return MaterialPageRoute(builder: (_) => const EditPreferencesView());
      case settingPage:
        return MaterialPageRoute(builder: (_) => const SettingsView());

      case blockedUser:
        return MaterialPageRoute(builder: (_) => const block.BlockedUser());
      case notificationPage:
        return MaterialPageRoute(builder: (_) => const NotificationView());
      case userProfilePage:
        // UserProfilePage expects the old UserModel, pass as dynamic for now
        return MaterialPageRoute(
            builder: (_) =>
                UserProfilePage(user: settings.arguments as dynamic));
      // case upgradePage:
      //   return MaterialPageRoute(builder: (_) => const UpgradePage());
      case makePayment:
        final arguments = settings.arguments as List<dynamic>;
        return MaterialPageRoute(
            builder: (_) => MakePayment(
                  price: arguments[1],
                  paymentType: arguments[0],
                ));
      case myMeltedMetals:
        return MaterialPageRoute(builder: (_) => const ConnectionListScreen());
      case myMeltedUser:
        return MaterialPageRoute(
            builder: (_) => ConnectionDetailScreen(
                  metalDetails: settings.arguments as Map<String, dynamic>,
                ));

      case meltMetal:

//"NUFXmf3EzrOAiw7k9PQsVzf7x7B3"
        return MaterialPageRoute(
            builder: (_) => MeltMetal(
                  id: settings.arguments as String,
                ));
      case sendSpark:
        // SendSpark expects the old UserModel, pass as dynamic for now
        return MaterialPageRoute(
            builder: (_) => SendSpark(
                recipient: settings.arguments != null
                    ? (settings.arguments as dynamic)
                    : null));
      case buySpark:
        return MaterialPageRoute(builder: (_) => BuySpark());
      case chatWindowView:
        return MaterialPageRoute(
            builder: (_) => ChatWindowView(
                  connectionId: settings.arguments as String,
                ));
      // Phone number and email update pages have been removed
      // TODO: Re-implement these in Clean Architecture when needed
      case updatePhoneNumberPage:
      case updateEmailPage:
      case newPhoneNumberPage:
      case newEmailPage:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Feature coming soon')),
          ),
        );
      case delete:
        return MaterialPageRoute(builder: (_) => DeleteScreen());

      // TODO: Re-implement postThought and thoughtDetails in new architecture
      case postThought:
      case thoughtDetails:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Feature coming soon')),
          ),
        );
      case workEmail:
        return MaterialPageRoute(
          builder: (_) => const WorkEmailPage(),
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
