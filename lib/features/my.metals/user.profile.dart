import 'package:flutter/material.dart';

import 'package:gap/gap.dart';

import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

import 'package:metal/features/profile/presentation/widget/edit.field.dart';
import 'package:metal/features/profile/presentation/widget/profile.header.dart';
 
import 'package:metal/res/colors/cr_colors.dart';

import 'package:metal/widgets/text_views.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key, required this.user});
  static const name = 'userProfilePage';
  static const route = name;
  final UserModel user;
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      Header: "User Profile",
      body: ProfileHeader(
          eye: false,
          metal: user.metal!,
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
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: ShapeDecoration(
                        color: const Color(0x0CD9197B),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      child: TextView(text: "@ ${user.username}"),
                    ),
                    const Gap(40),
                    EditField(
                      text: user.fullname!,
                      floatingLabel: " First name & Last name",
                    ),
                    const Gap(20),
                    EditField(
                      text: "@${user.username}",
                      floatingLabel: "Username",
                    ),
                    const Gap(20),
                    EditField(
                      text: user.DOB!,
                      floatingLabel: "Date of Birth (DD-MM)",
                    ),
                    const Gap(20),
                    EditField(
                      text: user.metal!.title!,
                      floatingLabel: "Metal that represents your value",
                    ),
                    const Gap(20),
                    EditField(
                      text: user.passion!.join(", "),
                      floatingLabel: "Passion/Interests",
                    ),
                    const Gap(20),
                    EditField(
                      text: user.extra_data!.marital_status!,
                      floatingLabel: "Marital status",
                    ),
                    const Gap(20),
                    EditField(
                      text: user.extra_data!.religion!,
                      floatingLabel: "Religion",
                    ),
                    const Gap(20),
                    EditField(
                      text: user.extra_data!.profession!,
                      floatingLabel: "Profession",
                    ),
                    const Gap(20),
                    EditField(
                      text: user.connect_with!,
                      floatingLabel: "Interested in",
                    ),
                    const Gap(20),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
