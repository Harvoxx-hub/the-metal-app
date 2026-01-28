import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/data/models/user_preferences_model.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/profile/metal_properties_provider.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/presentation/widgets/settings/edit_field.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/dropdown/metal.dropdown.dart';
import 'package:metal/widgets/dropdown/metal.dropdownMutipleSelection.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/presentation/views/prompt/prompt_creation_view.dart';

class EditPreferencesView extends ConsumerStatefulWidget {
  const EditPreferencesView({super.key});

  @override
  ConsumerState<EditPreferencesView> createState() =>
      _EditPreferencesViewState();
}

class _EditPreferencesViewState extends ConsumerState<EditPreferencesView> {
  RangeValues selectedAgeRange = const RangeValues(18, 60);
  List<String>? selectedReligion;
  List<String>? selectedEthnicity;
  List<String>? selectedEducation;
  String? selectedDemography;
  bool noSpecialPreference = false;
  bool _hasLoadedPreferences = false;

  void _loadCurrentPreferences() {
    if (_hasLoadedPreferences) return;

    final user = ref.read(currentUserProvider);
    final currentPreferences = user?.preferences;

    if (currentPreferences != null) {
      selectedAgeRange = _parseAgeRange(currentPreferences.ageRange);
      selectedReligion = _splitAndClean(currentPreferences.religion);
      selectedEthnicity = _splitAndClean(currentPreferences.ethnicity);
      selectedEducation = _splitAndClean(currentPreferences.education);

      final demographyList = _splitAndClean(currentPreferences.demography);
      selectedDemography =
          demographyList?.isNotEmpty == true ? demographyList!.first : null;

      noSpecialPreference = (selectedReligion?.isEmpty ?? true) &&
          (selectedEthnicity?.isEmpty ?? true) &&
          (selectedEducation?.isEmpty ?? true);
    }

    _hasLoadedPreferences = true;
  }

  RangeValues _parseAgeRange(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const RangeValues(18, 60);
    }

    final rangeMatch = RegExp(r'(\d+)\s*-\s*(\d+)').firstMatch(value);
    if (rangeMatch != null) {
      final min = int.tryParse(rangeMatch.group(1) ?? '18') ?? 18;
      final max = int.tryParse(rangeMatch.group(2) ?? '60') ?? 60;
      return RangeValues(min.toDouble(), max.toDouble());
    }

    final parts = value
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList();
    if (parts.length >= 2) {
      parts.sort();
      return RangeValues(parts.first.toDouble(), parts.last.toDouble());
    }

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

