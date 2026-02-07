import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/core/utils/strings/app_strings.dart';
import 'package:metal/presentation/widgets/profile_setup_header.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/profile/profile_setup_viewmodel.dart';
import 'package:metal/presentation/views/profile/profile_setup_constants.dart';
import 'package:metal/presentation/views/profile/profile_setup_helpers.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/dropdown/metal.dropdown.dart';
import 'package:metal/widgets/dropdown/metal.dropdownMutipleSelection.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

/// Basic Info View - Step 1 of profile setup
/// Collects: Name, Username, Gender, DOB, What looking for
class BasicInfoView extends ConsumerStatefulWidget {
  const BasicInfoView({super.key});
  static const name = 'basicInfo';
  static const route = '/$name';

  @override
  ConsumerState<BasicInfoView> createState() => _BasicInfoViewState();
}

class _BasicInfoViewState extends ConsumerState<BasicInfoView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? _gender;
  List<String> _whatImLookingFor = [];

  @override
  void dispose() {
    _nameController.dispose();
    _userNameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _showDatePicker() {
    BottomPicker.date(
      maxDateTime: DateTime(DateTime.now().year - 18),
      onSubmit: (date) {
        if (date != null) {
          _dobController.text = formatDateDDMMYY(date.toString());
        }
      },
      buttonPadding: 16,
      buttonSingleColor: AppColors.metalBlack,
      pickerTitle: const TextView(text: AppStrings.selectDateOfBirth),
    ).show(context);
  }

  void _onNextPressed() async {
    if (!_formKey.currentState!.validate()) return;

    if (_gender == null) {
      ProfileSetupHelpers.showValidationError(
          context, AppStrings.pleaseSelectGender);
      return;
    }

    if (_userNameController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<> ]'))) {
      ProfileSetupHelpers.showValidationError(
          context, AppStrings.usernameNoSpecialChars);
      return;
    }

    if (_dobController.text.isEmpty) {
      ProfileSetupHelpers.showValidationError(
          context, AppStrings.pleaseSelectDob);
      return;
    }

    final stepData = {
      'fullname': _nameController.text.trim(),
      'username': _userNameController.text.trim(),
      'gender': _gender,
      'dob': _dobController.text,
      'connectWith': _whatImLookingFor.join(","),
    };

    await ProfileSetupHelpers.saveStepAndNavigate(
      context: context,
      ref: ref,
      step: ProfileSetupStep.basicInfo,
      stepData: stepData,
      nextRoute: AppRoutes.chooseYourMetalPage,
      mounted: mounted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(profileSetupViewModelProvider);

    return BaseScreen(
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: AppStrings.createProfile,
      authFlow: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(ProfileSetupConstants.headerTopPadding),
              const CreateProfileHeader1(
                title1: AppStrings.hello,
                title2: AppStrings.setupProfile,
                title3: AppStrings.setupTime,
              ),
              Gap(ProfileSetupConstants.gapMedium),
              ProfileSetupHelpers.buildErrorWidget(setupState.errorMessage),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ProfileSetupConstants.horizontalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EditFormField(
                        floatingLabel: AppStrings.firstNameLastName,
                        label: AppStrings.firstNameLastName,
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        prefixWidget: Assets.icons.user3.svg(
                          width: ProfileSetupConstants.iconSize,
                          height: ProfileSetupConstants.iconSize,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.pleaseEnterName;
                          }
                          final parts = value.split(' ');
                          if (parts.length < 2) {
                            return AppStrings.pleaseEnterBothNames;
                          }
                          return null;
                        },
                        autoValidate: true,
                      ),
                      const Gap(ProfileSetupConstants.gapSmall),
                      EditFormField(
                        floatingLabel: AppStrings.userName,
                        label: AppStrings.userName,
                        controller: _userNameController,
                        keyboardType: TextInputType.name,
                        bottomLabel: AppStrings.usernameHint,
                        prefixWidget: Assets.icons.user3.svg(
                          width: ProfileSetupConstants.iconSize,
                          height: ProfileSetupConstants.iconSize,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.pleaseEnterUsername;
                          }
                          if (value
                              .contains(RegExp(r'[!@#$%^&*(),.?":{}|<> ]'))) {
                            return AppStrings.usernameInvalidChars;
                          }
                          return null;
                        },
                        autoValidate: true,
                      ),
                      const Gap(ProfileSetupConstants.gapSmall),
                      MentalDropdown(
                        items: ProfileSetupConstants.genderOptions,
                        value: _gender,
                        onChanged: (newValue) {
                          setState(() {
                            _gender = newValue;
                          });
                        },
                        floatingLabel: AppStrings.genderLabel,
                        hint: AppStrings.selectGender,
                        prefixIcon: Assets.icons.user2.svg(
                          height: ProfileSetupConstants.iconSize,
                        ),
                      ),
                      const Gap(ProfileSetupConstants.gapSmall),
                      GestureDetector(
                        onTap: _showDatePicker,
                        child: EditFormField(
                          floatingLabel: AppStrings.selectDateOfBirth,
                          label: AppStrings.dateOfBirthLabel,
                          enabled: false,
                          controller: _dobController,
                          keyboardType: TextInputType.name,
                          prefixWidget: Assets.icons.calendarBlank.svg(
                            width: ProfileSetupConstants.iconSize,
                          ),
                          suffixWidget: Assets.icons.srClose.svg(
                            width: ProfileSetupConstants.iconSizeSmall,
                          ),
                          bottomLabel: AppStrings.ageCannotBeChanged,
                        ),
                      ),
                      const Gap(ProfileSetupConstants.gapSmall),
                      MentalDropdownMutipleSelection(
                        items: ProfileSetupConstants.connectionOptions,
                        value: _whatImLookingFor,
                        onChanged: (newValue) {
                          setState(() {
                            _whatImLookingFor = newValue;
                          });
                        },
                        floatingLabel: AppStrings.lookingToConnectWith,
                        hint: AppStrings.pleaseSelect,
                        prefixIcon: Assets.icons.user2.svg(
                          width: ProfileSetupConstants.iconSize,
                        ),
                      ),
                      Gap(ProfileSetupConstants.gapExtraLarge),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ProfileSetupConstants.horizontalPadding,
                ),
                child: BaseButton(
                  buttonText:
                      ProfileSetupHelpers.getButtonText(setupState.isLoading),
                  onPressed: setupState.isLoading ? null : _onNextPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
