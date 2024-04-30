import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import 'package:metal/core/services/auth.pref.service.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/authentication/provider/metal.properties.notifier.dart';
import 'package:metal/features/authentication/provider/update.profile.notifier.dart';
import 'package:metal/features/profile/presentation/widget/edit.field.dart';
import 'package:metal/features/profile/provider/delete.user.notifier.dart';
import 'package:metal/gen/assets.gen.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/plain.button.dart';

import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class PersonalTab extends ConsumerStatefulWidget {
  const PersonalTab({super.key});

  @override
  ConsumerState<PersonalTab> createState() => _PersonalTabState();
}

class _PersonalTabState extends ConsumerState<PersonalTab> {
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authProvider).data;
    final metalProperties = ref.watch(metalPropertiesProvider).data;
    ref.listen<DeleteUsersState>(deleteUserProvider, (prev, current) {
      if (current.isSuccess) {
        logout();
      }
    });
    return Column(
      children: [
        EditField(
          text: userState?.fullname ?? " Your name here",
          floatingLabel: "First name & Last name",
        ),
        Gap(20.h),
        EditField(
          text: "@${userState?.username}" ?? "Username",
          floatingLabel: "Username",
        ),
        Gap(20.h),
        EditField(
          text: userState?.email ?? "Email address",
          floatingLabel: "Email address",
          // subLabel: "Edit",
          onSubLabel: (value) {
            Navigator.pushNamed(
              context,
              AppRoutes.updateEmailPage,
            );
          },
        ),
        Gap(20.h),
        EditField(
          text: userState?.phone ?? "Phone Number",
          floatingLabel: "Phone Number",
          //  subLabel: "Edit",
          onSubLabel: (value) {
            Navigator.pushNamed(
              context,
              AppRoutes.updatePhoneNumberPage,
            );
          },
        ),
        Gap(20.h),
        EditField(
          text: userState?.gender ?? "Gender",
          floatingLabel: "Gender",
          subLabel: "Edit",
          dropDownItems: [
            "Male",
            "Female",
            "Prefer not to say",
            "Others",
          ],
          editType: EditType.dropdown,
          onSubLabel: (value) {
            updateUser(UserModel(gender: value));
          },
        ),
        Gap(20.h),
        EditField(
          text: userState?.metal?.title ?? "Metal that represents your value",
          floatingLabel: " Metal that represents your value",
          subLabel: "Edit",
          dropDownItems: metalProperties!.metals!
              .map((passion) => passion.title ?? "")
              .toList(),
          editType: EditType.dropdown,
          onSubLabel: (value) {
            {
              if (value != null && metalProperties != null) {
                // Find the metal object with the selected title
                var selectedMetal = metalProperties!.metals!.firstWhere(
                  (metal) => metal.title == value,
                );
                if (selectedMetal != null) {
                  // Assign the selected metal object to the UserModel
                  updateUser(UserModel(metal: selectedMetal));
                }
              }
            }
          },
        ),
        Gap(20.h),
        EditField(
          text: userState?.passion?.join(",") ?? "Passion/Interest",
          floatingLabel: "Passion/Interest",
          subLabel: "Edit",
          dropDownItems: metalProperties!.passions!
              .map((passion) => passion.title ?? "")
              .toList(),
          editType: EditType.dropdown,
          onSubLabel: (p0) {
            updateUser(UserModel(passion: [p0!]));
          },
        ),
        Gap(20.h),
        EditField(
          text: userState?.extra_data?.marital_status ?? "Marital status",
          floatingLabel: "Marital status",
          subLabel: "Edit",
          dropDownItems: metalProperties.marriageStatus,
          editType: EditType.dropdown,
          onSubLabel: (p0) {
            updateUser(UserModel(extra_data: ExtraData(marital_status: p0)));
          },
        ),
        Gap(20.h),
        EditField(
          text: userState?.extra_data?.religion ?? "Religion",
          floatingLabel: "Religion",
          subLabel: "Edit",
          dropDownItems: metalProperties.religion,
          editType: EditType.dropdown,
          onSubLabel: (p0) {
            updateUser(UserModel(extra_data: ExtraData(religion: p0)));
          },
        ),
        Gap(20.h),
        EditField(
          text: userState!.address.toString(),
          floatingLabel: "Home address details",
          subLabel: "Edit",
          editType: EditType.text,
          onSubLabel: (p0) {
            updateUser(UserModel(address: Address(apartment_number: p0)));
          },
        ),

        Gap(20.h),
        EditField(
          text: userState?.extra_data?.profession ?? "Proffession",
          floatingLabel: "Proffession",
          subLabel: "Edit",
          dropDownItems: metalProperties.profession,
          editType: EditType.dropdown,
          onSubLabel: (p0) {
            updateUser(UserModel(extra_data: ExtraData(profession: p0)));
          },
        ),

        // Gap(20.h),
        // EditFormField(
        //   floatingLabel: 'Interested in',
        //   label: 'Interested in',
        //   controller: _intrestedInController,
        //   keyboardType: TextInputType.name,
        //   radius: 10,
        //   editButton: true,
        //   onEditTap: () {},
        // ),
        Gap(20.h),
        EditField(
          text: userState?.description ?? "Little Bio about me",
          floatingLabel: "Little Bio about me",
          subLabel: "Edit",
          editType: EditType.text,
          onSubLabel: (p0) {
            updateUser(UserModel(description: p0));
          },
        ),

        Gap(20.h),
        PlainButton(
          buttonText: "Delete my account",
          onPressed: () {
            ref.read(deleteUserProvider.notifier).DeleteUser();
            // logout();
          },
          textColor: AppColors.metalWhite,
          color: AppColors.metalRed,
          leftIcon: SvgPicture.asset(
            Assets.icons.profileTrash.path,
            height: 24,
            width: 24,
          ),
        )
      ],
    );
  }

  void updateUser(UserModel user) {
    ref.watch(updateProfileProvider.notifier).updateParticularInfor(user);
  }

  void logout() {
    ref.read(authManagerProvider).deleteAccessToken();
    ref.read(authManagerProvider).deleteLoginState();
    ref.read(authManagerProvider).deleteRefreshToken();

    ZegoUIKitPrebuiltCallInvitationService().uninit();
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.onboarding, (route) => false);
  }
}
