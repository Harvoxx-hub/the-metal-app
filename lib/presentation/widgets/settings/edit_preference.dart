import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/strings/app_strings.dart';
import 'package:metal/data/models/user_preferences_model.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/profile/metal_properties_provider.dart';
import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dropdown/metal.dropdown.dart';
import 'package:metal/widgets/dropdown/metal.dropdownMutipleSelection.dart';
import 'package:metal/widgets/text_views.dart';

class EditPreference extends ConsumerStatefulWidget {
  const EditPreference({
    super.key,
    required this.onPress,
    this.initialPreferences,
  });

  final Function(UserPreferencesModel) onPress;
  final UserPreferencesModel? initialPreferences;

  @override
  ConsumerState<EditPreference> createState() => _EditPreferenceState();
}

class _EditPreferenceState extends ConsumerState<EditPreference> {
  List<String>? selectedAgeRange;
  List<String>? selectedReligion;
  List<String>? selectedEthnicity;
  List<String>? selectedEducation;
  List<String>? selectedDemography;
  bool noSpecialPreference = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPreferences != null) {
      selectedAgeRange = _splitAndClean(widget.initialPreferences!.ageRange);
      selectedReligion = _splitAndClean(widget.initialPreferences!.religion);
      selectedEthnicity = _splitAndClean(widget.initialPreferences!.ethnicity);
      selectedEducation = _splitAndClean(widget.initialPreferences!.education);
      selectedDemography = _splitAndClean(widget.initialPreferences!.demography);
      // Set noSpecialPreference if all preferences are null/empty
      noSpecialPreference = (selectedAgeRange?.isEmpty ?? true) &&
          (selectedReligion?.isEmpty ?? true) &&
          (selectedEthnicity?.isEmpty ?? true) &&
          (selectedEducation?.isEmpty ?? true) &&
          (selectedDemography?.isEmpty ?? true);
    }
  }

  List<String>? _splitAndClean(String? value) {
    if (value == null || value.trim().isEmpty) return [];
    return value
        .split(",")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String? _joinAndClean(List<String>? list) {
    if (list == null || list.isEmpty) return null;
    final cleaned = list.where((e) => e.trim().isNotEmpty).toList();
    return cleaned.isEmpty ? null : cleaned.join(',');
  }

  @override
  Widget build(BuildContext context) {
    final metalProps = ref.watch(metalPropertiesProvider);

    return SingleChildScrollView(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            const Gap(15),
            const TextView(
              text: "Edit Preferences in Metal",
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
            const Gap(15),
            const TextView(
              text: AppStrings.preferencesPartnerFiltersExplainer,
              fontSize: 14,
              fontWeight: FontWeight.w300,
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            CustomCheckWidget(
              boarder: true,
              title: AppStrings.openToAnyonePartnerFilters,
              initialValue: noSpecialPreference,
              onChanged: (bool value) {
                setState(() {
                  noSpecialPreference = value;
                  if (value) {
                    // Clear all selections when "No Special Preference" is checked
                    selectedAgeRange = null;
                    selectedReligion = null;
                    selectedEthnicity = null;
                    selectedEducation = null;
                    selectedDemography = null;
                  }
                });
              },
            ),
            const Gap(16),
            const TextView(
              text: AppStrings.specialPreferencesHint,
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
            const Gap(15),
            AbsorbPointer(
              absorbing: noSpecialPreference,
              child: Opacity(
                opacity: noSpecialPreference ? 0.5 : 1.0,
                child: MentalDropdown(
                  items: const [
                    "18 - 25 years",
                    "25 - 30 years",
                    "30 - 35 years",
                    "35 - 40 years",
                    "40 - 45 years",
                    "45 - 50 years",
                    "50 - 55 years",
                    "55 - 60 years",
                    "Above 60 years",
                  ],
                  onChanged: (newValue) {
                    setState(() {
                      selectedAgeRange = newValue?.split(",") ?? [];
                    });
                  },
                  value: _joinAndClean(selectedAgeRange),
                  floatingLabel: "Age range",
                  hint: "Please Select",
                  prefixIcon: SvgPicture.asset(
                    Assets.icons.single.path,
                    height: 24,
                    width: 24,
                  ),
                ),
              ),
            ),
            const Gap(15),
            AbsorbPointer(
              absorbing: noSpecialPreference,
              child: Opacity(
                opacity: noSpecialPreference ? 0.5 : 1.0,
                child: MentalDropdownMutipleSelection(
                  items: metalProps.data?.religion ?? [],
                  value: selectedReligion,
                  onChanged: (newValue) {
                    setState(() {
                      selectedReligion = newValue;
                    });
                  },
                  floatingLabel: AppStrings.partnerReligionPreferenceLabel,
                  hint: "Please Select",
                  prefixIcon: Assets.icons.christianity.svg(width: 24, height: 24),
                ),
              ),
            ),
            const Gap(15),
            AbsorbPointer(
              absorbing: noSpecialPreference,
              child: Opacity(
                opacity: noSpecialPreference ? 0.5 : 1.0,
                child: MentalDropdownMutipleSelection(
                  items: metalProps.data?.ethnicity ?? [],
                  value: selectedEthnicity,
                  onChanged: (newValue) {
                    setState(() {
                      selectedEthnicity = newValue;
                    });
                  },
                  floatingLabel: AppStrings.partnerEthnicityPreferenceLabel,
                  hint: "Please Select",
                  prefixIcon: SvgPicture.asset(
                    Assets.icons.intersectCircle.path,
                    height: 24,
                    width: 24,
                  ),
                ),
              ),
            ),
            const Gap(15),
            AbsorbPointer(
              absorbing: noSpecialPreference,
              child: Opacity(
                opacity: noSpecialPreference ? 0.5 : 1.0,
                child: MentalDropdownMutipleSelection(
                  items: metalProps.data?.education ?? [],
                  value: selectedEducation,
                  onChanged: (newValue) {
                    setState(() {
                      selectedEducation = newValue;
                    });
                  },
                  floatingLabel: AppStrings.partnerEducationPreferenceLabel,
                  hint: "Please Select",
                  prefixIcon: SvgPicture.asset(
                    Assets.icons.graduationHat01.path,
                    height: 24,
                    width: 24,
                  ),
                ),
              ),
            ),
            const Gap(15),
            AbsorbPointer(
              absorbing: noSpecialPreference,
              child: Opacity(
                opacity: noSpecialPreference ? 0.5 : 1.0,
                child: MentalDropdownMutipleSelection(
                  items: metalProps.data?.demography ?? [],
                  value: selectedDemography,
                  onChanged: (newValue) {
                    setState(() {
                      selectedDemography = newValue;
                    });
                  },
                  floatingLabel: "Demography",
                  hint: "Please Select",
                  prefixIcon: SvgPicture.asset(
                    Assets.icons.markerPin03.path,
                    height: 24,
                    width: 24,
                  ),
                ),
              ),
            ),
            const Gap(38),
            BaseButton(
              buttonText: "Save",
              onPressed: () {
                UserPreferencesModel preferences;

                if (noSpecialPreference) {
                  // If no special preference is selected, create empty preferences
                  preferences = UserPreferencesModel(
                    ageRange: null,
                    religion: null,
                    demography: null,
                    education: null,
                    ethnicity: null,
                  );
                } else {
                  preferences = UserPreferencesModel(
                    ageRange: _joinAndClean(selectedAgeRange),
                    religion: _joinAndClean(selectedReligion),
                    demography: _joinAndClean(selectedDemography),
                    education: _joinAndClean(selectedEducation),
                    ethnicity: _joinAndClean(selectedEthnicity),
                  );
                }

                widget.onPress(preferences);
                Navigator.pop(context);
              },
            ),
            const Gap(23),
          ],
        ),
      ),
    );
  }
}

