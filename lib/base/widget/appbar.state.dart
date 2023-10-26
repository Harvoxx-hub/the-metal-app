import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/res/colors/cr_colors.dart';
 
 

import '../../gen/assets.gen.dart';

enum AppBarState {
  Dashboard,
  BackWithHeader,
  BackWithHeaderWithSkip
,


}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBarState appBarState;
  final Function() onHamburgerPressed;
  final Function() onBackButtonPressed;
  final Function() onSkipButtonPressed;
  final Function() onNotificationPressed;
  final String headerText;
 
  final bool appBarEnabled; // New parameter to enable/disable the AppBar

  CustomAppBar({
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
      appBarEnabled ? Size.fromHeight(kToolbarHeight) : Size.zero;

  @override
  Widget build(BuildContext context) {
    if (!appBarEnabled) {
      return SizedBox.shrink(); // Return an empty widget if AppBar is disabled
    }

    String leftIcon;
    String? rightIcon;
    String? rightText;
 
    Function() onLeftIconTap;
    Function()? onRightIconTap;

    switch (appBarState) {
      case AppBarState.BackWithHeader:
        leftIcon = Assets.icons.back.path;
         

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
        rightText = "Skip";
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
            height: 24,
            width: 24,
          ),
        ),
      ),
      leadingWidth: 30,
   
      title: Center(
          child:  Text(
            headerText,
            style: TextStyle(
              color: AppColors.metalWhite,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),),
      centerTitle: true,
      actions: [
        rightIcon == null
            ? SizedBox.shrink()
            : GestureDetector(
                onTap: onRightIconTap,
                child: SvgPicture.asset(
                  rightIcon,
                  height: 24.h,
                  width: 24.w,
                ),
              ),
              Gap(10),
      ],
    );
  }
}
