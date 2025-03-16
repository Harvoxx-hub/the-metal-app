import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    final metal = metalProperties!.metals!.firstWhere(
      (element) => element.id == userState!.metal,
      orElse: () =>
          metalProperties.metals![0], // Fallback in case no match is found
    );

    return Column(
      children: [
        EditField(
          text: userState?.fullname ?? " Your name here",
          floatingLabel: "First name & Last name",
        ),
        const Gap(20),
        EditField(
          text: "@${userState?.username}",
          floatingLabel: "Username",
        ),
        const Gap(20),
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
        const Gap(20),
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
        const Gap(20),
        EditField(
          text: userState?.gender ?? "Gender",
          floatingLabel: "Gender",
          subLabel: "Edit",
          dropDownItems: const [
            "Male",
            "Female",
            "Prefer not to say",
            "Others",
          ],
          editType: EditType.dropdown,
          onSubLabel: (value) {
           final updated = {
            'gender': value,
          };
          updateUser(updated);
          },
        ),
        const Gap(20),
        EditField(
          text: metal.title ?? "Metal that represents your value",
          floatingLabel: " Metal that represents your value",
          subLabel: "Edit",
          dropDownItems: metalProperties!.metals!
              .map((passion) => passion.title ?? "")
              .toList(),
          editType: EditType.dropdown,
          onSubLabel: (value) {
            {
              if (value != null) {
                // Find the metal object with the selected title
                var selectedMetal = metalProperties.metals!.firstWhere(
                  (metal) => metal.title == value,
                );
                // Assign the selected metal object to the UserModel
    final updated = {
              'metal': selectedMetal.id,
            };
            updateUser(updated);
              }
            }
          },
        ),
        const Gap(20),
        EditField(
          text: userState?.passion?.join(",") ?? "Passion/Interest",
          floatingLabel: "Passion/Interest",
          subLabel: "Edit",
          dropDownItems: metalProperties.passions!
              .map((passion) => passion.title ?? "")
              .toList(),
          editType: EditType.dropdown,
          onSubLabel: (p0) {
            final updated = {
              'passion': [p0!],
            };
            updateUser(updated);
          },
        ),
        const Gap(20),
        EditField(
          text: userState?.extraData?.maritalStatus ?? "Marital status",
          floatingLabel: "Marital status",
          subLabel: "Edit",
          dropDownItems: metalProperties.marriageStatus,
          editType: EditType.dropdown,
          onSubLabel: (p0) {
            final updated = {
              'extraData': {
                ...userState!.extraData!.toJson(),
                'maritalStatus': p0,
              }
            };
            updateUser(updated);
          
          },
        ),
        const Gap(20),
        EditField(
          text: userState?.extraData?.religion ?? "Religion",
          floatingLabel: "Religion",
          subLabel: "Edit",
          dropDownItems: metalProperties.religion,
          editType: EditType.dropdown,
          onSubLabel: (p0) {
         final updated = {
            'extraData': {
              ...userState!.extraData!.toJson(),
              'religion': p0,
            }
          };
          updateUser(updated);
          },
        ),
        const Gap(20),
        EditField(
          text: userState!.address.toString(),
          floatingLabel: "Home address details",
          subLabel: "Edit",
          editType: EditType.text,
          outboundWidget: true,
          onSubLabel: (p0) {
          final updated = {
            'address': p0,
          };
          updateUser(updated);
          },
        ),
        const Gap(20),
        EditField(
          text: userState.extraData?.profession ?? "Proffession",
          floatingLabel: "Profession",
          subLabel: "Edit",
          dropDownItems: metalProperties.profession,
          editType: EditType.dropdown,
          onSubLabel: (p0) {
            final updated = {
              'extraData': {
                ...userState.extraData!.toJson(),
                'profession': p0,
              }
            };
            updateUser(updated);
          },
        ),
        // Gap(20 ),
        // EditFormField(
        //   floatingLabel: 'Interested in',
        //   label: 'Interested in',
        //   controller: _intrestedInController,
        //   keyboardType: TextInputType.name,
        //   radius: 10,
        //   editButton: true,
        //   onEditTap: () {},
        // ),
        const Gap(20),
        EditField(
          text: userState.description ?? "Little Bio about me",
          floatingLabel: "Little Bio about me",
          subLabel: "Edit",
          editType: EditType.text,
          onSubLabel: (p0) {
            final updated = {
              'description': p0,
            };

            updateUser(updated);
          },
        ),

        const Gap(20),
      ],
    );
  }

  void updateUser(Map<String, dynamic> user) {
    ref.watch(updateProfileProvider.notifier).updateUserData(user);
    ref.watch(updateProfileProvider.notifier).sendUserUpdate();
  }
}
