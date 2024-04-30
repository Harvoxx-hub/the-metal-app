import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/authentication/provider/metal.properties.notifier.dart';
import 'package:metal/features/authentication/provider/update.profile.notifier.dart';
import 'package:metal/features/profile/presentation/widget/edit.field.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/settings/widget/blocked.card.dart';
import 'package:metal/res/colors/cr_colors.dart';

class EditPage extends ConsumerWidget {
  const EditPage({super.key});
 

  @override
  Widget build(BuildContext context, WidgetRef ref) {
       final userState = ref.watch(authProvider).data;
    final metalProperties = ref.watch(metalPropertiesProvider).data;
    return BaseScreen(
      appBarState: AppBarState.BackWithHeader,
      Header: "Make Changes to Profile",
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
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
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 29, left: 9, right: 9),
              child: Container(
                padding: const EdgeInsets.only(top: 55, left: 22, right: 22),
                decoration: const BoxDecoration(
                    color: AppColors.metalWhite,
                    borderRadius: BorderRadius.all(
                      Radius.circular(35),
                    )),
                child: Column(
                  children: [
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
            updateUser(UserModel(gender: value), ref);
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
                  updateUser(UserModel(metal: selectedMetal), ref);
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
            updateUser(UserModel(passion: [p0!]), ref);
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
            updateUser(UserModel(extra_data: ExtraData(marital_status: p0)),ref);
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
            updateUser(UserModel(extra_data: ExtraData(religion: p0)),ref);
          },
        ),
        Gap(20.h),
        EditField(
          text: userState!.address.toString(),
          floatingLabel: "Home address details",
          subLabel: "Edit",
          editType: EditType.text,
          onSubLabel: (p0) {
            updateUser(UserModel(address: Address(apartment_number: p0)), ref);
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
            updateUser(UserModel(extra_data: ExtraData(profession: p0)), ref);
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
            updateUser(UserModel(description: p0), ref);
          },
        ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
   void updateUser(UserModel user, ref) {
    ref.watch(updateProfileProvider.notifier).updateParticularInfor(user);
  }
}
