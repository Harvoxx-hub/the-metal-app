import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/metal.properties.notifier.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/features/profile/presentation/widget/edit.field.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dropdown/metal.dropdown.dart';
import 'package:metal/widgets/dropdown/metal.dropdownMutipleSelection.dart';
import 'package:metal/widgets/text_views.dart';

class EditPreferences extends ConsumerStatefulWidget {
  const EditPreferences({super.key});

  @override
  ConsumerState<EditPreferences> createState() => _EditPreferencesState();
}

class _EditPreferencesState extends ConsumerState<EditPreferences> {
  RangeValues selectedAgeRange = const RangeValues(18, 60);
  List<String>? selectedReligion;
  List<String>? selectedEthnicity;
  List<String>? selectedEducation;
  String? selectedDemography; // Changed to single selection
  double maximumDistance = 50.0; // Maximum distance in km
  bool enableDistanceFilter = true; // Enable/disable distance filtering
  bool noSpecialPreference = false;
  bool _isLoading = false;

  bool _hasLoadedPreferences = false;

  void _loadCurrentPreferences() {
    if (_hasLoadedPreferences) return;

    final userState = ref.read(userStateProvider).data;
    final currentPreferences = userState?.preferences;

    if (currentPreferences != null) {
      // Parse age range from stored format (e.g., "18 - 25 years" or "18,25,30")
      selectedAgeRange = _parseAgeRange(currentPreferences.ageRange);
      selectedReligion = _splitAndClean(currentPreferences.religion);
      selectedEthnicity = _splitAndClean(currentPreferences.ethnicity);
      selectedEducation = _splitAndClean(currentPreferences.education);

      // Demography is now single selection - take first value if multiple exist
      final demographyList = _splitAndClean(currentPreferences.demography);
      selectedDemography =
          demographyList?.isNotEmpty == true ? demographyList!.first : null;

      // Set noSpecialPreference if all "other preferences" are null/empty
      // Note: Demography and age range are in first section, not affected by this
      noSpecialPreference = (selectedReligion?.isEmpty ?? true) &&
          (selectedEthnicity?.isEmpty ?? true) &&
          (selectedEducation?.isEmpty ?? true);
    }

    // Load maximum distance from user's distance field
    if (userState?.distance != null) {
      final distanceStr =
          userState!.distance!.replaceAll(RegExp(r'[^0-9.]'), '');
      maximumDistance = double.tryParse(distanceStr) ?? 50.0;
    }

    // Load distance filter enable/disable preference
    enableDistanceFilter = userState?.enableDistanceFilter ?? true;

    _hasLoadedPreferences = true;
  }

  RangeValues _parseAgeRange(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const RangeValues(18, 60);
    }

    // Try to parse formats like "18 - 25 years" or "18,25"
    final rangeMatch = RegExp(r'(\d+)\s*-\s*(\d+)').firstMatch(value);
    if (rangeMatch != null) {
      final min = int.tryParse(rangeMatch.group(1) ?? '18') ?? 18;
      final max = int.tryParse(rangeMatch.group(2) ?? '60') ?? 60;
      return RangeValues(min.toDouble(), max.toDouble());
    }

    // Try comma-separated values
    final parts = value
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList();
    if (parts.length >= 2) {
      parts.sort();
      return RangeValues(parts.first.toDouble(), parts.last.toDouble());
    }

