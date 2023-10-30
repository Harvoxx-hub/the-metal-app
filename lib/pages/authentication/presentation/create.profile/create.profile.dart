import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/pages/authentication/presentation/welcome/presentation/welcome.page.dart';
import 'package:metal/res/res.dart';
import 'package:metal/utils/screen.size.dart';
import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../widgets/dropdown/metal.dropdown.dart';

class CreateProfilePage extends ConsumerStatefulWidget {
  CreateProfilePage({Key? key}) : super(key: key);
  static const name = 'createProfile';
  static const route = '$name';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateProfilePageState();
}

class _CreateProfilePageState extends ConsumerState<CreateProfilePage> {
  static final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  String? seletedValue;
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: 'Create Profile',
      authFlow: true,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Gap(43.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextView(
                text: '👋 Hello',
                fontSize: 20.sp,
                fontWeight: FontWeight.w400,
              ),
              TextView(
                text: 'Let’s set up your profile',
                fontSize: 20.sp,
                fontWeight: FontWeight.w400,
              ),
              TextView(
                text: 'It takes only 3 minutes!',
                fontSize: 14.sp,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w300,
              ),
              SizedBox(
                width: getDeviceWidth(context),
              )
            ],
          ),
          Gap(40.h),
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
            onPressed: () {
              context.pushNamed(WelcomePage.name);
            },
            // enabled: _emailController.text.isNotEmpty &&
            //     _passwordController.text.isNotEmpty,
          ),
        ],
      ),
    );
  }

  void onCompleted(String value, context) {
    print(value);
    context.pushNamed(WelcomePage.name);
  }
}