  String _getLocationText(UserDto? user) {
    if (user?.location == null) {
      return "Location not set";
    }

    final location = user!.location!;
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
    final user = ref.watch(currentUserProvider);
    final metalProperties = ref.watch(metalPropertiesProvider).data;

    // Load preferences once
    if (user != null && !_hasLoadedPreferences) {
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
                  borderRadius: BorderRadius.all(Radius.circular(35)),
                ),
                child: Column(
                  children: [
                    const Gap(20),
                    // Location (not editable)
                    EditField(
                      text: _getLocationText(user),
                      floatingLabel: "Current Location",
                      suffixIcon: SvgPicture.asset(
                        Assets.icons.markerPin03.path,
                        height: 24,
                        width: 24,
                      ),
                    ),
                    const Gap(20),
                    // Demographics
                    MentalDropdown(
                      items: metalProperties?.demography ?? [],
                      value: selectedDemography,
                      onChanged: (newValue) {
                        setState(() {
                          selectedDemography = newValue;
                        });
                        _pushPreferences();
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
                    // Connect with
                    EditField(
                      text: user?.connectWith ?? "Connect with",
                      floatingLabel: "Connect with",
                      subLabel: "Edit",
                      dropDownItems: const ["Male", "Female", "Everyone"],
                      editType: EditType.dropdown,
                      onSubLabel: (value) => _updateUser('connectWith', value),
                    ),
                    const Gap(20),
                    // Connection option
                    EditField(
                      text: user?.connectionOption?.join(", ") ??
                          "Connection option",
                      floatingLabel: "Connection option",
                      subLabel: "Edit",
                      outboundWidget: true,
                      isConnectionOption: true,
                      onSubLabel: (value) {
                        List<String> connectionOption = value;
                        _updateUser('connectionOption', connectionOption);
                      },
                    ),
                    const Gap(20),
                    // Manage Prompts Section
                    _buildManagePromptsSection(user),
                    const Gap(20),
                    // Age range
                    _buildAgeRangeSection(),
                    const Gap(30),
                    // Other Preferences
                    _buildOtherPreferencesSection(metalProperties),
                    const Gap(20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pushPreferences() async {
    final preferences = UserPreferencesModel(
      ageRange: _formatAgeRange(selectedAgeRange),
      religion: noSpecialPreference ? null : _joinAndClean(selectedReligion),
      demography: selectedDemography,
      education:
          noSpecialPreference ? null : _joinAndClean(selectedEducation),
      ethnicity:
          noSpecialPreference ? null : _joinAndClean(selectedEthnicity),
    );
    final ok = await ref
        .read(userStateProvider.notifier)
        .updateUserField(field: 'preferences', value: preferences.toJson());
    if (!ok && mounted) {
      Fluttertoast.showToast(msg: 'Failed to update preferences');
    }
  }

  Widget _buildAgeRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(Assets.icons.single.path, height: 24, width: 24),
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
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: AppColors.metalTabBg,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.metalButtonStroke, width: 1.0),
          ),
          child: Column(
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  sliderTheme: SliderThemeData(
                    trackHeight: 4.0,
                    activeTrackColor: AppColors.metalPinkColour,
                    inactiveTrackColor: AppColors.metalButtonStroke,
                    thumbColor: AppColors.metalPinkColour,
                    overlayColor: AppColors.metalPinkColour40,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 20.0),
                    valueIndicatorShape:
                        const PaddleSliderValueIndicatorShape(),
                    valueIndicatorColor: AppColors.metalPinkColour,
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
                  onChangeEnd: (_) => _pushPreferences(),
                ),
              ),
              const Gap(12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.metalPinkColour40,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextView(
                      text: '${selectedAgeRange.start.round()} years',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.metalPinkColour,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.metalPinkColour40,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextView(
                      text: '${selectedAgeRange.end.round()} years',
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
    );
  }

  Widget _buildOtherPreferencesSection(metalProperties) {
    return Column(
      children: [
        const TextView(
          text: "Other Preferences",
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        const Gap(10),
        const TextView(
          text: "Let us know what your special preferences are in a person",
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
                selectedReligion = null;
                selectedEthnicity = null;
                selectedEducation = null;
              }
            });
            _pushPreferences();
          },
        ),
        const Gap(16),
        const TextView(
          text: "If you have special preferences, please select below.",
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
                _pushPreferences();
              },
              floatingLabel: "Religion",
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
              items: metalProperties?.ethnicity ?? [],
              value: selectedEthnicity,
              onChanged: (newValue) {
                setState(() {
                  selectedEthnicity = newValue;
                });
                _pushPreferences();
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
                _pushPreferences();
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
      ],
    );
  }

  Widget _buildManagePromptsSection(UserDto? user) {
    final prompts = user?.prompts ?? [];
    final promptCount = prompts.length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.metalTabBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.metalButtonStroke, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextView(
                    text: "Manage Prompts",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.metalBrownColourForText,
                  ),
                  const Gap(4),
                  TextView(
                    text: promptCount >= 3
                        ? "$promptCount prompts selected"
                        : "$promptCount of 3 minimum prompts",
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: promptCount >= 3
                        ? AppColors.metalBrownColourForText.withOpacity(0.7)
                        : AppColors.metalPinkColour,
                  ),
                ],
              ),
              TextButton(
                onPressed: () async {
                  // Navigate to prompt editing and wait for return
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PromptCreationView(
                        isAuthFlow: false,
                      ),
                    ),
                  );
                  
                  // Refresh user data to get latest prompts
                  if (mounted) {
                    await ref.read(userStateProvider.notifier).fetchAndSetUser();
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  backgroundColor: AppColors.metalPinkColour,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const TextView(
                  text: "Edit",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.metalWhite,
                ),
              ),
            ],
          ),
          if (prompts.isNotEmpty) ...[
            const Gap(12),
            const Divider(height: 1),
            const Gap(12),
            ...prompts.take(3).map((prompt) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.metalButtonStroke,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: prompt.questionText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.metalBrownColourForText,
                    ),
                    const Gap(6),
                    TextView(
                      text: prompt.answer,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.metalBrownColourForText.withOpacity(0.7),
                    ),
                  ],
                ),
              );
            }),
            if (prompts.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: TextView(
                  text: "+${prompts.length - 3} more prompt${prompts.length - 3 > 1 ? 's' : ''}",
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.metalPinkColour,
                ),
              ),
          ] else ...[
            const Gap(8),
            TextView(
              text: "Add prompts to express yourself better",
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.metalBrownColourForText.withOpacity(0.6),
            ),
          ],
        ],
      ),
    );
  }

  /// Update user field via single source of truth (userStateProvider)
  Future<void> _updateUser(String field, dynamic value) async {
    await ref.read(userStateProvider.notifier).updateUserField(
      field: field,
      value: value,
    );
  }
}