    // Default range
    return const RangeValues(18, 60);
  }

  String? _formatAgeRange(RangeValues range) {
    final min = range.start.round();
    final max = range.end.round();
    return '$min - $max years';
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

  String _getLocationText(UserModel? userState) {
    if (userState?.location == null) {
      return "Location not set";
    }

    final location = userState!.location!;
    final parts = <String>[];

    if (location.address != null && location.address!.isNotEmpty) {
      parts.add(location.address!);
    } else if (location.city != null && location.city!.isNotEmpty) {
      parts.add(location.city!);
      if (location.state != null && location.state!.isNotEmpty) {
        parts.add(location.state!);
      }
      if (location.country != null && location.country!.isNotEmpty) {
        parts.add(location.country!);
      }
    } else if (location.country != null && location.country!.isNotEmpty) {
      parts.add(location.country!);
    }

    return parts.isEmpty ? "Location not set" : parts.join(", ");
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userStateProvider).data;
    final metalProperties = ref.watch(metalPropertiesProvider).data;

    // Load preferences once when userState is available
    if (userState != null && !_hasLoadedPreferences) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _loadCurrentPreferences();
          });
        }
      });
    }

    return BaseScreen(
      appBarState: AppBarState.BackWithHeader,
      Header: "Edit Preferences",
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.00, -1.00),
                        end: Alignment(0, 1),
                        colors: [Color(0xFFDB217A), Color(0xFFF00E3E)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(35),
                        bottomRight: Radius.circular(35),
                      )),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 24.0, right: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 29, left: 9, right: 9),
              child: Container(
                  padding: const EdgeInsets.only(
                      top: 55, left: 22, right: 22, bottom: 22),
                  decoration: const BoxDecoration(
                      color: AppColors.metalWhite,
                      borderRadius: BorderRadius.all(
                        Radius.circular(35),
                      )),
                  child: Column(
                    children: [
                      const Gap(20),

                      // FIRST SECTION
                      // 1. Location (not editable)
                      EditField(
                        text: _getLocationText(userState),
                        floatingLabel: "Current Location",
                        suffixIcon: SvgPicture.asset(
                          Assets.icons.markerPin03.path,
                          height: 24,
                          width: 24,
                        ),
                      ),

                      const Gap(20),

                      // 2. Demographics (single selection)
                      MentalDropdown(
                        items: metalProperties?.demography ?? [],
                        value: selectedDemography,
                        onChanged: (newValue) {
                          setState(() {
                            selectedDemography = newValue;
                          });
                        },
                        floatingLabel: "Demographics",
                        hint: "Please Select",
                        prefixIcon: SvgPicture.asset(
                          Assets.icons.markerPin03.path,
                          height: 24,
                          width: 24,
                        ),
                      ),

                      const Gap(20),

                      // 3. Maximum Distance
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const TextView(
                                text: "Maximum Distance",
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.metalBrownColourForText,
                              ),
                              Row(
                                children: [
                                  TextView(
                                    text: enableDistanceFilter
                                        ? "Enabled"
                                        : "Disabled",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: enableDistanceFilter
                                        ? AppColors.metalPinkColour
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Switch(
                                    value: enableDistanceFilter,
                                    onChanged: (value) {
                                      setState(() {
                                        enableDistanceFilter = value;
                                      });
                                    },
                                    activeColor: AppColors.metalPinkColour,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Gap(8),
                          AbsorbPointer(
                            absorbing: !enableDistanceFilter,
                            child: Opacity(
                              opacity: enableDistanceFilter ? 1.0 : 0.5,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: AppColors.metalTabBg,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: AppColors.metalButtonStroke,
                                    width: 1.0,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                        sliderTheme: SliderThemeData(
                                          trackHeight: 4.0,
                                          activeTrackColor:
                                              AppColors.metalPinkColour,
                                          inactiveTrackColor:
                                              AppColors.metalButtonStroke,
                                          thumbColor: AppColors.metalPinkColour,
                                          overlayColor:
                                              AppColors.metalPinkColour40,
                                          thumbShape:
                                              const RoundSliderThumbShape(
                                            enabledThumbRadius: 12.0,
                                          ),
                                          overlayShape:
                                              const RoundSliderOverlayShape(
                                            overlayRadius: 20.0,
                                          ),
                                        ),
                                      ),
                                      child: Slider(
                                        value: maximumDistance,
                                        min: 1,
                                        max: 100,
                                        divisions: 99,
                                        label: '${maximumDistance.round()} km',
                                        activeColor: AppColors.metalPinkColour,
                                        inactiveColor:
                                            AppColors.metalButtonStroke,
                                        onChanged: (newValue) {
                                          setState(() {
                                            maximumDistance = newValue;
                                          });
                                        },
                                      ),
                                    ),
                                    const Gap(8),
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.metalPinkColour40,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: TextView(
                                          text: '${maximumDistance.round()} km',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.metalPinkColour,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Gap(20),

                      // 4. Connect with
                      EditField(
                        text: userState?.connectWith ?? "Connect with",
                        floatingLabel: "Connect with",
                        subLabel: "Edit",
                        dropDownItems: const [
                          "Male",
                          "Female",
                          "Everyone",
                        ],
                        editType: EditType.dropdown,
                        onSubLabel: (value) {
                          updateUser('connectWith', value);
                        },
                      ),

                      const Gap(20),

                      // 5. Connection option
                      EditField(
                        text: userState?.connectionOption?.join(", ") ??
                            "Connection option",
                        floatingLabel: "Connection option",
                        subLabel: "Edit",
                        outboundWidget: true,
                        isConnectionOption: true,
                        onSubLabel: (value) {
                          List<String> connectionOption = value;
                          updateUser('connectionOption', connectionOption);
                        },
                      ),

                      const Gap(20),

                      // 6. Age range
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                Assets.icons.single.path,
                                height: 24,
                                width: 24,
                              ),
                              const Gap(10),
                              const TextView(
                                text: "Age range",
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.metalBrownColourForText,
                              ),
                            ],
                          ),
                          const Gap(8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 12.0),
                            decoration: BoxDecoration(
                              color: AppColors.metalTabBg,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: AppColors.metalButtonStroke,
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    sliderTheme: SliderThemeData(
                                      trackHeight: 4.0,
                                      activeTrackColor:
                                          AppColors.metalPinkColour,
                                      inactiveTrackColor:
                                          AppColors.metalButtonStroke,
                                      thumbColor: AppColors.metalPinkColour,
                                      overlayColor: AppColors.metalPinkColour40,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 12.0,
                                      ),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                        overlayRadius: 20.0,
                                      ),
                                      valueIndicatorShape:
                                          const PaddleSliderValueIndicatorShape(),
                                      valueIndicatorColor:
                                          AppColors.metalPinkColour,
                                      valueIndicatorTextStyle: const TextStyle(
                                        color: AppColors.metalWhite,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  child: RangeSlider(
                                    values: selectedAgeRange,
                                    min: 18,
                                    max: 80,
                                    divisions: 62,
                                    activeColor: AppColors.metalPinkColour,
                                    inactiveColor: AppColors.metalButtonStroke,
                                    labels: RangeLabels(
                                      '${selectedAgeRange.start.round()}',
                                      '${selectedAgeRange.end.round()}',
                                    ),
                                    onChanged: (RangeValues newRange) {
                                      setState(() {
                                        selectedAgeRange = newRange;
                                      });
                                    },
                                  ),
                                ),
                                const Gap(12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.metalPinkColour40,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: TextView(
                                        text:
                                            '${selectedAgeRange.start.round()} years',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.metalPinkColour,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.metalPinkColour40,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: TextView(
                                        text:
                                            '${selectedAgeRange.end.round()} years',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.metalPinkColour,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Gap(30),

                      // SECOND SECTION - Other Preferences
                      const TextView(
                        text: "Other Preferences",
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      const Gap(10),
                      const TextView(
                        text:
                            "Let us know what your special preferences are in a person",
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        textAlign: TextAlign.left,
                      ),
                      const Gap(16),
                      CustomCheckWidget(
                        boarder: true,
                        title: 'No Special Preference',
                        initialValue: noSpecialPreference,
                        onChanged: (bool value) {
                          setState(() {
                            noSpecialPreference = value;
                            if (value) {
                              // Clear all selections when "No Special Preference" is checked
                              selectedReligion = null;
                              selectedEthnicity = null;
                              selectedEducation = null;
                            }
                          });
                        },
                      ),
                      const Gap(16),
                      const TextView(
                        text:
                            "If you have special preferences, please select below.",
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                      const Gap(15),
                      AbsorbPointer(
                        absorbing: noSpecialPreference,
                        child: Opacity(
                          opacity: noSpecialPreference ? 0.5 : 1.0,
                          child: MentalDropdownMutipleSelection(
                            items: metalProperties?.religion ?? [],
                            value: selectedReligion,
                            onChanged: (newValue) {
                              setState(() {
                                selectedReligion = newValue;
                              });
                            },
                            floatingLabel: "Religion",
                            hint: "Please Select",
                            prefixIcon: Assets.icons.christianity
                                .svg(width: 24, height: 24),
                          ),
                        ),
                      ),
                      const Gap(15),
                      AbsorbPointer(
                        absorbing: noSpecialPreference,
                        child: Opacity(
                          opacity: noSpecialPreference ? 0.5 : 1.0,
                          child: MentalDropdownMutipleSelection(
                            items: metalProperties?.ethnicity ?? [],
                            value: selectedEthnicity,
                            onChanged: (newValue) {
                              setState(() {
                                selectedEthnicity = newValue;
                              });
                            },
                            floatingLabel: "Ethnicity",
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
                            items: metalProperties?.education ?? [],
                            value: selectedEducation,
                            onChanged: (newValue) {
                              setState(() {
                                selectedEducation = newValue;
                              });
                            },
                            floatingLabel: "Education",
                            hint: "Please Select",
                            prefixIcon: SvgPicture.asset(
                              Assets.icons.graduationHat01.path,
                              height: 24,
                              width: 24,
                            ),
                          ),
                        ),
                      ),
                      const Gap(30),
                      BaseButton(
                        buttonText:
                            _isLoading ? "Saving..." : "Save Preferences",
                        onPressed: _isLoading ? null : _savePreferences,
                      ),
                      const Gap(20),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Preferences preferences;

      // Always save first section preferences (demography, ageRange)
      // Only clear "other preferences" when noSpecialPreference is true
      preferences = Preferences(
        ageRange: _formatAgeRange(selectedAgeRange), // Always save age range
        religion: noSpecialPreference ? null : _joinAndClean(selectedReligion),
        demography: selectedDemography, // Always save demography (single value)
        education:
            noSpecialPreference ? null : _joinAndClean(selectedEducation),
        ethnicity:
            noSpecialPreference ? null : _joinAndClean(selectedEthnicity),
      );

      await updateUser('preferences', preferences.toJson());

      // Save maximum distance separately
      await updateUser('distance', '${maximumDistance.round()} km');

      // Save distance filter enable/disable preference
      await updateUser('enableDistanceFilter', enableDistanceFilter);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferences saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving preferences: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save preferences: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> updateUser(String field, dynamic value) async {
    try {
      // Use the new UserStateNotifier for batch updates
      await ref.read(userStateProvider.notifier).updateUserField(
            field: field,
            value: value,
          );
    } catch (e) {
      // Handle error - could show snackbar or toast
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }
}
