import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/services/firebase.remote.config.service.dart';
import 'package:metal/core/utils/strings/app_strings.dart';
import 'package:metal/features/dashboard.dart/widget/new_update_dialog.dart';
import 'package:metal/features/dashboard.dart/widget/tutorial_dialog.dart';
import 'package:metal/features/dashboard.dart/widget/verification.dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import necessary internal packages
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/authentication/provider/metal.properties.notifier.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
import 'package:metal/features/chat/presentation/chat.page.dart';
import 'package:metal/features/dashboard.dart/widget/complete.profile.dialog.dart';
import 'package:metal/features/home_page/provider/get.melt.users.notifier.dart';
import 'package:metal/features/onboarding/tutorial_pages/tutorial_screen.dart';
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
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    // Initialize with the provided index or default to 0
    currentIndex = widget.initialPageIndex ?? 0;
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (_initialized) return;
    _initialized = true;

    final userdata = ref.read(authProvider).data;
    if (userdata != null && mounted) {
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
                Navigator.pop(dialogContext);
                await Navigator.of(context).push(
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (_, __, ___) => const OnboardingFlowView(),
                    transitionsBuilder: (_, animation, __, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
                await prefs.setBool('hasSeenOnboarding', true);
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
    } else if (_isUpdateAvailable(currentVersion, latestVersion)) {
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
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedProfile = prefs.getBool('hasCompletedProfile') ?? false;

    if (!(userData.completedProfile ?? false) && !hasCompletedProfile) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CustomDialog(
            content: ComplecteProfileDialog(
              onProfileComplete: () async {
                // Store that profile has been completed
                await prefs.setBool('hasCompletedProfile', true);
                // Update the user data to reflect completion
                final updatedUser = userData.copyWith(completedProfile: true);
                await ref
                    .read(authenticationRepositoryProvider)
                    .updateUser(updatedUser.toJson());
                if (mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          );
        },
      );
    } else if (!(userData.isVerified ?? false)) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            content: VerificationDialog(),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavPages = [
      const HomePage(),
      const SparksPage(),
      const ChatPage(),
      const ProfilePage(),
    ];
    final user = ref.watch(authProvider);
    ref.watch(getMeltUserProvider);
    ref.watch(metalPropertiesProvider);
    ref.read(authProvider.notifier).initZIMKIt();

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
              backgroundColor: const Color(0xFFD2128B),
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () async {
                await Navigator.pushNamed(context, AppRoutes.postThought,
                    arguments: user.data);
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
              icon: Image.asset(Assets.images.inactiveSpark.path),
              activeIcon: Image.asset(Assets.images.activeSpark.path),
              label: AppStrings.sparks),
          BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Image.asset(Assets.images.inactiveMessage.path),
                  if (ref.watch(unreadCountProvider).data != null &&
                      ref.watch(unreadCountProvider).data! > 0)
                    Positioned(
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
                          ref.watch(unreadCountProvider).data!.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: Stack(
                children: [
                  Image.asset(Assets.images.activeMessage.path),
                  if (ref.watch(unreadCountProvider).data != null &&
                      ref.watch(unreadCountProvider).data! > 0)
                    Positioned(
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
                          ref.watch(unreadCountProvider).data!.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
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
