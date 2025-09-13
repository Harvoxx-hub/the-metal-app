import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/presentation/widget/create.profile.header1.dart';
import 'package:metal/features/authentication/provider/profile_setup_manager.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';

import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/dropdown/metal.dropdownMutipleSelection.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

import '../../../../widgets/dropdown/metal.dropdown.dart';

class CreateProfilePage extends ConsumerStatefulWidget {
  const CreateProfilePage({super.key});
  static const name = 'createProfile';
  static const route = name;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateProfilePageState();
}

class _CreateProfilePageState extends ConsumerState<CreateProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? _gender;
  List<String> _whatImLookingFor = [];

  @override
  void initState() {
    super.initState();
    _initializeFromExistingData();
  }

  void _initializeFromExistingData() {
    // Initialize from existing user data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = ref.read(userStateProvider);
      if (userState.data != null) {
        final user = userState.data!;

        if (user.fullname != null) {
          _nameController.text = user.fullname!;
        }

        if (user.username != null) {
          _userNameController.text = user.username!;
        }

        if (user.dob != null) {
          _dobController.text = user.dob!;
        }

        if (user.gender != null) {
          _gender = user.gender;
        }

        if (user.connectWith != null) {
          _whatImLookingFor = user.connectWith!.split(',');
        }

        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final setupState = ref.watch(profileSetupManagerProvider);

        return BaseScreen(
          bgImage: Assets.images.bg2.path,
          appBarEnabled: false,
          Header: 'Create Profile',
          authFlow: true,
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(45),
                  const CreateProfileHeader1(
                    title1: '👋 Hello',
                    title2: 'Lets set up your profile',
                    title3: "It will only take 3 minutes",
                  ),
                  const Gap(24),

                  // Show error message if any
                  if (setupState.errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red, size: 20),
                          const Gap(8),
                          Expanded(
                            child: Text(
                              setupState.errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Form(
                    key: _formKey,
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
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your name';
                            }

                            List<String> parts = value.split(' ');

                            if (parts.length < 2) {
                              return 'Please enter both first name and last name';
                            }

                            return null;
                          },
                          autoValidate: true,
                        ),
                        const Gap(16),
                        EditFormField(
                          floatingLabel: 'User name',
                          label: 'User name',
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
                        const Gap(16),
                        MentalDropdown(
                          items: const [
                            "Male",
                            "Female",
                            "Prefer not to say",
                            "Others",
                          ],
                          value: _gender,
                          onChanged: (newValue) {
                            setState(() {
                              _gender = newValue;
                            });
                          },
                          floatingLabel: "Gender",
                          hint: "Select Gender",
                          prefixIcon: Assets.icons.user2.svg(height: 24),
                        ),
                        const Gap(16),
                        GestureDetector(
                          onTap: _showDatePicker,
                          child: EditFormField(
                            floatingLabel: 'Please Select your Date Of Birth',
                            label: 'Select Date Of Birth',
                            enabled: false,
                            controller: _dobController,
                            keyboardType: TextInputType.name,
                            prefixWidget:
                                Assets.icons.calendarBlank.svg(width: 24),
                            suffixWidget: Assets.icons.srClose.svg(width: 17),
                            bottomLabel: "Age cannot be changed",
                          ),
                        ),
                        const Gap(16),
                        MentalDropdownMutipleSelection(
                          items: const [
                            "Male",
                            "Female",
                            "Others",
                          ],
                          value: _whatImLookingFor,
                          onChanged: (newValue) {
                            setState(() {
                              _whatImLookingFor = newValue;
                            });
                          },
                          floatingLabel: "I am looking to connect with",
                          hint: "Please Select",
                          prefixIcon: Assets.icons.user2.svg(width: 24),
                        ),
                        const Gap(64),
                      ],
                    ),
                  ),
                  BaseButton(
                    buttonText: setupState.isLoading ? "Saving..." : "Next",
                    onPressed: setupState.isLoading ? null : _onNextPressed,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDatePicker() {
    BottomPicker.date(
      maxDateTime: DateTime(DateTime.now().year - 18),
      onSubmit: (date) {
        _dobController.text = formatDateDDMMYY(date.toString());
      },
      buttonSingleColor: AppColors.metalBlack,
      pickerTitle: const TextView(text: "Please Select your Date Of Birth"),
    ).show(context);
  }

  void _onNextPressed() async {
    if (_formKey.currentState!.validate()) {
      // Validate required fields
      if (_gender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your gender'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      /// username should be unique and not contain any special characters
      if (_userNameController.text
          .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username should not contain any special characters'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_dobController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your date of birth'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final stepData = {
        'fullname': _nameController.text.trim(),
        'username': _userNameController.text.trim(),
        'gender': _gender,
        'dob': _dobController.text,
        'connectWith': _whatImLookingFor.join(","),
      };

      try {
        // Save step data using the new profile setup manager
        await ref.read(profileSetupManagerProvider.notifier).saveStepData(
              step: ProfileSetupStep.basicInfo,
              stepData: stepData,
              moveToNext: true,
            );

        // Check if save was successful
        final setupState = ref.read(profileSetupManagerProvider);
        if (setupState.errorMessage == null) {
          // Navigate to next screen
          if (mounted) {
            Navigator.pushNamed(
              context,
              AppRoutes.chooseYourMetalPage,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving profile: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userNameController.dispose();
    _dobController.dispose();
    super.dispose();
  }
}
