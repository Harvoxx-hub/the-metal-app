import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/core/services/auth.manager.dart';
import 'package:metal/features/authentication/presentation/login/login.screen.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/verification/verification.video.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/feedback/feedback.page.dart';
import 'package:metal/features/my.metals/my.melted.metals.dart';
import 'package:metal/features/refer.earn/refer.earn.dart';
import 'package:metal/features/settings/settings.page.dart';
import 'package:metal/features/upgrade/upgrade.page.dart';
import 'package:metal/res/res.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:provider/provider.dart';

class NavDrawer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _authState = ref.watch(authProvider).data;
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
                      TextView(
                        text: "Metal",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: SvgPicture.asset(
                          Assets.icons.xClose.path,
                          height: 24,
                          width: 24,
                        ),
                      )
                    ],
                  ),
                  Gap(36),
                  Row(
                    children: [
                      ProfilePhoto(
                        verfly: false,
                        size: 51,
                      ),
                      // Image.asset(Assets.images.navBarProfile.path),
                      Gap(19),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextView(
                            text: _authState!.fullname!,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                          TextView(
                            text: "@${_authState!.username!}",
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              )),
          Gap(51),
          ListTile(
            leading: Container(
              height: 46,
              width: 46,
              decoration: ShapeDecoration(
                color: AppColors.metalPinkColour.withOpacity(0.06),
                shape: OvalBorder(),
              ),
              child: Center(
                  child: SvgPicture.asset(
                Assets.icons.user2.path,
                height: 24,
                width: 24,
              )),
            ),
            title: TextView(text: "My melted metals"),
            onTap: () => {context.pushNamed(MyMeltedMetals.name)},
          ),
          Gap(20),
          ListTile(
            leading: Container(
              height: 46,
              width: 46,
              decoration: ShapeDecoration(
                color: AppColors.metalPinkColour.withOpacity(0.06),
                shape: OvalBorder(),
              ),
              child: Center(
                  child: SvgPicture.asset(
                Assets.icons.rocketLaunch.path,
                height: 24,
                width: 24,
              )),
            ),
            title: TextView(text: "Upgrade to Metal Plus"),
            onTap: () => {context.pushNamed(UpgradePage.name)},
          ),
          Gap(20),
          ListTile(
            leading: Container(
              height: 46,
              width: 46,
              decoration: ShapeDecoration(
                color: AppColors.metalPinkColour.withOpacity(0.06),
                shape: OvalBorder(),
              ),
              child: Center(
                  child: SvgPicture.asset(
                Assets.icons.user2.path,
                height: 24,
                width: 24,
              )),
            ),
            title: TextView(text: "Refer & Earn"),
            onTap: () => {context.pushNamed(ReferEarn.name)},
          ),
          Gap(20),
          ListTile(
            leading: Container(
              height: 46,
              width: 46,
              decoration: ShapeDecoration(
                color: AppColors.metalPinkColour.withOpacity(0.06),
                shape: OvalBorder(),
              ),
              child: Center(
                  child: SvgPicture.asset(
                Assets.icons.pencilLine.path,
                height: 24,
                width: 24,
              )),
            ),
            title: TextView(text: "Verify your account"),
            onTap: () => {context.pushNamed(VerificationVideo.name)},
          ),
          Gap(20),
          ListTile(
            leading: Container(
              height: 46,
              width: 46,
              decoration: ShapeDecoration(
                color: AppColors.metalPinkColour.withOpacity(0.06),
                shape: OvalBorder(),
              ),
              child: Center(
                  child: SvgPicture.asset(
                Assets.icons.pencilLine.path,
                height: 24,
                width: 24,
              )),
            ),
            title: TextView(text: "Let’s hear from you"),
            onTap: () => {context.pushNamed(FeedBackPage.name)},
          ),
          Gap(20),
          ListTile(
            leading: Container(
              height: 46,
              width: 46,
              decoration: ShapeDecoration(
                color: AppColors.metalPinkColour.withOpacity(0.06),
                shape: OvalBorder(),
              ),
              child: Center(
                  child: SvgPicture.asset(
                Assets.icons.gear.path,
                height: 24,
                width: 24,
              )),
            ),
            title: TextView(text: "Settings"),
            onTap: () => {context.pushNamed(SettingPage.name)},
          ),
          Gap(20),
          ListTile(
            leading: Container(
              height: 46,
              width: 46,
              decoration: ShapeDecoration(
                color: AppColors.metalPinkColour.withOpacity(0.06),
                shape: OvalBorder(),
              ),
              child: Center(
                  child: SvgPicture.asset(
                Assets.icons.signOut.path,
                height: 24,
                width: 24,
              )),
            ),
            title: TextView(text: "Log out"),
            onTap: () => {
              logout(),
              context.pushReplacementNamed(LoginPage.name),
            },
          ),
          Gap(40),
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                Gap(19.w),
                TextView(
                  text: "V 1.10",
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

  void logout() {
    final authManager = AuthManager();
    authManager.saveLoginState(LoginState.loggedOut);
  }
}
