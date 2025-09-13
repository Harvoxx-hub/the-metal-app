import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

import 'package:metal/features/authentication/provider/metal.properties.notifier.dart';

import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/features/profile/presentation/widget/edit.field.dart';

class EditProfile extends ConsumerStatefulWidget {
  const EditProfile({super.key});

  @override
  ConsumerState<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userStateProvider).data;
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
            updateUser('gender', value);
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
            if (value != null) {
              // Find the metal object with the selected title
              var selectedMetal = metalProperties.metals!.firstWhere(
                (metal) => metal.title == value,
              );
              updateUser('metal', selectedMetal.id!);
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
            updateUser('passion', [p0!]);
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
              ...userState!.extraData!.toJson(),
              'maritalStatus': p0,
            };

            updateUser('extraData', updated);
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
              ...userState!.extraData!.toJson(),
              'religion': p0,
            };
            updateUser('extraData', updated);
          },
        ),
        const Gap(20),
        EditField(
          text: userState?.extraData?.profession ?? "Proffession",
          floatingLabel: "Profession",
          subLabel: "Edit",
          dropDownItems: metalProperties.profession,
          editType: EditType.dropdown,
          onSubLabel: (p0) {
            final updated = {
              ...userState!.extraData!.toJson(),
              'profession': p0,
            };

            updateUser('extraData', updated);
          },
        ),
        const Gap(20),
        EditField(
          text: userState?.bio ?? "Little Bio about me",
          floatingLabel: "Little Bio about me",
          subLabel: "Edit",
          editType: EditType.text,
          onSubLabel: (p0) {
            updateUser('bio', p0);
          },
        ),
        const Gap(20),
      ],
    );
  }

  void updateUser(String field, dynamic value) async {
    try {
      // Use the new UserStateNotifier for batch updates
      await ref.read(userStateProvider.notifier).updateUserField(
            field: field,
            value: value,
          );
    } catch (e) {
      // Handle error - could show snackbar or toast
      debugPrint('Error updating user: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
