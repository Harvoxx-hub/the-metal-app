import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/pages/authentication/presentation/login/login.screen.dart';
import 'package:metal/pages/main_activity/main_activity.dart';
import 'package:metal/utils/screen.size.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/button_divider.dart';
import 'package:metal/widgets/dash.progress.indicator.dart';
import 'package:metal/widgets/text_views.dart';

import '../authentication/presentation/signup/account.setting.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PageController _controller = PageController(
      initialPage: 0,
    );
    int currentPage = 0;

    void nextPage() {
      setState(() {
        if (_controller.page == 2) {}
        _controller.nextPage(
            duration: const Duration(
              milliseconds: 100,
            ),
            curve: Curves.easeIn);
      });
    }

    return BaseScreen(
      appBarEnabled: false,
      bgImage: Assets.images.bg2.path,
      body: Column(
        children: [
          SizedBox(
            height: 500.h,
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
                  currentPage: 0,
                  index: 3,
                  next: () => nextPage(),
                ),
                OnboardingWidget(
                  headerText: 'Interact from around the world',
                  descriptionText:
                      'Irrespective of your location, you can get to interact with new contacts and friends',
                  imageUrl: image2,
                  currentPage: 1,
                  index: 3,
                  next: nextPage,
                ),
                OnboardingWidget(
                  headerText: 'Let your hearts talk',
                  descriptionText:
                      'With our exciting Metal features, get to have meaningful blind conversations and connect your hearts.',
                  imageUrl: image3,
                  currentPage: 2,
                  index: 3,
                  next: nextPage,
                ),
              ],
            ),
          ),
          DashProgressIndicator(
            pageCount: 3,
            currentPage: currentPage,
          ),
          const Gap(38),
          BaseButton(
            buttonText: 'Sign up with your email',
            onPressed: () {
              context.pushReplacementNamed(AccountSetting.name);
              //  context.pushNamed(MainActivityPage.name);
            },
          ),
          const Gap(20),
          const ButtonDivider(),
          const Gap(20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Assets.images.google.path,
                width: 39.w,
                height: 39.h,
              ),
              const Gap(10),
              Image.asset(
                Assets.images.apple.path,
                width: 39.w,
                height: 39.h,
              ),
            ],
          ),
          const Gap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextView(
                text: 'Already have an account?',
              ),
              const Gap(5),
              TextView(
                onTap: () {
                  context.pushReplacementNamed(LoginPage.name);
                },
                text: 'Log in',
              ),
            ],
          ),
          const Gap(20),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextView(
                text: 'By tapping Sign up or Log in, you agree to our ',
                fontSize: 10,
              ),
              TextView(
                text: 'Terms',
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              TextView(
                text: 'Learn how we process your data in our ',
                fontSize: 10,
                fontWeight: FontWeight.normal,
              ),
              TextView(
                text: 'Privacy Policy',
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              TextView(
                text: ' and ',
                fontSize: 10,
                fontWeight: FontWeight.normal,
              ),
              TextView(
                text: 'Cookies Policy',
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ],
          )
        ],
      ),
    );
  }
}
