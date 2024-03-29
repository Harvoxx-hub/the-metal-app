import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/eyes/presentation/eyes.intro.screen.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/profile/tab.screen/discovery.tab.dart';
import 'package:metal/features/profile/tab.screen/metal.plan.tab.dart';
import 'package:metal/features/profile/tab.screen/personal.tab.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/tab/base.tab.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).data;
    return SingleChildScrollView(
      child: ProfileHeader(
          user: user!,
          child: Padding(
            padding: const EdgeInsets.only(top: 110, left: 20, right: 20),
            child: Container(
              padding: const EdgeInsets.only(
                top: 122,
              ),
              decoration: const BoxDecoration(
                  color: AppColors.metalWhite,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35))),
              child: Column(
                children: [
                  BaseTab(
                    tabs: [
                      BaseTabModel(
                          child: const PersonalTab(), title: "Personal"),
                      BaseTabModel(
                          child: const MetalPlanTab(), title: "Metal Plan"),
                      BaseTabModel(
                          child: const DiscoveryTab(), title: "Discovery")
                    ],
                  )
                ],
              ),
            ),
          )),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.child,
    required this.user,
    this.eye = true,
  });

  final Widget child;
  final UserModel user;
  final bool eye;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppbarBackground(),
            ],
          ),
          child,
          Positioned(
            top: 19,
            left: 0,
            right: 0,
            child: user.metal == null
                ? const ProfilePhoto(
                    size: 170,
                    verfly: false,
                  )
                : ProfilePhoto(
                    size: 170,
                    verfly: false,
                    photourl: user.metal!.img!,
                  ),
          ),
          eye
              ? Positioned(
                  top: 140,
                  right: 50.w,
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.eyesIntro,
                    ),
                    child: SvgPicture.asset(
                      Assets.icons.eye.path,
                      height: 40,
                      width: 40,
                    ),
                  ))
              : SizedBox(),
        ],
      ),
    );
  }
}

class AppbarBackground extends StatelessWidget {
  const AppbarBackground({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220.h,
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [Color(0xFFDB217A), Color(0xFFF00E3E)],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(35.sp),
            bottomRight: Radius.circular(35.sp),
          )),
      child: const Padding(
        padding: EdgeInsets.only(left: 24.0, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [],
        ),
      ),
    );
  }
}
