import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/metal.helper.dart';
import 'package:metal/data/models/user_model.dart';
import 'package:metal/presentation/viewmodels/profile/metal_properties_provider.dart';
// import 'package:metal/features/thought/provider/get.melt.users.notifier.dart'; // Removed - migrated to new architecture

import 'package:metal/presentation/widgets/settings/edit_field.dart';
import 'package:metal/presentation/widgets/profile/profile_header.dart';
import 'package:metal/presentation/widgets/settings/block_button.dart';

import 'package:metal/res/colors/cr_colors.dart';

import 'package:metal/widgets/text_views.dart';

class UserProfilePage extends ConsumerWidget {
  const UserProfilePage({super.key, required this.user});
  static const name = 'userProfilePage';
  static const route = name;
  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metalProperties = ref.watch(metalPropertiesProvider).data;
    // TODO: Replace with new connection viewmodel when connections feature is fully migrated
    // final connection = ref.watch(getMeltUserProvider.notifier).getMeltUserById(user.id!);
    final connection = null; // Temporarily set to null until connections feature is fully migrated

    final metal = metalProperties!.metals!.firstWhere(
      (element) => element.id == user.metal,
      orElse: () =>
          metalProperties.metals![0], // Fallback in case no match is found
    );
    return BaseScreen(
      Header: "User Profile",
      body: ProfileHeader(
          eye: false,
          myProfile: false,
          metalId: user.metal!,
          profileUrl: connection != null
              ? connection.isAnonymous
                  ? null
                  : user.profilePhoto
              : null,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BlockUserButton(
                      userId: user.id!,
                      username: user.username!,
                      isOutlined: true,
                      fontSize: 16.0,
                    ),
                    const Gap(20),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: ShapeDecoration(
                        color: const Color(0x0CD9197B),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      child: TextView(
                          text: connection != null
                              ? connection.isAnonymous
                                  ? "@${user.username} "
                                  : "${user.fullname} "
                              : "@${user.username} "),
                    ),
                    const Gap(40),
                    connection?.isAnonymous ?? true
                        ? const SizedBox()
                        : EditField(
                            text: user.fullname!,
                            floatingLabel: " First name & Last name",
                          ),
                    const Gap(20),
                    EditField(
                      text: "@${user.username}",
                      floatingLabel: "Username",
                    ),

                    /// gender
                    const Gap(20),
                    EditField(
                      text: user.gender ?? "",
                      floatingLabel: "Gender",
                    ),
                    const Gap(20),
                    EditField(
                      text: MetalHelper.getAgeRange(user.dob!) + " years",
                      floatingLabel: "Age Range",
                    ),
                    const Gap(20),
                    EditField(
                      text: metal.title,
                      floatingLabel: "Metal that represents your value",
                    ),
                    const Gap(20),
                    EditField(
                      text: user.passion?.join(", ") ?? "",
                      floatingLabel: "Passion/Interests",
                    ),
                    const Gap(20),
                    EditField(
                      text: user.extraData?.marriageStatus ?? "",
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


}
