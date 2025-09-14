import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_svg/svg.dart';

import 'package:metal/core/services/firebase.service.db.dart';
 
import 'package:metal/features/authentication/provider/metal.properties.notifier.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/res.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

class NavDrawer extends ConsumerWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(userStateProvider).data;
    final metalProperties = ref.watch(metalPropertiesProvider).data;

    final metal = metalProperties!.metals!.firstWhere(
      (element) => element.id == authState!.metal,
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
                        meltId: authState!.metal!,
                        imgUrl: authState?.profilePhoto ?? null,
                      ),
                      const Gap(19),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextView(
                            text: authState!.fullname!,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                          TextView(
                            text: "@${authState.username!}_${metal.title}",
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
          //       text: authState.subscription == null
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
            onTap: () => {
              Navigator.pushNamed(
                context,
                AppRoutes.referEarn,
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
          //       Assets.icons.videoCamera.path,
          //       height: 24,
          //       width: 24,
          //     )),
          //   ),
          //   title: const TextView(text: "Watch tutorial"),
          //   onTap: () => {},
          // ),
          const Gap(20),
          (authState.isVerified == false)
              ? Column(
                  children: [
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
                          Assets.icons.checkVerified.path,
                          color: AppColors.metalBlack75,
                          height: 24,
                          width: 24,
                        )),
                      ),
                      title: const TextView(text: "Verify your account"),
                      onTap: () => {
                               
            Navigator.pushNamed(context, AppRoutes.workEmail)
                      },
                    ),
                    const Gap(20),
                  ],
                )
              : const SizedBox(),
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
            onTap: () => {
              Navigator.pushNamed(
                context,
                AppRoutes.feedBackPage,
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
            onTap: () => {
              logout(ref),
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.login, (route) => false)
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

  void logout(WidgetRef ref) {
    FirebaseServiceDb.instance.auth.signOut();
  }
}
