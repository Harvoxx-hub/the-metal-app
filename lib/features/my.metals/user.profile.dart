import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/home_page/domain/entries/all.user.model.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/profile/profile.page.dart';
import 'package:metal/features/profile/widget/edit.field.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text_views.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key, required this.user});
  static const name = 'userProfilePage';
  static const route = '$name';
  final UserModel user;
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      Header: "User Profile",
      body: ProfileHeader(
          user: user,
          child: Padding(
        padding: const EdgeInsets.only(top: 110, left: 20, right: 20),
        child: Container(
          padding: const EdgeInsets.only(
            top: 122,
          ),
          decoration: const BoxDecoration(
              color: AppColors.metalWhite,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35), topRight: Radius.circular(35))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: ShapeDecoration(
                    color: Color(0x0CD9197B),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  child: TextView(text: "@ ${user.username}"),
                ),
                Gap(40),
                EditField(
                  text: user.fullname!,
                  floatingLabel: " First name & Last name",
                ),
                Gap(20),
                EditField(
                  text: "@${user.username}",
                  floatingLabel: "Username",
                ),
                Gap(20),
                EditField(
                  text: user.DOB!,
                  floatingLabel: "Date of Birth (DD-MM)",
                ),
                Gap(20),
                EditField(
                  text: user.metal!.title!,
                  floatingLabel: "Metal that represents your value",
                ),
                Gap(20),
                EditField(
                  text: user.passion!.join(", "),
                  floatingLabel: "Passion/Interests",
                ),
                Gap(20),
                EditField(
                  text: user.extra_data!.marital_status!,
                  floatingLabel: "Marital status",
                ),
                Gap(20),
                EditField(
                  text: user.extra_data!.religion!,
                  floatingLabel: "Religion",
                ),
                Gap(20),
                EditField(
                  text: user.extra_data!.profession!,
                  floatingLabel: "Profession",
                ),
                Gap(20),
                EditField(
                  text: user.connect_with!,
                  floatingLabel: "Interested in",
                ),
                Gap(20),
              ],
            ),
          ),
        ),
      )),
    );
  }

  Widget _blockDialog(BuildContext context) {
    return Column(
      children: [
        Gap(38.h),
        SvgPicture.asset(
          Assets.icons.meltedMetalsSmileyXEyes.path,
          height: 45,
          width: 45,
        ),
        Gap(15.h),
        TextView(
          text: "Block  ${user.username}",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        Gap(15.h),
        TextView(
          text:
              "Blocked metals cannot call or send you messages. This Metal will not be notified",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        Gap(38.h),
        BaseButton(buttonText: "Block  ${user.username}", onPressed: () {}),
        Gap(23.h),
        TextView(
          text: "Cancel",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          onTap: () => Navigator.pop(context),
        ),
        Gap(21.h),
      ],
    );
  }

  Widget _ceMeltDialog(BuildContext context) {
    return Column(
      children: [
        Gap(38.h),
        SvgPicture.asset(
          Assets.icons.meltedMetalsTrash01.path,
          height: 45,
          width: 45,
        ),
        Gap(15.h),
        TextView(
          text: "De-melt ${user.username}",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        Gap(15.h),
        TextView(
          text: "De-melted metals will have to request to melt with you again",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        Gap(38.h),
        BaseButton(buttonText: "De-melt ${user.username}", onPressed: () {}),
        Gap(23.h),
        TextView(
          text: "Cancel",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          onTap: () => Navigator.pop(context),
        ),
        Gap(21.h),
      ],
    );
  }
}
