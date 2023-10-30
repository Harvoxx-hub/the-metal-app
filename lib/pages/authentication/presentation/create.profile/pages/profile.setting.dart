import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/pages/authentication/presentation/create.profile/widget/create.profile.header1.dart';
import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dropdown/metal.dropdown.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';

class ProfileSettingPage extends StatefulWidget {
  const ProfileSettingPage({super.key, required this.onNextPress});
  final Future<void> Function() onNextPress;
  @override
  State<ProfileSettingPage> createState() => _ProfileSettingPageState();
}

class _ProfileSettingPageState extends State<ProfileSettingPage> {
  static final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  String? seletedValue;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CreateProfileHeader1(),
          Gap(24.h),
          Form(
              key: _form,
              child: Column(
                children: [
                  EditFormField(
                    floatingLabel: 'First Name and Last Name',
                    label: 'First Name and Last Name',
                    controller: _nameController,
                    keyboardType: TextInputType.name,

                    prefixWidget: SvgPicture.asset(
                      Assets.icons.user3.path,
                      height: 24,
                      width: 24,
                    ),
                    // validator: EmailValidator.validate(email),
                    radius: 10,
                    // fillColor: AppColors.appGrey,
                  ),
                  Gap(16.h),
                  EditFormField(
                    floatingLabel: 'User name',
                    label: "User name",
                    controller: _userNameController,
                    keyboardType: TextInputType.name,
                    bottomLabel: "Type a name unique to you",

                    prefixWidget: SvgPicture.asset(
                      Assets.icons.newspaperClipping.path,
                      height: 24,
                      width: 24,
                    ),
                    // validator: EmailValidator.validate(email),
                    radius: 10,
                  ),
                  Gap(16.h),
                  if (seletedValue != "Others (Please specify)")
                    MentalDropdown(
                      items: const [
                        "Male",
                        "Female",
                        "Prefer not to say",
                        "Others (Please specify)",
                      ],
                      value: seletedValue,
                      onChanged: (newValue) {
                        setState(() {
                          seletedValue = newValue;
                        });
                      },
                      floatingLabel: "Gender",
                      hint: "Select Gender",
                      prefixIcon: SvgPicture.asset(
                        Assets.icons.user2.path,
                        height: 24,
                        width: 24,
                      ),
                    ),
                  if (seletedValue == "Others (Please specify)")
                    EditFormField(
                      floatingLabel: 'Gender/Others',
                      label: "Female",
                      controller: _userNameController,
                      keyboardType: TextInputType.name,

                      prefixWidget: SvgPicture.asset(
                        Assets.icons.user2.path,
                        height: 24,
                        width: 24,
                      ),
                      // validator: EmailValidator.validate(email),
                      radius: 10,
                    ),
                  Gap(16.h),
                  CustomCheckWidget(
                    title: 'Show my gender on my Profile',
                    initialValue: false,
                    onChanged: (bool value) {
                      print('Value changed to $value');
                    },
                  ),
                  Gap(64.h),
                ],
              )),
          BaseButton(
            buttonText: "Next 1/6",
            onPressed: _onNextPressed,
          ),
        ],
      ),
    );
  }

  void _onNextPressed() {
    widget.onNextPress();
  }
}
