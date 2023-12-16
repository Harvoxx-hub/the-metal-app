import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/pages/authentication/presentation/profile.setting/choose.your.metal.dart';
import 'package:metal/pages/authentication/presentation/signup/verfication.dart';
import 'package:metal/pages/authentication/presentation/widget/create.profile.header1.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text.field/phone.number.input.dart';
import 'package:metal/widgets/text_views.dart';

import '../../../../widgets/dropdown/metal.dropdown.dart';

class CreateProfileDobPage extends ConsumerStatefulWidget {
  CreateProfileDobPage({Key? key}) : super(key: key);
  static const name = 'createProfileDob';
  static const route = '$name';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateProfileDobPageState();
}

class _CreateProfileDobPageState extends ConsumerState<CreateProfileDobPage> {
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  static final GlobalKey<FormState> _form = GlobalKey<FormState>();
  String? seletedValue;
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        Header: 'Create Profile',
        authFlow: true,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(45.h),
              CreateProfileHeader1(),
              Gap(40.h),
              Form(
                  key: _form,
                  child: Column(
                    children: [
                      EditFormField(
                        floatingLabel: 'Please Select your Date Of Birth',
                        label: '01/01/2023',
                        controller: _dobController,
                        keyboardType: TextInputType.name,
                        onTapped: () {
                          BottomPicker.date(
                            title: "Please Select your Date Of Birth",
                            titleStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: AppColors.metalBlack),
                            onChange: (index) {
                              print(index);
                            },
                            onSubmit: (index) {
                              print(index);
                            },
                            buttonSingleColor: AppColors.metalBlack,
                          ).show(context);
                        },
                        prefixWidget: SvgPicture.asset(
                          Assets.icons.calendarBlank.path,
                          height: 24,
                          width: 24,
                        ),
                        suffixWidget: SvgPicture.asset(
                          Assets.icons.srClose.path,
                          height: 17,
                          width: 17,
                        ),
                        // validator: EmailValidator.validate(email),
                        radius: 10,
                        bottomLabel: "Age cannot be changed",
                        // fillColor: AppColors.appGrey,
                      ),
                      Gap(16.h),
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
                        floatingLabel: "I am looking to connect with",
                        hint: "Select Gender",
                        prefixIcon: SvgPicture.asset(
                          Assets.icons.user2.path,
                          height: 24,
                          width: 24,
                        ),
                      ),
                      Gap(16.h),
                      PhoneInput(
                        phoneController: _phoneController,
                      ),
                      Gap(16.h),
                      TextView(
                        text:
                            'A verification code will be sent to this number. Message and data rates may apply. Learn what happens what your number changes',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        color:
                            AppColors.metalBrownColourForText.withOpacity(0.5),
                      ),
                      Gap(64.h),
                    ],
                  )),
              BaseButton(
                buttonText: "Next 2/6",
                onPressed: _onNextPressed,
              ),
            ],
          ),
        ));
  }

  void _onNextPressed() {
    context.pushNamed(VerificationPage.name,
        extra: RouteFrom.AccountSetting.name);
    // context.pushNamed(ChooseYourMetalPage.name);
  }
}
