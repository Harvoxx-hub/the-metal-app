import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/core/utils/strings/app_strings.dart';
 
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/features/profile/presentation/widget/profile.header.dart';
import 'package:metal/features/settings/provider/get.blocked.user.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/profile/presentation/widget/edit.field.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/custom.toggle.dart';
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
    final user = ref.watch(userStateProvider).data;
    final blocked = ref.watch(getBlockUserProvider).data;
    return BaseScreen(
      Header: AppStrings.settingsTitle,
      appBarState: AppBarState.HambugerWithHeader,
      body: SingleChildScrollView(
        child: ProfileHeader(
            myProfile: true,
            eye: false,
            metalId: user!.metal!,
            profileUrl: user.profilePhoto,
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
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
                          initialValue: user.showOnline,
                          onChanged: (value) async {
                            await ref
                                .read(userStateProvider.notifier)
                                .updateUserField(
                                  field: 'showOnline',
                                  value: value,
                                );
                          },
                        ),
                      ),
                      EditField(
                        text: "Always a Metal",
                        prefixIcon: CustomToggle(
                          initialValue: user.alwaysMetal,
                          onChanged: (value) async {
                            await ref
                                .read(userStateProvider.notifier)
                                .updateUserField(
                                  field: 'alwaysMetal',
                                  value: value,
                                );
                          },
                        ),
                      ),
                      const Gap(20),
                      EditField(
                        text: AppStrings.receiveNotifications,
                        floatingLabel: AppStrings.notifications,
                        prefixIcon: CustomToggle(
                          initialValue: user.receiveNotification,
                          onChanged: (value) async {
                            await ref
                                .read(userStateProvider.notifier)
                                .updateUserField(
                                  field: 'receiveNotification',
                                  value: value,
                                );
                          },
                        ),
                      ),
                      const Gap(20),
                      EditField(
                        text: AppStrings.showProfile,
                        floatingLabel: AppStrings.profileVisibility,
                        prefixIcon: CustomToggle(
                          initialValue: user.showMyProfile,
                          onChanged: (value) async {
                            await ref
                                .read(userStateProvider.notifier)
                                .updateUserField(
                                  field: 'showMyProfile',
                                  value: value,
                                );
                          },
                        ),
                      ),
                      const Gap(20),
                      EditField(
                        text: AppStrings.editProfile,
                        floatingLabel: AppStrings.editProfile,
                        prefixIcon: TextView(
                            text: AppStrings.edit,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.blueAccent,
                            underline: true,
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.editPage);
                            }),
                      ),
                      const Gap(20),
                      EditField(
                        text: "Activate voice notes",
                        floatingLabel: "Call Preferences",
                        prefixIcon: CustomToggle(
                          initialValue: user.activateVoiceNote,
                          onChanged: (value) async {
                            await ref
                                .read(userStateProvider.notifier)
                                .updateUserField(
                                  field: 'activateVoiceNote',
                                  value: value,
                                );
                          },
                        ),
                      ),
                      EditField(
                        text: "Activate video call",
                        prefixIcon: CustomToggle(
                          initialValue: user.activateVideoCall,
                          onChanged: (value) async {
                            await ref
                                .read(userStateProvider.notifier)
                                .updateUserField(
                                  field: 'activateVideoCall',
                                  value: value,
                                );
                          },
                        ),
                      ),
                      EditField(
                        text: "Activate voice call",
                        prefixIcon: CustomToggle(
                          initialValue: user.activateVoiceCall,
                          onChanged: (value) async {
                            await ref
                                .read(userStateProvider.notifier)
                                .updateUserField(
                                  field: 'activateVoiceCall',
                                  value: value,
                                );
                          },
                        ),
                      ),
                      const Gap(20),
                      EditField(
                        text: blocked?.length.toString() ?? "0",
                        floatingLabel: "*Blocked Contacts*",
                        prefixIcon: TextView(
                            text: "View",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            onTap: () {
                              if ((blocked?.length ?? 0) >= 1) {
                                Navigator.pushNamed(
                                    context, AppRoutes.blockedUser);
                              }
                            }),
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
            )),
      ),
    );
  }
}
