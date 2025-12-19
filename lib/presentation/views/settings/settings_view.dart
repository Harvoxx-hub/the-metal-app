import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/core/utils/strings/app_strings.dart';
import 'package:metal/presentation/viewmodels/settings/blocked_users_viewmodel.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/presentation/widgets/profile/profile_header.dart';
import 'package:metal/presentation/widgets/settings/edit_field.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/custom.toggle.dart';
import 'package:metal/widgets/text_views.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final blockedUsersState = ref.watch(blockedUsersViewModelProvider);
    final blocked = blockedUsersState.blockedUsers;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return BaseScreen(
      Header: AppStrings.settingsTitle,
      appBarState: AppBarState.HambugerWithHeader,
      body: SingleChildScrollView(
        child: ProfileHeader(
          myProfile: true,
          eye: false,
          metalId: user.metal ?? '',
          profileUrl: user.profilePhoto,
          child: Padding(
            padding: const EdgeInsets.only(top: 110, left: 20, right: 20),
            child: Container(
              padding: const EdgeInsets.only(top: 122),
              decoration: const BoxDecoration(
                color: AppColors.metalWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: ShapeDecoration(
                        color: const Color(0x0CD9197B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: TextView(text: user.username ?? ''),
                    ),
                    const Gap(40),
                    EditField(
                      text: "Show when I am online",
                      floatingLabel: "Privacy",
                      prefixIcon: CustomToggle(
                        initialValue: user.showOnline ?? false,
                        onChanged: (value) => _updateField('showOnline', value),
                      ),
                    ),
                    EditField(
                      text: "Always a Metal",
                      prefixIcon: CustomToggle(
                        initialValue: user.alwaysMetal ?? false,
                        onChanged: (value) => _updateField('alwaysMetal', value),
                      ),
                    ),
                    const Gap(20),
                    EditField(
                      text: AppStrings.receiveNotifications,
                      floatingLabel: AppStrings.notifications,
                      prefixIcon: CustomToggle(
                        initialValue: user.receiveNotification ?? false,
                        onChanged: (value) => _updateField('receiveNotification', value),
                      ),
                    ),
                    const Gap(20),
                    EditField(
                      text: AppStrings.showProfile,
                      floatingLabel: AppStrings.profileVisibility,
                      prefixIcon: CustomToggle(
                        initialValue: user.showMyProfile ?? false,
                        onChanged: (value) => _updateField('showMyProfile', value),
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
                        onTap: () => Navigator.pushNamed(context, AppRoutes.editPage),
                      ),
                    ),
                    const Gap(20),
                    EditField(
                      text: AppStrings.editPreferences,
                      floatingLabel: AppStrings.editPreferences,
                      prefixIcon: TextView(
                        text: AppStrings.edit,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.blueAccent,
                        underline: true,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.editPreferences),
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
                            Navigator.pushNamed(context, AppRoutes.blockedUser);
                          }
                        },
                      ),
                    ),
                    const Gap(20),
                    PlainButton(
                      buttonText: "Logout",
                      onPressed: _handleLogout,
                      textColor: AppColors.metalWhite,
                      color: AppColors.metalGray,
                      leftIcon: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.metalWhite,
                        size: 24,
                      ),
                    ),
                    const Gap(12),
                    PlainButton(
                      buttonText: "Delete my account",
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.delete),
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
        ),
      ),
    );
  }

  /// Update user field via single source of truth (userStateProvider)
  Future<void> _updateField(String field, dynamic value) async {
    await ref.read(userStateProvider.notifier).updateUserField(
      field: field,
      value: value,
    );
  }

  /// Handle logout
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await ref.read(userStateProvider.notifier).logout();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.onboarding,
        (route) => false,
      );
    }
  }
}
