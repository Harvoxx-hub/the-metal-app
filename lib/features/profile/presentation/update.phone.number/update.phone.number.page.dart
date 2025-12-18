import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

class UpdatePhoneNumberPage extends StatelessWidget {
  UpdatePhoneNumberPage({super.key});
  static const name = 'updatePhoneNumberPage';
  static const route = name;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBarState: AppBarState.BackWithHeader,
      Header: "Update phone number",
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
                      Assets.icons.profilePhone.path,
                      height: 50,
                      width: 50,
                    ),
                    const Gap(22),
                    const TextView(
                      text: "Update your phone number?",
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                    const Gap(5),
                    const TextView(
                      text:
                          "To update your phone number please input your Metal password. A verification code will be sent to your email address",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      textAlign: TextAlign.center,
                    ),
                    const Gap(35),
                    EditFormField(
                      floatingLabel: 'Email address',
                      label: 'Enter email Address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixWidget: SvgPicture.asset(
                        Assets.icons.user.path,
                        height: 24,
                        width: 24,
                      ),
                      // validator: EmailValidator.validate(email),
                      radius: 10,
                      editButton: true,
                      onEditTap: () {},
                      // fillColor: AppColors.appGrey,
                    ),
                    const Gap(22),
                    EditFormField(
                      floatingLabel: 'Metal Password',
                      label: '************',
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      prefixWidget: SvgPicture.asset(
                        Assets.icons.passwordIcon.path,
                        height: 24,
                        width: 24,
                      ),
                      // validator: EmailValidator.validate(email),
                      radius: 10,
                      // fillColor: AppColors.appGrey,
                    ),
                    const Gap(45),
                    BaseButton(
                      buttonText: "Confirm password",
                      onPressed: () {
                        // TODO: Implement phone update flow later
                        Navigator.pushNamed(context, AppRoutes.newPhoneNumberPage);
                      },
                    ),
                    const Gap(11),
                    const TextView(
                      text: "Still having issues? We are happy to help",
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.italic,
                      textAlign: TextAlign.center,
                    ),
                    const TextView(
                      text: "Contact us",
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      underline: true,
                      color: AppColors.metalPinkColour,
                      textAlign: TextAlign.center,
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
}
