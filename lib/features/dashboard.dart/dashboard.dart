import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/features/dashboard.dart/widget/tutorial_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import necessary internal packages
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/authentication/provider/metal.properties.notifier.dart';
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
import 'package:upgrader/upgrader.dart';

import '../home_page/home_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userdata = ref.watch(authProvider).data;
      await _checkOnboardingAndUserStatus(userdata!);
    });
  }

  Future<void> _checkOnboardingAndUserStatus(UserModel userData) async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

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
            ),
          );
        },
      );
    } else {
      await _checkUserStatus(userData);
    }
  }

  Future<void> _checkUserStatus(UserModel userData) async {
    if (!(userData.completedProfile ?? false)) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            content: ComplecteProfileDialog(),
          );
        },
      );
    } else if (!(userData.isVerified ?? false)) {
      // await showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return const CustomDialog(
      //       content: VerificationDialog(),
      //     );
      //   },
      // );
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
          : UpgradeAlert(
              dialogStyle: Platform.isIOS
                  ? UpgradeDialogStyle.cupertino
                  : UpgradeDialogStyle.material,
              upgrader: Upgrader(),
              child: Column(
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
        type: BottomNavigationBarType.fixed,
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
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Image.asset(Assets.images.inactiveSpark.path),
              activeIcon: Image.asset(Assets.images.activeSpark.path),
              label: 'Sparks'),
          BottomNavigationBarItem(
              icon: Image.asset(Assets.images.inactiveMessage.path),
              activeIcon: Image.asset(Assets.images.activeMessage.path),
              label: 'Chat'),
          BottomNavigationBarItem(
              icon: Image.asset(Assets.images.inactiveUser.path),
              activeIcon: Image.asset(Assets.images.activeUser.path),
              label: 'Profile'),
        ],
      ),
    );
  }
}
