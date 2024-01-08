import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/text_views.dart';

import '../onboarding/onboarding_page_view.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static const routeName = '/splash';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final String _asset = Assets.images.bg1.path;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () {
     
         context.pushReplacementNamed(OnboardingPageView.route);
 
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        /// We need use decoration to occupy entire screen
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_asset),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Assets.gifs.logo.path,
                width: 53.w,
                height: 53.h,
              ),
              Gap(10),
              TextView(
                text: 'Metal',
                fontSize: 32.sp,
              ),
               Gap(10),
              TextView(
                text: '...True Friendship is built \n on real connections',
                fontSize: 16.sp,
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}
