import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/chat/chat.page.dart';
import 'package:metal/features/profile/profile.page.dart';

import 'package:metal/features/sparks_page/sparks_page.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/res/style/text_styles.dart';

import '../home_page/home_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  static const name = 'DashboardPage';
  static const route = '/$name';

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bottomNavPages = [
      const HomePage(),
      const SparksPage(),
      const ChatPage(),
      const ProfilePage(),
    ];
    return BaseScreen(
      appBarState: AppBarState.Dashboard,
      body: Column(
        children: [
          Expanded(
              child: Container(
            color: AppColors.metalWhite,
            child: Stack(
              children: [bottomNavPages[currentIndex]],
            ),
          )),
        ],
      ),
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
