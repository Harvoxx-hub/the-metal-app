import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/web_utils.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/res.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/button_divider.dart';
import 'package:metal/widgets/text_views.dart';
import 'onboarding_screen.dart';

class OnboardingPageView extends StatefulWidget {
  const OnboardingPageView({super.key});
  static const name = 'onBoardingPageView';
  static const route = '/$name';

  @override
  State<OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<OnboardingPageView> {
  final image1 = Assets.gifs.onboarding.path;
  final image2 = Assets.gifs.onboarding2.path;
  final image3 = Assets.gifs.onboarding3.path;
  final PageController _controller = PageController();
  int currentPage = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_controller.hasClients) {
          // Check if controller has clients
          if (currentPage < 2) {
            _controller.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
            );
          } else {
            _controller.jumpToPage(0);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentPage > 0) {
          _controller.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          return false;
        }
        return true;
      },
      child:
    
     BaseScreen(
      isScrollable: true,
      appBarEnabled: false,
      bgImage: Assets.images.bg2.path,
      body: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 500,
                child: PageView(
                  controller: _controller,
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  children: [
                    OnboardingWidget(
                      headerText: 'Find your special someone',
                      descriptionText:
                          'A true love, a companion, a listening ear, a mentor, a father or a daughter? We got you!',
                      imageUrl: image1,
                    ),
                    OnboardingWidget(
                      headerText: 'Interact from around the world',
                      descriptionText:
                          'Irrespective of your location, you can get to interact with new contacts and friends',
                      imageUrl: image2,
                    ),
                    OnboardingWidget(
                      headerText: 'Let your hearts talk',
                      descriptionText:
                          'With our exciting Metal features, get to have meaningful blind conversations and connect your hearts.',
                      imageUrl: image3,
                      subHeader: "Every Match Is a Mystery",
                      checkMetal: true,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  buildDot(currentPage == 0),
                  buildDot(currentPage == 1),
                  buildDot(currentPage == 2),
                ],
              ),
              const Gap(20),
              BaseButton(
                buttonText: 'Sign up with your email',
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.accountSetting,
                  );
                },
              ),
              const Gap(20),
              const ButtonDivider(),
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const TextView(
                    text: 'Already have an account?',
                  ),
                  const Gap(5),
                  TextView(
                    color: AppColors.metalPinkColour,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    onTap: () {
                      debugPrint('Navigating to login page');
                      Navigator.pushNamed(
                        context,
                        AppRoutes.login,
                      );
                    },
                    text: 'Log in',
                  ),
                ],
              ),
              const Gap(20),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const TextView(
                    text: 'By tapping Sign up or Log in, you agree to our ',
                    fontSize: 10,
                  ),
                  TextView(
                    onTap: () {
                      openLink("https://themetalapp.com/terms-and-conditions/");
                    },
                    text: 'Terms',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  const TextView(
                    text: 'Learn how we process your data in our ',
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                  ),
                  TextView(
                    onTap: () {
                      openLink("https://themetalapp.com/privacy/");
                    },
                    text: 'Privacy Policy',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  const TextView(
                    text: ' and ',
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                  ),
                  TextView(
                    onTap: () {},
                    text: 'Cookies Policy',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    )
  );}

  Widget buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      height: 6.0,
      width: 6.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.metalBlack : Colors.grey,
      ),
    );
  }
}
