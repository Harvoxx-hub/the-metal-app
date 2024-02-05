import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/features/authentication/provider/update.profile.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/authentication/presentation/profile.setting/choose.your.metal.dart';

import 'package:metal/features/authentication/presentation/signup/account.setting.dart';
import 'package:metal/features/authentication/presentation/widget/create.profile.header1.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';

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
  final TextEditingController _dobController = TextEditingController();

  String? _gender;
  String? _whatImLookingFor;

  int currentPage = 0;
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
              const CreateProfileHeader1(
                title1:          '👋 Hello',
 
                title2:
                          'Let’s set up your profile',
                    title3: "it will only take a 3 minutes" ,
              ),
              Gap(24.h),
              Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EditFormField(
                        floatingLabel: 'First Name and Last Name',
                        label: 'First Name and Last Name',
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        prefixWidget: Assets.icons.user3.svg(
                          width: 24,
                          height: 24,
                        ),
                        validator: Validators.validateString(),
                        autoValidate: true,
                      ),
                      Gap(16.h),
                      EditFormField(
                        floatingLabel: 'User name',
                        label: "User name",
                        controller: _userNameController,
                        keyboardType: TextInputType.name,
                        bottomLabel:
                            "Type a name unique to you that will be displayed to other users",
                        prefixWidget: Assets.icons.user3.svg(
                          width: 24,
                          height: 24,
                        ),
                        validator: Validators.validateString(),
                        autoValidate: true,
                      ),
                      Gap(16.h),

                      MentalDropdown(
                        items: const [
                          "Male",
                          "Female",
                          "Prefer not to say",
                          "Others (Please specify)",
                        ],
                        value: _gender,
                        onChanged: (newValue) {
                          setState(() {
                            _gender = newValue;
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
                      // if (seletedValue == "Others (Please specify)")
                      //   EditFormField(
                      //     floatingLabel: 'Gender/Others',
                      //     label: "Female",
                      //     controller: _userNameController,
                      //     keyboardType: TextInputType.name,

                      //     prefixWidget: SvgPicture.asset(
                      //       Assets.icons.user2.path,
                      //       height: 24,
                      //       width: 24,
                      //     ),
                      //     // validator: EmailValidator.validate(email),
                      //     radius: 10,
                      //   ),
                      Gap(16.h),
                      EditFormField(
                        floatingLabel: 'Please Select your Date Of Birth',
                        label: '01/01/2023',
                        controller: _dobController,
                        keyboardType: TextInputType.name,
                        onTapped: () {
                          BottomPicker.date(
                            title: "Please Select your Date Of Birth",
                            titleStyle: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: AppColors.metalBlack),
                            onSubmit: (index) {
                              _dobController.text =
                                  formatDateDDMMYY(index.toString());
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
                        value: _whatImLookingFor,
                        onChanged: (newValue) {
                          setState(() {
                            _whatImLookingFor = newValue;
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
                buttonText: "Next 1/5",
                onPressed: _onNextPressed,
              ),
            ],
          ),
        ));
  }

  void _onNextPressed() {
    final userData = ref.watch(updateProfileProvider).data;

    if (_form.currentState!.validate()) {
      userData!.fullname = _nameController.text;
      userData!.username = _userNameController.text;
      userData!.DOB = _dobController.text;
      userData!.gender = _gender;
      userData!.connect_with = _whatImLookingFor;
  
      ref.read(updateProfileProvider.notifier).updateUserData(userData);
      context.pushNamed(ChooseYourMetalPage.name);
    }
  }
}
