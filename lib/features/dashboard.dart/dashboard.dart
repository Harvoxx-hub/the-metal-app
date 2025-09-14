import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/services/firebase.remote.config.service.dart';
import 'package:metal/core/managers/location_manager.dart';
import 'package:metal/core/utils/strings/app_strings.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/dashboard.dart/widget/new_update_dialog.dart';
import 'package:metal/features/dashboard.dart/widget/tutorial_dialog.dart';
import 'package:metal/features/dashboard.dart/widget/tutorial_overlay.dart';
import 'package:metal/features/dashboard.dart/widget/verification.dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import necessary internal packages
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

import 'package:metal/features/authentication/provider/metal.properties.notifier.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';

import 'package:metal/features/chat/presentation/chat.page.dart';

import 'package:metal/features/home_page/provider/get.melt.users.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/profile/presentation/profile.page.dart';
import 'package:metal/features/sparks_page/screens/sparks_page.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';

import 'package:metal/features/chat/provider/unread.count.notifier.dart';

import '../home_page/home_page.dart';
import 'package:metal/features/dashboard.dart/widget/thought_reminder_dialog.dart';

class DashboardPage extends ConsumerStatefulWidget {
  final int? initialPageIndex;

  const DashboardPage({
    super.key,
    this.initialPageIndex,
  });

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  late int currentIndex;
  bool _initialized = false;

  // Add a key for the new post FAB to be referenced by the tutorial
  final GlobalKey newPostFabKey = GlobalKey();
  final GlobalKey thoughtCardKey = GlobalKey();
  final GlobalKey profileKey = GlobalKey();
  final GlobalKey commentKey = GlobalKey();
  final GlobalKey reactionKey = GlobalKey();

  // Create HomePage instance as class member
  late final HomePage homePage;

  // Initialize ZegoUIKit safely after the widget is built
  Future<void> _initializeZegoUIKit() async {
    if (!mounted) return;

    try {
      await ref.read(authProvider.notifier).initZIMKItWithContext(context);
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error initializing ZegoUIKit: $e');
      // Show a snackbar to inform the user
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Call service initialization failed. Please try again later.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    print('Dashboard initState');
    // Initialize HomePage instance
    homePage = HomePage(
      newPostFabKey: newPostFabKey,
      profileKey: profileKey,
      commentKey: commentKey,
      reactionKey: reactionKey,
    );

    // Initialize ZegoUIKit with permission handling after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeZegoUIKit();
    });

    // Initialize with the provided index or default to 0
    currentIndex = widget.initialPageIndex ?? 0;
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (_initialized) return;
    _initialized = true;

