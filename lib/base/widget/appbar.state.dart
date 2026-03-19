import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/presentation/viewmodels/notification/notification_viewmodel.dart';

import '../../gen/assets.gen.dart';

enum AppBarState {
  Dashboard,
  BackWithHeader,
  BackWithHeaderWithSkip,
  HambugerWithHeader,
}

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final AppBarState appBarState;
  final Function() onHamburgerPressed;
  final Function() onBackButtonPressed;
  final Function() onSkipButtonPressed;
  final Function() onNotificationPressed;
  final String headerText;

  final bool appBarEnabled; // New parameter to enable/disable the AppBar

  const CustomAppBar({
    super.key,
    required this.appBarState,
    required this.onHamburgerPressed,
    required this.onBackButtonPressed,
    required this.onSkipButtonPressed,
    required this.onNotificationPressed,
    required this.headerText,
    required this.appBarEnabled, // Pass true to enable AppBar, false to disable
  });

  @override
  Size get preferredSize =>
      appBarEnabled ? const Size.fromHeight(kToolbarHeight) : Size.zero;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!appBarEnabled) {
      return const SizedBox
          .shrink(); // Return an empty widget if AppBar is disabled
    }

    String leftIcon;
    String? rightIcon;

    Function() onLeftIconTap;
    Function()? onRightIconTap;

    switch (appBarState) {
      case AppBarState.BackWithHeader:
        leftIcon = Assets.icons.backBtn.path;
        onLeftIconTap = onBackButtonPressed;
        break;
      case AppBarState.HambugerWithHeader:
        leftIcon = Assets.icons.hambuger.path;
        onLeftIconTap = onBackButtonPressed;
        break;
      case AppBarState.Dashboard:
        leftIcon = Assets.icons.hambuger.path;
        rightIcon = Assets.icons.notification.path;
        onLeftIconTap = onHamburgerPressed;
        onRightIconTap = onNotificationPressed;
        break;
      case AppBarState.BackWithHeaderWithSkip:
        leftIcon = Assets.icons.back.path;
        onLeftIconTap = onBackButtonPressed;
        onRightIconTap = onSkipButtonPressed;
        break;
    }

    return AppBar(
      backgroundColor: AppColors.metalPinkColour,
      leading: GestureDetector(
        onTap: onLeftIconTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SvgPicture.asset(
            leftIcon,
            height: 40,
            width: 40,
          ),
        ),
      ),
      elevation: 0,
      leadingWidth: appBarState == AppBarState.BackWithHeader ? 32 : 45,
      title: Center(
        child: Text(
          headerText,
          style: const TextStyle(
            color: AppColors.metalWhite,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        rightIcon == null
            ? const SizedBox.shrink()
            : _buildNotificationIcon(onRightIconTap, rightIcon, ref),
        const Gap(10),
      ],
    );
  }

  Widget _buildNotificationIcon(
      Function()? onTap, String iconPath, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          SvgPicture.asset(
            iconPath,
            height: 40,
            width: 40,
          ),
          // Only show badge for notification icon (BUG-009: only after load, avoid phantom count)
          if (iconPath == Assets.icons.notification.path)
            Consumer(
              builder: (context, ref, child) {
                final notificationState = ref.watch(notificationViewModelProvider);
                final count = notificationState.unreadCount;
                final hasLoaded = notificationState.isSuccess || notificationState.notifications.isNotEmpty;
                return hasLoaded && count > 0
                    ? Positioned(
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
                            count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
        ],
      ),
    );
  }
}
