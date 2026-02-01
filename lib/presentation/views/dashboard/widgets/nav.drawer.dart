import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_svg/svg.dart';

import 'package:metal/presentation/viewmodels/profile/metal_properties_provider.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/res/res.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

class NavDrawer extends ConsumerWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final metalProperties = ref.watch(metalPropertiesProvider).data;

    // Early return if no user
    if (user == null || metalProperties == null) {
      return const Drawer(child: Center(child: CircularProgressIndicator()));
    }

    final metal = metalProperties.metals?.firstWhere(
      (element) => element.id == user.metal,
      orElse: () => metalProperties.metals![0],
    );

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
              decoration: BoxDecoration(
                  color: AppColors.metalPinkColour.withOpacity(0.07)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset(
                        Assets.images.logo.path,
                        height: 19,
                        width: 21,
                      ),
                      const TextView(
                        text: "Metal",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: SvgPicture.asset(
                          Assets.icons.xClose.path,
                          height: 24,
                          width: 24,
                        ),
                      )
                    ],
                  ),
                  const Gap(36),
                  Row(
                    children: [
                      ProfilePhoto(
                        verfly: false,
                        size: 51,
                        meltId: user.metal ?? '',
                        imgUrl: user.profilePhoto,
                      ),
                      const Gap(19),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextView(
                            text: user.fullname ?? '',
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                          TextView(
                            text:
                                "@${user.username ?? ''}_${metal?.title ?? ''}",
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              )),
          const Gap(51),
          ListTile(
            leading: Container(
              height: 46,
              width: 46,
              decoration: ShapeDecoration(
                color: AppColors.metalPinkColour.withOpacity(0.06),
                shape: const OvalBorder(),
              ),
              child: Center(
                  child: SvgPicture.asset(
                Assets.icons.user2.path,
                height: 24,
                width: 24,
              )),
            ),
            title: const TextView(text: "My melted metals"),
            onTap: () => {
              Navigator.pushNamed(
                context,
                AppRoutes.myMeltedMetals,
              )
            },
          ),
          const Gap(20),
          // ListTile(
          //   leading: Container(
          //     height: 46,
          //     width: 46,
          //     decoration: ShapeDecoration(
          //       color: AppColors.metalPinkColour.withOpacity(0.06),
          //       shape: const OvalBorder(),
          //     ),
          //     child: Center(
          //         child: SvgPicture.asset(
          //       Assets.icons.rocketLaunch.path,
          //       height: 24,
          //       width: 24,
          //     )),
          //   ),
          //   title: TextView(
          //       text: user.subscription == null
          //           ? "Upgrade to Metal Plus"
          //           : " Metal Plus"),
          //   onTap: () => {
          //     Navigator.pushNamed(
          //       context,
          //       AppRoutes.upgradePage,
          //     )
          //   },
          // ),
          const Gap(20),
          ListTile(
            leading: Container(
              height: 46,
              width: 46,
              decoration: ShapeDecoration(
                color: AppColors.metalPinkColour.withOpacity(0.06),
                shape: const OvalBorder(),
              ),
              child: Center(
                  child: SvgPicture.asset(
                Assets.icons.user2.path,
                height: 24,
                width: 24,
              )),
            ),
            title: const TextView(text: "Refer & Earn"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.referEarn);
            },
          ),
          const Gap(20),
          // ListTile(
          //   leading: Container(
          //     height: 46,
          //     width: 46,
          //     decoration: ShapeDecoration(
          //       color: AppColors.metalPinkColour.withOpacity(0.06),
          //       shape: const OvalBorder(),
          //     ),
          //     child: Center(
          //         child: SvgPicture.asset(
          //       Assets.icons.videoCamera.path,
          //       height: 24,
          //       width: 24,
          //     )),
          //   ),
          //   title: const TextView(text: "Watch tutorial"),
          //   onTap: () => {},
          // ),
          const Gap(20),
          ListTile(
            leading: Container(
              height: 46,
              width: 46,
              decoration: ShapeDecoration(
                color: AppColors.metalPinkColour.withOpacity(0.06),
                shape: const OvalBorder(),
              ),
              child: Center(
                  child: SvgPicture.asset(
                Assets.icons.pencilLine.path,
                height: 24,
                width: 24,
              )),
            ),
            title: const TextView(text: "Let's hear from you"),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.feedback);
            },
          ),
          const Gap(20),
          ListTile(
            leading: Container(
              height: 46,
              width: 46,
              decoration: ShapeDecoration(
                color: AppColors.metalPinkColour.withOpacity(0.06),
                shape: const OvalBorder(),
              ),
              child: Center(
                  child: SvgPicture.asset(
                Assets.icons.gear.path,
                height: 24,
                width: 24,
              )),
            ),
            title: const TextView(text: "Settings"),
            onTap: () => {
              Navigator.pushNamed(
                context,
                AppRoutes.settingPage,
              )
            },
          ),
          const Gap(20),
          ListTile(
            leading: Container(
              height: 46,
              width: 46,
              decoration: ShapeDecoration(
                color: AppColors.metalPinkColour.withOpacity(0.06),
                shape: const OvalBorder(),
              ),
              child: Center(
                  child: SvgPicture.asset(
                Assets.icons.signOut.path,
                height: 24,
                width: 24,
              )),
            ),
            title: const TextView(text: "Log out"),
            onTap: () async {
              // Use single source of truth for logout
              await ref.read(userStateProvider.notifier).logout();
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.onboarding, (route) => false);
            },
          ),
          const Gap(40),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: TextView(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      text:
                          "...when our eyes are closed, our hearts talk and create real, lasting communications."),
                ),
                Gap(19),
                TextView(
                  text:
                      ref.read(metalPropertiesProvider.notifier).currentVersion,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
