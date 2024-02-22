import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/features/chat/presentation/chat.page.dart';
import 'package:metal/features/verification/verification.video.dart';
import 'package:metal/gen/assets.gen.dart';
 
import 'package:metal/features/profile/profile.page.dart';

import 'package:metal/features/sparks_page/screens/sparks_page.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/res/style/text_styles.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text_views.dart';

import '../home_page/home_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  static const name = 'DashboardPage';
  static const route = '/$name';

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int currentIndex = 0;
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAlertDialog(context);
    });
    super.initState();
  }

  void showAlertDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          content: verifyDialog(context),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavPages = [
      const HomePage(),
      const SparksPage(),
        ChatPage(),
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

  Widget verifyDialog(BuildContext context) {
    return Column(
      children: [
        Gap(38.h),
        Assets.images.checkVerified.image(),
        Gap(15.h),
        TextView(
          text: "Confirmation",
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        Gap(15.h),
        TextView(
          text:
              "Verifying your identity means telling other metals that you are authentic, and your information is accurate which helps to increase your chances for real connections and we can vouch that we know you. It takes a little fee!",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        Gap(38.h),
        BaseButton(
            buttonText: "Verifly Me",
            onPressed: () {
              context.pushNamed(VerificationVideo.name);
              //  confirm(context);
            }),
        Gap(23.h),
        TextView(
          text: "Skip for Now",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          onTap: () => context.pop(),
        ),
        Gap(21.h),
      ],
    );
  }
}
