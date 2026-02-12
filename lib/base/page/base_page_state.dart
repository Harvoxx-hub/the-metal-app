import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/core/utils/screen.size.dart';

import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/views/dashboard/widgets/nav.drawer.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';

import '../../widgets/text_views.dart';

class BaseScreen extends StatefulWidget {
  final Widget body;
  final AppBarState appBarState;
  final bool appBarEnabled; // New parameter to enable/disable the AppBar
  final bool isLoading;
  final String? bgImage;
  final Widget? bottomWidget;
  final Widget? floatingActionButton;
  final BottomNavigationBar? bottomNavigationBar;
  final String? Header;
  final Function()? onSkipButtonPressed;
  final bool isScrollable;
  final bool subAppBar;
  final bool authFlow;
  // New parameter to indicate loading state

  const BaseScreen({
    super.key,
    this.bgImage,
    required this.body,
    this.subAppBar = false,
    this.bottomWidget,
    this.bottomNavigationBar,
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
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      drawer: const NavDrawer(),
      backgroundColor: AppColors.metalWhite,
      appBar: widget.appBarEnabled
          ? CustomAppBar(
              appBarState: widget.appBarState,
              onHamburgerPressed: () {
                _key.currentState!.openDrawer();
              },
              onBackButtonPressed: () {
                Navigator.pop(context);
              },
              onSkipButtonPressed: () {},
              onNotificationPressed: () {
                Navigator.pushNamed(context, AppRoutes.notificationPage);
              },
              headerText: widget.Header!,
              appBarEnabled: widget.appBarEnabled,
            )
          : null,
      body: SizedBox(
          height: getDeviceHeight(context),
          width: getDeviceWidth(context),
          child: _backgroundImage(_subAppbar(
            widget.isLoading
                ? const Center(
                    child: CircularProgressIndicator(), // Loading indicator
                  )
                : GestureDetector(
                    onTap: () {
                      // Dismiss the keyboard when tapping outside of text fields
                      FocusScope.of(context).unfocus();
                    },
                    child: widget.authFlow
                        ? SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, bottom: 16),
                              child: Container(
                                height: getDeviceHeight(context) - 100,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                    color: AppColors.metalWhite,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  children: [
                                    _authAppbar(context),
                                    const Gap(10),

                                    Expanded(
                                        child: widget
                                            .body), // Use an Expanded widget for flexible content
                                  ],
                                ),
                              ),
                            ),
                          )
                        : widget.body,
                  ),
          ))),
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }

  Widget _backgroundImage(Widget child) {
    if (widget.bgImage != null) {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(widget.bgImage!),
            fit: BoxFit.cover,
          ),
        ),
        child: child,
      );
    } else {
      // If bgImage is null, you can choose a fallback background or return just the child.
      // For example, returning a container with a background color:

      // Alternatively, if you want to return just the child with no background:
      return child;
    }
  }

  Widget _subAppbar(Widget child) {
    if (widget.subAppBar) {
      return SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 53,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.00, -1.00),
                        end: Alignment(0, 1),
                        colors: [Color(0xFFDB217A), Color(0xFFF00E3E)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(35),
                        bottomRight: Radius.circular(35),
                      )),
                ),
                child
              ],
            ),
          ],
        ),
      );
    } else {
      return child;
    }
  }

  Widget _authAppbar(BuildContext context) {
    return Container(
      color: AppColors.metalWhite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
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
            text: widget.Header!,
            fontSize: 20,
            fontWeight: FontWeight.normal,
          ),
          Container()
        ],
      ),
    );
  }
}
