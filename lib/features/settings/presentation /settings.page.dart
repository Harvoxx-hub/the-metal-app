import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/profile/presentation/widget/profile.header.dart';
import 'package:metal/features/settings/provider/get.block.user.notifier.dart';
import 'package:metal/gen/assets.gen.dart';

import 'package:metal/features/profile/presentation/widget/edit.field.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/custom.toggle.dart';
import 'package:metal/widgets/shimmer.loading.dart';
import 'package:metal/widgets/text_views.dart';

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key});
  static const name = 'settingPage';
  static const route = name;

  @override
  ConsumerState<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).data;
    final blocked = ref.watch(getBlockUserProvider);
    return BaseScreen(
      Header: "Settings",
      appBarState: AppBarState.HambugerWithHeader,
      body: SingleChildScrollView(
        child: ProfileHeader(
            eye: false,
            metal: user!.metal!,
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
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: ShapeDecoration(
                            color: const Color(0x0CD9197B),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                          ),
                          child: TextView(text: user.username!),
                        ),
                        const Gap(40),
                        EditField(
                          text: "Show when I am online",
                          floatingLabel: "Privacy",
                          prefixIcon: CustomToggle(
                            initialValue: true, // Set the initial value
                            onChanged: (value) {
                              // Handle the state change
                              print('Toggle state changed: $value');
                            },
                          ),
                        ),
                        EditField(
                          text: "Always a Metal",
                          prefixIcon: CustomToggle(
                            initialValue: true, // Set the initial value
                            onChanged: (value) {
                              // Handle the state change
                              print('Toggle state changed: $value');
                            },
                          ),
                        ),
                        const Gap(20),
                        EditField(
                          text: "I want to receive notifications",
                          floatingLabel: "Notifications",
                          prefixIcon: CustomToggle(
                            initialValue: true, // Set the initial value
                            onChanged: (value) {
                              // Handle the state change
                              print('Toggle state changed: $value');
                            },
                          ),
                        ),
                        const Gap(20),
                        EditField(
                          text: "Show my profile to other metals",
                          floatingLabel: "Profile visibility",
                          prefixIcon: CustomToggle(
                            initialValue: true, // Set the initial value
                            onChanged: (value) {
                              // Handle the state change
                              print('Toggle state changed: $value');
                            },
                          ),
                        ),
                        const Gap(20),
                        EditField(
                          text: "Make changes to my profile",
                          floatingLabel: "Edit profile",
                          prefixIcon: TextView(
                              text: "Edit",
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.blueAccent,
                              underline: true,
                              onTap: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.editPage);
                              }),
                        ),
                        const Gap(20),
                        EditField(
                          text: "Activate voice notes",
                          floatingLabel: "Call Preferences",
                          prefixIcon: CustomToggle(
                            initialValue: true, // Set the initial value
                            onChanged: (value) {
                              // Handle the state change
                              print('Toggle state changed: $value');
                            },
                          ),
                        ),
                        EditField(
                          text: "Active video call",
                          prefixIcon: CustomToggle(
                            initialValue: true, // Set the initial value
                            onChanged: (value) {
                              // Handle the state change
                              print('Toggle state changed: $value');
                            },
                          ),
                        ),
                        EditField(
                          text: "Activate voice call",
                          prefixIcon: CustomToggle(
                            initialValue: true, // Set the initial value
                            onChanged: (value) {
                              // Handle the state change
                              print('Toggle state changed: $value');
                            },
                          ),
                        ),
                        const Gap(20),
                        ShimmerLoading(
                          isLoading: blocked.isLoading,
                          child: EditField(
                            text: blocked.data?.length.toString() ?? "0",
                            floatingLabel: "*Blocked Contacts*",
                            prefixIcon: TextView(
                                text: "View",
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRoutes.blockedUser);
                                }),
                          ),
                        ),
                        const Gap(20),
                        PlainButton(
                          buttonText: "Delete my account",
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.delete);
                          },
                          textColor: AppColors.metalWhite,
                          color: AppColors.metalRed,
                          leftIcon: SvgPicture.asset(
                            Assets.icons.profileTrash.path,
                            height: 24,
                            width: 24,
                          ),
                        ),
                        const Gap(20),
                      ],
                    ),
                  ),
                ),
              ),
            )),
      ),
    );
  }
}
