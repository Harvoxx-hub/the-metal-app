import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/authentication/provider/metal.properties.notifier.dart';
import 'package:metal/features/authentication/provider/update.profile.notifier.dart';
import 'package:metal/features/profile/presentation/widget/edit.field.dart';

class EditProfile extends ConsumerStatefulWidget {
  const EditProfile({super.key});

  @override
  ConsumerState<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {
 
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authProvider).data;
    final metalProperties = ref.watch(metalPropertiesProvider).data;
   
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
            // Navigator.pushNamed(
            //   context,
            // //  AppRoutes.updateEmailPage,
            // );
          },
        ),
        Gap(20.h),
        EditField(
          text: userState?.phone ?? "Phone Number",
          floatingLabel: "Phone Number",
          //  subLabel: "Edit",
          onSubLabel: (value) {
            // Navigator.pushNamed(
            //   context,
            //  // AppRoutes.updatePhoneNumberPage,
            // );
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
          outboundWidget: true,
          onSubLabel: (p0) {
            updateUser(UserModel(address: p0 as Address));
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
       
      ],
    );
  }


  void updateUser(UserModel user) {
    ref.watch(updateProfileProvider.notifier).updateParticularInfor(user);
  }

}