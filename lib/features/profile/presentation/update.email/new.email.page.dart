import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

class NewEmailPage extends StatelessWidget {
  NewEmailPage({super.key});
  static const name = 'newEmailPage';
  static const route = name;
  final TextEditingController _email2Controller = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBarState: AppBarState.BackWithHeader,
      Header: "Update email address",
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.00, -1.00),
                        end: Alignment(0, 1),
                        colors: [Color(0xFFDB217A), Color(0xFFF00E3E)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(35),
                        bottomRight: Radius.circular(35),
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
                    SvgPicture.asset(
                      Assets.icons.profileIcon.path,
                      height: 50,
                      width: 50,
                    ),
                    const Gap(22),
                    const TextView(
                      text: "Email address verified",
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                    const Gap(5),
                    const TextView(
                      text:
                          "Please input the *new phone number* you are migrating to",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      textAlign: TextAlign.center,
                    ),
                    const Gap(35),
                    EditFormField(
                      floatingLabel: 'New Email address',
                      label: 'New Email address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixWidget: SvgPicture.asset(
                        Assets.icons.user.path,
                        height: 24,
                        width: 24,
                      ),
                      // validator: EmailValidator.validate(email),
                      radius: 10,

                      // fillColor: AppColors.appGrey,
                    ),
                    const Gap(22),
                    EditFormField(
                      floatingLabel: 'Confirm New Email address',
                      label: 'New Email address',
                      controller: _email2Controller,
                      keyboardType: TextInputType.emailAddress,
                      prefixWidget: SvgPicture.asset(
                        Assets.icons.user.path,
                        height: 24,
                        width: 24,
                      ),
                      // validator: EmailValidator.validate(email),
                      radius: 10,

                      // fillColor: AppColors.appGrey,
                    ),
                    const Gap(45),
                    BaseButton(
                      buttonText: "Update  Email",
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialog(
                              content: phoneUpdatedDialog(context),
                            );
                          },
                        );
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

  Widget phoneUpdatedDialog(BuildContext context) {
    return Column(
      children: [
        const Gap(38),
        SvgPicture.asset(
          Assets.icons.profileMail01.path,
          height: 50,
          width: 50,
        ),
        const Gap(15),
        const TextView(
          text: "Email updated",
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        const Gap(15),
        const TextView(
          text: "Your email address has been updated successfully",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(38),
        BaseButton(
            buttonText: "OK. Got it! ",
            onPressed: () {
              Navigator.pop(context);
            }),
        const Gap(21),
      ],
    );
  }
}
