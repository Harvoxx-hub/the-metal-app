import 'package:flutter/material.dart';

import 'package:metal/presentation/views/settings/delete_account_view.dart';

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
import 'package:metal/presentation/views/prompt/prompt_creation_view.dart';
import 'package:metal/presentation/views/profile/connection_options_view.dart';
import 'package:metal/presentation/views/profile/preferences_view.dart';
import 'package:metal/presentation/views/settings/settings_view.dart';
import 'package:metal/presentation/views/settings/edit_profile_view.dart';
import 'package:metal/presentation/views/settings/edit_preferences_view.dart';
import 'package:metal/presentation/views/chat/chat_window_view.dart';
import 'package:metal/presentation/views/dashboard/dashboard_view.dart';
import 'package:metal/presentation/views/thought/create_thought_screen.dart';
import 'package:metal/presentation/views/thought/thought_detail_view.dart';
import 'package:metal/presentation/views/community/community_detail_view.dart';
import 'package:metal/presentation/views/community/create_community_screen.dart';
import 'package:metal/presentation/views/user/user_profile_view.dart';
import 'package:metal/presentation/views/meetup/create_meetup_screen.dart';
import 'package:metal/presentation/views/meetup/invite_guests_screen.dart';
import 'package:metal/presentation/views/meetup/meetup_detail_view.dart';

// New Clean Architecture Connection views
import 'package:metal/presentation/views/connection/connection_list_screen.dart';
import 'package:metal/presentation/views/connection/melt_screen.dart';

// Notification view
import 'package:metal/presentation/views/notification/notification_view.dart';

// Verification
import 'package:metal/presentation/views/verification/work_email_verification_view.dart';

// Location (central flow; discovery uses stored user model)
import 'package:metal/presentation/views/location/enable_location_view.dart';

// Settings
import 'package:metal/presentation/views/settings/blocked_users_view.dart';