    final userdata = ref.read(userStateProvider).data;
    if (userdata != null && mounted) {
      // Update location on app startup using LocationManager
      await LocationManager().updateLocationOnAppStart(ref);
      await _checkOnboardingAndUserStatus(userdata);
    }
  }

  @override
  void dispose() {
    _initialized = false;
    super.dispose();
  }

  Future<void> _checkOnboardingAndUserStatus(UserModel userData) async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    final hasSeenThoughtReminder =
        prefs.getBool('hasSeenThoughtReminder') ?? false;
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final String currentVersion = packageInfo.buildNumber;

    // Calculate if user is within 7 days of creation
    final DateTime creationDate = userData.createdAt != null
        ? DateTime.parse(userData.createdAt!)
        : DateTime.now();
    final bool isWithin7Days =
        DateTime.now().difference(creationDate).inDays <= 7;

    if (!hasSeenOnboarding) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return CustomDialog(
            content: TutorialDialog(
              onStartTutorial: () async {
                // Close the dialog first
                Navigator.pop(dialogContext);

                // Make sure the widget is still mounted before proceeding
                if (!mounted) return;

                // Navigate to Home tab first
                setState(() {
                  currentIndex = 0;
                });

                // Give UI time to update
                await Future.delayed(const Duration(milliseconds: 300));

                // Check again if still mounted
                if (!mounted) return;

                // Show the tutorial overlay directly
                _showFeaturesTutorial();

                // We need to mark onboarding as seen
                await prefs.setBool('hasSeenOnboarding', true);

                // Only proceed if still mounted
                if (!mounted) return;

                // After that's done, check user status
                await _checkUserStatus(userData);
              },
              onSkipTutorial: () async {
                // Mark that user has seen onboarding when they skip
                await prefs.setBool('hasSeenOnboarding', true);
                await _checkUserStatus(userData);
              },
            ),
          );
        },
      );
    } else if (_isUpdateAvailable(
        currentVersion, FirebaseRemoteConfigService().getLatestVersion())) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            content: NewUpdateDialog(),
          );
        },
      );
    } else {
      await _checkUserStatus(userData);

      // Show thought reminder for new users who haven't seen it
      if (isWithin7Days && !hasSeenThoughtReminder) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomDialog(
              content: ThoughtReminderDialog(),
            );
          },
        );
        await prefs.setBool('hasSeenThoughtReminder', true);
      }
    }
  }

  bool _isUpdateAvailable(String currentVersion, String latestVersion) {
    final int currentPart = int.parse(currentVersion);
    final int latestPart = int.parse(latestVersion);

    if (latestPart > currentPart) {
      return true;
    } else if (latestPart < currentPart) {
      return false;
    } else {
      return false;
    }
  }

  Future<void> _checkUserStatus(UserModel userData) async {
    if (!mounted) return;

    if (userData.workEmailVerified == false) {
      await showDialog(
        context: context,
        builder: (dialogContext) => const CustomDialog(
          content: VerificationDialog(),
        ),
      );
    }
  }

  // Create the tutorial overlay directly
  void _showFeaturesTutorial() {
    // Make sure we're still mounted
    if (!mounted) return;

    // Force home tab to be selected to ensure all elements are visible
    setState(() {
      currentIndex = 0;
    });

    // Give UI time to update before showing tutorial
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      // Get tutorial steps from HomePage instance
      final steps = homePage.getTutorialSteps(
          newPostFabKey, profileKey, commentKey, reactionKey);

      if (steps.isEmpty) {
        debugPrint("Warning: No tutorial steps available");
        return;
      }

      // Show the tutorial - this will now bypass the hasSeenTutorial check
      showTutorial(context, steps, 'dashboard_tutorial_key');
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavPages = [
      homePage,
      const SparksPage(),
      const ChatPage(),
      const ProfilePage(),
    ];
    final user = ref.watch(userStateProvider);
    ref.watch(getMeltUserProvider);
    ref.watch(metalPropertiesProvider);

    return BaseScreen(
      appBarState: AppBarState.Dashboard,
      body: user.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: Container(
                    color: AppColors.metalWhite,
                    child: Stack(
                      children: [bottomNavPages[currentIndex]],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              key: newPostFabKey, // Add the key to the FAB
              backgroundColor: const Color(0xFFD2128B),
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () async {
                await Navigator.pushNamed(
                  context,
                  AppRoutes.postThought,
                );
              })
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Image.asset(Assets.images.inactiveHome.path),
              activeIcon: Image.asset(Assets.images.activeHome.path),
              label: AppStrings.home),
          BottomNavigationBarItem(
              icon: Container(
                key: homePage.sparksTabKey,
                child: Image.asset(Assets.images.inactiveSpark.path),
              ),
              activeIcon: Image.asset(Assets.images.activeSpark.path),
              label: AppStrings.sparks),
          BottomNavigationBarItem(
              icon: Stack(
                key: homePage.chatTabKey,
                children: [
                  Image.asset(Assets.images.inactiveMessage.path),
                  Consumer(
                    builder: (context, ref, child) {
                      final unreadState = ref.watch(unreadCountProvider);
                      if (unreadState.isSuccess && unreadState.data! > 0) {
                        return Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              unreadState.data!.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              activeIcon: Stack(
                children: [
                  Image.asset(Assets.images.activeMessage.path),
                  Consumer(
                    builder: (context, ref, child) {
                      final unreadState = ref.watch(unreadCountProvider);
                      if (unreadState.isSuccess && unreadState.data! > 0) {
                        return Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              unreadState.data!.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              label: AppStrings.chat),
          BottomNavigationBarItem(
              icon: Image.asset(Assets.images.inactiveUser.path),
              activeIcon: Image.asset(Assets.images.activeUser.path),
              label: AppStrings.profile),
        ],
      ),
    );
  }
}
