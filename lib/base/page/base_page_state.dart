import 'package:flutter/material.dart';
import 'package:metal/base/widget/appbar.state.dart';

import '../../utils/constant/colors.dart';
import '../../utils/screen.size.dart';

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
        child: bgImage != null
            ? _backgroundImage(
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(), // Loading indicator
                      )
                    : GestureDetector(
                        onTap: () {
                          // Dismiss the keyboard when tapping outside of text fields
                          FocusScope.of(context).unfocus();
                        },
                        child: SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            child: body,
                          ),
                        ),
                      ),
              )
            : isLoading
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
                              width: getDeviceWidth(context) - 100,
                              color: AppColors.metalBlack75,
                              child: body,
                            ))
                        : body,
                  ),
      ),
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
}
