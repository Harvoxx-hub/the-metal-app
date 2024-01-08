import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/profile/update.email/update.email.page.dart';
import 'package:metal/features/profile/update.phone.number/update.phone.number.page.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';

class PersonalTab extends StatefulWidget {
  const PersonalTab({super.key});

  @override
  State<PersonalTab> createState() => _PersonalTabState();
}

class _PersonalTabState extends State<PersonalTab> {
  // static final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  final TextEditingController _metalController = TextEditingController();

  final TextEditingController _passionController = TextEditingController();

  final TextEditingController _maritalStatusController =
      TextEditingController();

  final TextEditingController _religionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _proffessionController = TextEditingController();
  final TextEditingController _intrestedInController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void didChangeDependencies() {
    _firstNameController.text = "DesigneChi Basil";
    _userNameController.text = "chibeke";
    _emailController.text = "chi.metal@gmail.com";
    _phoneController.text = "06-09-1995";
    _genderController.text = "Female";
    _metalController.text = "Aluminium";
    _passionController.text = "Dancing, Hiking, Travelling";
    _maritalStatusController.text = "Single";
    _religionController.text = "Christianity";
    _addressController.text = "Street no, town, state, country, etc.";
    _proffessionController.text = "Barrister";
    _intrestedInController.text = "Both gender";
    _bioController.text =
        "I term myself an Aluminium because I am light and emotional. I like to be cared for as I have some tendencies to get rusty. It would be great to connect with you! Let’s melt!";
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EditFormField(
          floatingLabel: 'First name & Last name',
          label: 'First name & Last name',
          controller: _firstNameController,
          keyboardType: TextInputType.name,
          radius: 10,
        ),
        Gap(20.h),
        EditFormField(
          floatingLabel: 'Username',
          label: 'Username',
          controller: _userNameController,
          keyboardType: TextInputType.name,
          radius: 10,
        ),
        Gap(20.h),
        EditFormField(
          floatingLabel: 'Email address',
          label: 'Email address',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          radius: 10,
          editButton: true,
          onEditTap: () {
            context.pushNamed(UpdateEmailPage.name);
          },
        ),
        Gap(20.h),
        EditFormField(
          floatingLabel: 'Phone Number',
          label: 'Phone Number',
          controller: _phoneController,
          keyboardType: TextInputType.number,
          radius: 10,
          editButton: true,
          onEditTap: () {
            context.pushNamed(UpdatePhoneNumberPage.name);
          },
        ),
        Gap(20.h),
        EditFormField(
          floatingLabel: 'Gender',
          label: 'Gender',
          controller: _genderController,
          keyboardType: TextInputType.number,
          radius: 10,
          editButton: true,
          onEditTap: () {},
        ),
        Gap(20.h),
        EditFormField(
          floatingLabel: 'Gender',
          label: 'Gender',
          controller: _genderController,
          keyboardType: TextInputType.number,
          radius: 10,
          editButton: true,
          onEditTap: () {},
        ),
        Gap(20.h),
        EditFormField(
          floatingLabel: 'Metal that represents your value',
          label: 'Metal that represents your value',
          controller: _metalController,
          keyboardType: TextInputType.name,
          radius: 10,
          editButton: true,
          onEditTap: () {},
        ),
        Gap(20.h),
        EditFormField(
          floatingLabel: 'Passion/Interest',
          label: 'Passion/Interest',
          controller: _passionController,
          keyboardType: TextInputType.number,
          radius: 10,
          editButton: true,
          onEditTap: () {},
        ),
        Gap(20.h),
        EditFormField(
          floatingLabel: 'Marital status',
          label: 'Marital status',
          controller: _maritalStatusController,
          keyboardType: TextInputType.name,
          radius: 10,
          editButton: true,
          onEditTap: () {},
        ),
        Gap(20.h),
        EditFormField(
          floatingLabel: 'Religion',
          label: 'Religion',
          controller: _religionController,
          keyboardType: TextInputType.name,
          radius: 10,
          editButton: true,
          onEditTap: () {},
        ),
        Gap(20.h),
        EditFormField(
          floatingLabel: 'Home address details',
          label: 'Home address details',
          controller: _addressController,
          keyboardType: TextInputType.name,
          radius: 10,
          editButton: true,
          onEditTap: () {},
        ),
        Gap(20.h),
        EditFormField(
          floatingLabel: 'Proffession',
          label: 'Proffession',
          controller: _proffessionController,
          keyboardType: TextInputType.name,
          radius: 10,
          editButton: true,
          onEditTap: () {},
        ),
        Gap(20.h),
        EditFormField(
          floatingLabel: 'Interested in',
          label: 'Interested in',
          controller: _intrestedInController,
          keyboardType: TextInputType.name,
          radius: 10,
          editButton: true,
          onEditTap: () {},
        ),
        Gap(20.h),
        EditFormField(
          floatingLabel: 'Little Bio about me',
          label: 'Little Bio about me',
          controller: _bioController,
          maxLines: 5,
          keyboardType: TextInputType.number,
          radius: 10,
          editButton: true,
          onEditTap: () {},
        ),
        Gap(20.h),
        PlainButton(
          buttonText: "Delete my account",
          onPressed: () {},
          textColor: AppColors.metalWhite,
          color: AppColors.metalRed,
          leftIcon: SvgPicture.asset(
            Assets.icons.profileTrash.path,
            height: 24,
            width: 24,
          ),
        )
      ],
    );
  }
}
