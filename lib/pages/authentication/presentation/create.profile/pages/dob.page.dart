import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/pages/authentication/presentation/create.profile/widget/create.profile.header1.dart';
import 'package:metal/res/res.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dropdown/metal.dropdown.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';

class DobPage extends StatefulWidget {
  const DobPage({super.key, required this.onNextPress});
  final Future<void> Function() onNextPress;
  @override
  State<DobPage> createState() => _DobPageState();
}

class _DobPageState extends State<DobPage> {
  final TextEditingController _dobController = TextEditingController();
  static final GlobalKey<FormState> _form = GlobalKey<FormState>();
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
                  Gap(64.h),
                ],
              )),
          BaseButton(
            buttonText: "Next 2/6",
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