// Spark features (to be migrated)
// Spark features migrated to lib/presentation/views/spark/
// import 'package:metal/features/sparks_page/screens/buy.spark/buy.spark.dart';
// import 'package:metal/features/sparks_page/screens/send.spark/send.spark.dart';
import 'package:metal/presentation/views/spark/send_spark_screen.dart';
import 'package:metal/presentation/views/referral/referral_view.dart';
import 'package:metal/presentation/views/feedback/feedback_view.dart';
import 'package:metal/domain/entities/user_dto.dart';

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
  static const String promptCreationPage = '/promptCreationPage';
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
  static const String upgradePage = '/upgradePage';
  static const String makePayment = '/makePayment';
  static const String myMeltedMetals = '/myMeltedMetals';
  static const String sendSpark = '/sendSpark';
  static const String buySpark = '/buySpark';
  static const String referEarn = '/referEarn';
  static const String feedback = '/feedback';
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
  static const String communityDetails = '/communityDetails';
  static const String createCommunity = '/createCommunity';
  static const String userProfile = '/userProfile';
  static const String workEmail = '/work-email';
  static const String meetupDetails = '/meetupDetails';

  /// Meetup detail (Live Event Dashboard). Alias for meetupDetails (backwards compatibility).
  static const String linkupDetails = '/linkupDetails';
  static const String createMeetup = '/createMeetup';
  static const String inviteGuests = '/inviteGuests';
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
      case chooseYourMetalPage:
        return MaterialPageRoute(builder: (_) => const ChooseMetalView());
      case PassionsView.route:
      case passionsPage:
        return MaterialPageRoute(builder: (_) => const PassionsView());
      case AboutYouView.route:
      case aboutYouPage:
        return MaterialPageRoute(builder: (_) => const AboutYouView());
      case MoreAboutYouView.route:
      case moreAboutYouPage:
        return MaterialPageRoute(builder: (_) => const MoreAboutYouView());
      case promptCreationPage:
        return MaterialPageRoute(
          builder: (_) => PromptCreationView(
            isAuthFlow: true,
            onComplete: () {
              // Navigate to connection options after prompts are created
              Navigator.pushReplacementNamed(
                  _, AppRoutes.connectionOptionsPage);
            },
          ),
        );
      case ConnectionOptionsView.route:
      case connectionOptionsPage:
        return MaterialPageRoute(builder: (_) => const ConnectionOptionsView());
      case PreferencesView.route:
      case preferenceMetalPage:
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

      case locationEnablePage: {
        final args = settings.arguments is Map
            ? settings.arguments as Map<String, dynamic>
            : null;
        return MaterialPageRoute(
          builder: (_) => EnableLocationView(
            fromSplash: args?['fromSplash'] as bool? ?? false,
            profileUpdated: args?['profileUpdated'] as bool? ?? false,
          ),
        );
      }

      case blockedUser:
        return MaterialPageRoute(builder: (_) => const BlockedUsersView());
      case notificationPage:
        return MaterialPageRoute(builder: (_) => const NotificationView());
      // case upgradePage:
      //   return MaterialPageRoute(builder: (_) => const UpgradePage());

      case myMeltedMetals:
        return MaterialPageRoute(builder: (_) => const ConnectionListScreen());

      case meltMetal:
        final args = settings.arguments;
        String? userId;
        String? connectionId;

        if (args is String) {
          userId = args;
        } else if (args is Map) {
          userId = args['userId'] as String?;
          connectionId = args['connectionId'] as String?;
        }

        if (userId != null && userId.isNotEmpty) {
          return MaterialPageRoute(
            builder: (_) => MeltScreen(
              userId: userId!,
              connectionId: connectionId,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Invalid user ID')),
          ),
        );
      case makePayment:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Payment feature coming soon')),
          ),
        );
      // Spark features moved to new architecture - use spark tab in dashboard
      case sendSpark:
        final args = settings.arguments;
        final preSelectedUser = args is UserDto ? args : null;
        return MaterialPageRoute(
          builder: (_) => SendSparkScreen(preSelectedUser: preSelectedUser),
        );
      case buySpark:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Use Sparks tab in dashboard')),
          ),
        );
      case referEarn:
        return MaterialPageRoute(
          builder: (_) => const ReferralView(),
        );
      case feedback:
        return MaterialPageRoute(
          builder: (_) => const FeedbackView(),
        );
      case chatWindowView:
        return MaterialPageRoute(
            builder: (_) => ChatWindowView(
                  connectionId: settings.arguments as String,
                ));
      // Phone number and email update pages have been removed
      // TODO: Re-implement these in Clean Architecture when needed

      case delete:
        return MaterialPageRoute(builder: (_) => const DeleteAccountView());

      case postThought:
        final rawArgs = settings.arguments;
        Map<String, dynamic>? communityMetadata;
        String? editThoughtId;
        String? editText;
        bool editConnectionOnly = false;

        if (rawArgs is Map<String, dynamic>) {
          // New edit-mode payload shape:
          // { communityMetadata?: {...}, editThoughtId, editText, editConnectionOnly }
          if (rawArgs.containsKey('communityMetadata')) {
            final cm = rawArgs['communityMetadata'];
            communityMetadata = cm is Map<String, dynamic> ? cm : null;
          } else {
            // Backwards compatible: old callers pass community metadata directly
            communityMetadata = rawArgs;
          }

          editThoughtId = rawArgs['editThoughtId'] as String?;
          editText = rawArgs['editText'] as String?;
          editConnectionOnly = rawArgs['editConnectionOnly'] as bool? ?? false;
        }
        return MaterialPageRoute(
          builder: (_) => CreateThoughtScreen(
            communityMetadata: communityMetadata,
            editThoughtId: editThoughtId,
            editText: editText,
            editConnectionOnly: editConnectionOnly,
          ),
        );
      case thoughtDetails:
        // Handle arguments: can be String (thoughtId) or Map with thoughtId and optional commentId
        final args = settings.arguments;
        String thoughtId;
        String? targetCommentId;

        if (args is String) {
          thoughtId = args;
        } else if (args is Map<String, dynamic>) {
          thoughtId = args['thoughtId'] as String? ?? '';
          targetCommentId = args['commentId'] as String?;
        } else {
          thoughtId = '';
        }

        return MaterialPageRoute(
          builder: (_) => ThoughtDetailView(
            thoughtId: thoughtId,
            targetCommentId: targetCommentId,
          ),
        );
      case communityDetails:
        final args = settings.arguments;
        final communityId = args is String
            ? args
            : (args as Map<String, dynamic>?)?['communityId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => CommunityDetailView(communityId: communityId),
        );
      case createCommunity:
        return MaterialPageRoute(
          builder: (_) => const CreateCommunityScreen(),
        );
      case userProfile:
        final args = settings.arguments;
        final userId = args is String
            ? args
            : (args as Map<String, dynamic>?)?['userId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => UserProfileView(userId: userId),
        );
      case workEmail:
        return MaterialPageRoute(
          builder: (_) => const WorkEmailVerificationView(),
        );
      case createMeetup:
        final args = settings.arguments;
        final communityId = args is String
            ? args
            : (args as Map<String, dynamic>?)?['communityId'] as String?;
        return MaterialPageRoute(
          builder: (_) => CreateMeetupScreen(communityId: communityId),
        );
      case meetupDetails:
      case linkupDetails:
        // Live Event Dashboard (Meetup detail)
        final args = settings.arguments;
        final meetupId = args is String
            ? args
            : (args as Map<String, dynamic>?)?['meetupId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => MeetupDetailView(meetupId: meetupId),
        );
      case inviteGuests:
        final args = settings.arguments as Map<String, dynamic>?;
        final maxGuests = args?['maxGuests'] as int? ?? 10;
        final initialSelectedIds =
            (args?['initialSelectedIds'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [];
        return MaterialPageRoute(
          builder: (_) => InviteGuestsScreen(
            maxGuests: maxGuests,
            initialSelectedIds: initialSelectedIds,
          ),
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
