import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/strings/app_strings.dart';
import 'package:metal/data/models/user_preferences_model.dart';
import 'package:metal/presentation/widgets/profile_setup_header.dart';
import 'package:metal/presentation/viewmodels/profile/metal_properties_provider.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/profile/profile_setup_viewmodel.dart';
import 'package:metal/presentation/views/profile/profile_setup_constants.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/dropdown/metal.dropdownMutipleSelection.dart';
import 'package:metal/widgets/text_views.dart';

/// Alias for UserPreferencesModel
typedef Preferences = UserPreferencesModel;

/// Preferences View - Step 7 of profile setup (Final step)
/// Collects: Age range, Religion, Ethnicity, Education, Demography preferences
class PreferencesView extends ConsumerStatefulWidget {
  const PreferencesView({super.key});
  static const name = 'preferences';
  static const route = '/$name';

  @override
  ConsumerState<PreferencesView> createState() => _PreferencesViewState();
}

class _PreferencesViewState extends ConsumerState<PreferencesView> {
  List<String>? _selectedAgeRange;
  List<String>? _selectedReligion;
  List<String>? _selectedEthnicity;
  List<String>? _selectedEducation;
  List<String>? _selectedDemography;
  bool _noSpecialPreference = false;

  void _onNextPressed() async {
    Preferences preferences;

    if (_noSpecialPreference) {
      preferences = Preferences(
        ageRange: null,
        religion: null,
        demography: null,
        education: null,
        ethnicity: null,
      );
    } else {
      preferences = Preferences(
        ageRange: _selectedAgeRange?.join(','),
        religion: _selectedReligion?.join(','),
        demography: _selectedDemography?.join(','),
        education: _selectedEducation?.join(','),
        ethnicity: _selectedEthnicity?.join(','),
      );
    }

    final preferencesData = {
      'preferences': preferences.toJson(),
    };

    await ref.read(profileSetupViewModelProvider.notifier).saveStepData(
          step: ProfileSetupStep.preferences,
          stepData: preferencesData,
        );

    // Complete the entire profile setup
    await ref.read(profileSetupViewModelProvider.notifier).completeProfile();

    final setupState = ref.read(profileSetupViewModelProvider);
    if (setupState.errorMessage == null && mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.dashboardPage,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final metalProps = ref.watch(metalPropertiesProvider);
    final setupState = ref.watch(profileSetupViewModelProvider);

    if (metalProps.data == null) {
      return const BaseScreen(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BaseScreen(
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: AppStrings.preferencesInMetal,
      authFlow: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            CreateProfileHeader2(
              path: Assets.images.heartLocks1.path,
              title: AppStrings.preferencesTitle,
              subtitle: AppStrings.preferencesSubtitle,
            ),
            Gap(ProfileSetupConstants.gapSmall),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ProfileSetupConstants.horizontalPadding,
              ),
              child: Column(
                children: [
                  CustomCheckWidget(
                    boarder: true,
                    title: AppStrings.openToAnyonePartnerFilters,
                    initialValue: _noSpecialPreference,
                    onChanged: (bool value) {
                      setState(() {
                        _noSpecialPreference = value;
                        if (value) {
                          _selectedAgeRange = null;
                          _selectedReligion = null;
                          _selectedEthnicity = null;
                          _selectedEducation = null;
                          _selectedDemography = null;
                        }
                      });
                    },
                  ),
                  Gap(ProfileSetupConstants.gapSmall),
                  const TextView(
                    text: AppStrings.specialPreferencesHint,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                  Gap(ProfileSetupConstants.gapSmall),
                  const TextView(
                    text: AppStrings.preferencesPartnerFiltersExplainer,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                  Gap(15),
                  AbsorbPointer(
                    absorbing: _noSpecialPreference,
                    child: Opacity(
                      opacity: _noSpecialPreference
                          ? ProfileSetupConstants.disabledOpacity
                          : 1.0,
                      child: MentalDropdownMutipleSelection(
                        items: ProfileSetupConstants.ageRanges,
                        value: _selectedAgeRange,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedAgeRange = newValue;
                          });
                        },
                        floatingLabel: AppStrings.ageRange,
                        hint: AppStrings.pleaseSelect,
                        prefixIcon: SvgPicture.asset(
                          Assets.icons.single.path,
                          height: ProfileSetupConstants.iconSize,
                          width: ProfileSetupConstants.iconSize,
                        ),
                      ),
                    ),
                  ),
                  Gap(15),
                  AbsorbPointer(
                    absorbing: _noSpecialPreference,
                    child: Opacity(
                      opacity: _noSpecialPreference
                          ? ProfileSetupConstants.disabledOpacity
                          : 1.0,
                      child: MentalDropdownMutipleSelection(
                        items: metalProps.data!.religion!,
                        value: _selectedReligion,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedReligion = newValue;
                          });
                        },
                        floatingLabel: AppStrings.partnerReligionPreferenceLabel,
                        hint: AppStrings.pleaseSelect,
                        prefixIcon: Assets.icons.christianity.svg(
                          width: ProfileSetupConstants.iconSize,
                          height: ProfileSetupConstants.iconSize,
                        ),
                      ),
                    ),
                  ),
                  Gap(15),
                  AbsorbPointer(
                    absorbing: _noSpecialPreference,
                    child: Opacity(
                      opacity: _noSpecialPreference
                          ? ProfileSetupConstants.disabledOpacity
                          : 1.0,
                      child: MentalDropdownMutipleSelection(
                        items: metalProps.data!.ethnicity!,
                        value: _selectedEthnicity,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedEthnicity = newValue;
                          });
                        },
                        floatingLabel: AppStrings.partnerEthnicityPreferenceLabel,
                        hint: AppStrings.pleaseSelect,
                        prefixIcon: SvgPicture.asset(
                          Assets.icons.intersectCircle.path,
                          height: ProfileSetupConstants.iconSize,
                          width: ProfileSetupConstants.iconSize,
                        ),
                      ),
                    ),
                  ),
                  Gap(15),
                  AbsorbPointer(
                    absorbing: _noSpecialPreference,
                    child: Opacity(
                      opacity: _noSpecialPreference
                          ? ProfileSetupConstants.disabledOpacity
                          : 1.0,
                      child: MentalDropdownMutipleSelection(
                        items: metalProps.data!.education!,
                        value: _selectedEducation,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedEducation = newValue;
                          });
                        },
                        floatingLabel: AppStrings.partnerEducationPreferenceLabel,
                        hint: AppStrings.pleaseSelect,
                        prefixIcon: SvgPicture.asset(
                          Assets.icons.graduationHat01.path,
                          height: ProfileSetupConstants.iconSize,
                          width: ProfileSetupConstants.iconSize,
                        ),
                      ),
                    ),
                  ),
                  Gap(15),
                  AbsorbPointer(
                    absorbing: _noSpecialPreference,
                    child: Opacity(
                      opacity: _noSpecialPreference
                          ? ProfileSetupConstants.disabledOpacity
                          : 1.0,
                      child: MentalDropdownMutipleSelection(
                        items: metalProps.data!.demography!,
                        value: _selectedDemography,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedDemography = newValue;
                          });
                        },
                        floatingLabel: AppStrings.demography,
                        hint: AppStrings.pleaseSelect,
                        prefixIcon: SvgPicture.asset(
                          Assets.icons.markerPin03.path,
                          height: ProfileSetupConstants.iconSize,
                          width: ProfileSetupConstants.iconSize,
                        ),
                      ),
                    ),
                  ),
                  Gap(ProfileSetupConstants.gapLarge),
                  BaseButton(
                    enabled: (_noSpecialPreference == true ||
                            (_selectedAgeRange != null &&
                                _selectedReligion != null &&
                                _selectedEthnicity != null &&
                                _selectedEducation != null &&
                                _selectedDemography != null)) &&
                        !setupState.isLoading,
                    loading: setupState.isLoading,
                    buttonText: setupState.isLoading
                        ? AppStrings.saving
                        : AppStrings.completeProfile,
                    onPressed: _onNextPressed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
