import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/gen/assets.gen.dart';

import '../../utils/constant/colors.dart';
import '../../utils/screen.size.dart';
import '../../widgets/text_views.dart';

class BaseScreen extends StatelessWidget {
  final Widget body;
  final AppBarState appBarState;
  final bool appBarEnabled; // New parameter to enable/disable the AppBar
  final bool isLoading;
  final String? bgImage;
  final Widget? bottomWidget;
  final Widget? floatingActionButton;
  final String? Header;
  final Function()? onSkipButtonPressed;
  final bool isScrollable;
  final bool authFlow;
  // New parameter to indicate loading state

  BaseScreen({
    this.bgImage,
    required this.body,
    this.bottomWidget,
    this.appBarState = AppBarState.BackWithHeader,
    this.appBarEnabled = true,
    this.isScrollable = true,
    this.floatingActionButton,
    this.onSkipButtonPressed,
    this.authFlow = false,
    this.Header = '',
    this.isLoading =
        false, // Default to not loading // Default to enabling AppBar
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.metalWhite,

      appBar: appBarEnabled
          ? CustomAppBar(
              appBarState: appBarState,
              onHamburgerPressed: () {},
              onBackButtonPressed: () {},
              onSkipButtonPressed: () {},
              onNotificationPressed: () {},
              headerText: Header!,
              appBarEnabled: appBarEnabled,
            )
          : null,
      body: Container(
          height: getDeviceHeight(context),
          width: getDeviceWidth(context),
          child: _backgroundImage(
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(), // Loading indicator
                  )
                : GestureDetector(
                    onTap: () {
                      // Dismiss the keyboard when tapping outside of text fields
                      FocusScope.of(context).unfocus();
                    },
                    child: authFlow
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              height: getDeviceHeight(context) - 100,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  color: AppColors.metalWhite,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                children: [
                                  _authAppbar(),
                                  Gap(10.h),
                                  body,
                                ],
                              ),
                            ))
                        : body,
                  ),
          )),

      // bottomSheet: Container(

      //   color: AppColors.metalWhite,
      //   child: Padding(
      //     padding: const EdgeInsets.all(8.0),
      //     child: bottomWidget,
      //   ),
      // ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _backgroundImage(Widget child) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(bgImage!),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }

  Widget _authAppbar() {
    return Container(
      color: AppColors.metalWhite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: SvgPicture.asset(
                Assets.icons.back.path,
                height: 32,
                width: 32,
              ),
            ),
          ),
          TextView(
            text: Header!,
            fontSize: 20.sp,
            fontWeight: FontWeight.normal,
          ),
          Container()
        ],
      ),
    );
  }
}
