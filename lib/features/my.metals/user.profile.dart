import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

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
                    // EditField(
                    //   text: user.fullname!,
                    //   floatingLabel: " First name & Last name",
                    // ),
                    //  const Gap(20),
                    EditField(
                      text: "@${user.username}",
                      floatingLabel: "Username",
                    ),
                    const Gap(20),
                    EditField(
                      text: getAgeRange(user.dob!) + " years",
                      floatingLabel: "Age Range",
                    ),
                    const Gap(20),
                    EditField(
                      text: user.metal!.title!,
                      floatingLabel: "Metal that represents your value",
                    ),
                    const Gap(20),
                    EditField(
                      text: user.passion?.join(", ") ?? "",
                      floatingLabel: "Passion/Interests",
                    ),
                    const Gap(20),
                    EditField(
                      text: user.extraData?.maritalStatus ?? "",
                      floatingLabel: "Marital status",
                    ),
                    const Gap(20),
                    EditField(
                      text: user.extraData?.religion ?? "",
                      floatingLabel: "Religion",
                    ),
                    const Gap(20),
                    EditField(
                      text: user.extraData?.profession ?? "",
                      floatingLabel: "Profession",
                    ),
                    const Gap(20),
                    EditField(
                      text: user.connectWith!,
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

  String getAgeRange(String dateString) {
    DateFormat dateFormat = DateFormat("dd/MM/yyyy");
    DateTime birthDate = dateFormat.parse(dateString);
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;

    // Check if the birthday has occurred this year
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      age--;
    }

    if (age >= 18 && age <= 23) {
      return "18 - 23";
    } else if (age >= 24 && age <= 29) {
      return "24 - 29";
    } else if (age >= 30 && age <= 35) {
      return "30 - 35";
    } else if (age >= 36 && age <= 41) {
      return "36 - 41";
    } else if (age >= 42 && age <= 47) {
      return "42 - 47";
    } else if (age >= 48 && age <= 53) {
      return "48 - 53";
    } else if (age >= 54 && age <= 59) {
      return "54 - 59";
    } else if (age >= 60 && age <= 65) {
      return "60 - 65";
    } else if (age >= 66 && age <= 71) {
      return "66 - 71";
    } else if (age >= 72 && age <= 77) {
      return "72 - 77";
    } else if (age >= 78 && age <= 83) {
      return "78 - 83";
    } else if (age >= 85 && age <= 90) {
      return "85 - 90";
    } else if (age >= 91 && age <= 100) {
      return "91 - 100";
    } else {
      return "Age is not within any specified range";
    }
  }
}
