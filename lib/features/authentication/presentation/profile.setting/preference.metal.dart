import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/presentation/widget/create.profile.header2.dart';
import 'package:metal/features/authentication/provider/metal.properties.notifier.dart';
import 'package:metal/features/authentication/provider/update.profile.notifier.dart';
import 'package:metal/gen/assets.gen.dart';

 
import 'package:metal/route/routes.dart';

import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/dropdown/metal.dropdownMutipleSelection.dart';
 
import 'package:metal/widgets/text_views.dart';

class PreferenceMetalPage extends ConsumerStatefulWidget {
  const PreferenceMetalPage({super.key});
  static const pageName = 'PreferenceMetalPage';
  static const route = '/$pageName';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PreferenceMetalPageState();
}

class _PreferenceMetalPageState extends ConsumerState<PreferenceMetalPage> {
  List<String>? selectedAgeRange;
  List<String>? selectedReligion;
  List<String>? selectedEthnicity;
  List<String>? selectedEducation;
  List<String>? selectedDemography;
  bool noSpecialPreference = false;

  @override
  Widget build(BuildContext context) {
    final metalProps = ref.watch(metalPropertiesProvider);
    return BaseScreen(
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: 'Preferences in Metal',
      authFlow: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            CreateProfileHeader2(
              path: Assets.images.heartLocks1.path,
              title: "Let us know what your special preferences are in a person",
              subtitle: " ",
            ),
            const Gap(16 ),
            CustomCheckWidget(
              boarder: true,
              title: 'No Special Preference',
              initialValue: noSpecialPreference,
              onChanged: (bool value) {
                setState(() {
                  noSpecialPreference = value;
                });
              },
            ),
            const Gap(16 ),
            const TextView(
              text: "If you have special preferences, please select below.",
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
            const Gap(15 ),
            MentalDropdownMutipleSelection(
              items: const [
                "18 - 30 years",
                "30 - 45 years",
                "45 - 60 years",
                "Above 60 years",
              ],
              value: selectedAgeRange,
              onChanged: (newValue) {
                setState(() {
                  selectedAgeRange = newValue;
                });
              },
              floatingLabel: "Age range",
              hint: "Please Select",
              prefixIcon: SvgPicture.asset(
                Assets.icons.single.path,
                height: 24,
                width: 24,
              ),
            ),
            const Gap(15 ),
            MentalDropdownMutipleSelection(
              items: metalProps.data!.religion!,
              value: selectedReligion,
              onChanged: (newValue) {
                setState(() {
                  selectedReligion = newValue;
                });
              },
              floatingLabel: "Religion",
              hint: "Please Select",
              prefixIcon: Assets.icons.christianity.svg(width: 24, height: 24),
            ),
            const Gap(15 ),
            MentalDropdownMutipleSelection(
              items: metalProps.data!.ethnicity!,
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
            const Gap(15 ),
            MentalDropdownMutipleSelection(
              items: metalProps.data!.education!,
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
            const Gap(15 ),
            MentalDropdownMutipleSelection(
              items: metalProps.data!.demography!,
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
            const Gap(15 ),
            BaseButton(
              enabled: noSpecialPreference == true
                  ? true
                  : (selectedAgeRange != null &&
                      selectedReligion != null &&
                      selectedEthnicity != null &&
                      selectedEducation != null &&
                      selectedDemography != null),
              buttonText: "Next",
              onPressed: _onNextPressed,
            ),
          ],
        ),
      ),
    );
  }

  void _onNextPressed() {
    final userData = ref.watch(updateProfileProvider).data;
    final preferences = Preferences()
      ..age_range = selectedAgeRange?.join(',')
      ..religion = selectedReligion?.join(',')
      ..demography = selectedDemography?.join(',')
      ..education = selectedEducation?.join(',')
      ..ethnicity = selectedEthnicity?.join(',');
    userData!.preferences = preferences;
    ref.read(updateProfileProvider.notifier).updateUserData(userData);

    Navigator.pushNamed(
      context,
      AppRoutes .homeAddressPage,
    );
  }
}
