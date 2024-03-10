import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/metal.properties.notifier.dart';
import 'package:metal/features/authentication/provider/update.profile.notifier.dart';
import 'package:metal/gen/assets.gen.dart';

import 'package:metal/features/authentication/presentation/home.address/home.address.dart';
import 'package:metal/features/authentication/presentation/widget/create.profile.header2.dart';
import 'package:metal/route/routes.dart';

import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/dropdown/metal.dropdown.dart';
import 'package:metal/widgets/dropdown/metal.dropdownMutipleSelection.dart';
import 'package:metal/widgets/text_views.dart';

class PreferenceMetalPage extends ConsumerStatefulWidget {
  PreferenceMetalPage({Key? key}) : super(key: key);
  static const name = 'PreferenceMetalPage';
  static const route = '$name';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PreferenceMetalPageState();
}

class _PreferenceMetalPageState extends ConsumerState<PreferenceMetalPage> {
  List<String>? seletedAgeRange;
  List<String>? seletedReligion;
  String? seletedEthnicity;
  String? seletedEducation;
  List<String>? seletedDemography;
  bool _value = false;
  @override
  Widget build(BuildContext context) {
    final _metalProps = ref.watch(metalPropertiesProvider);
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
                title:
                    "Let us know what your special preferences are in a person",
                subtitle: " "),
            Gap(16.h),
            CustomCheckWidget(
              boarder: true,
              title: 'No Special Preference',
              initialValue: false,
              onChanged: (bool value) {
                setState(() {
                  _value = value;
                });
              },
            ),
            Gap(16.h),
            TextView(
              text: "If you have special preferences, please select below.",
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
            Gap(15.h),
            MentalDropdownMutipleSelection(
              items: const [
                "18 - 30 years",
                "30 - 45 years",
                "45 - 60 years",
                "Above 60 years",
              ],
              value: seletedAgeRange,
              onChanged: (newValue) {
                setState(() {
                  seletedAgeRange = newValue;
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
            Gap(15.h),
            MentalDropdownMutipleSelection(
              items: _metalProps.data!.religion!,
              value: seletedReligion,
              onChanged: (newValue) {
                setState(() {
                  seletedReligion = newValue;
                });
              },
              floatingLabel: "Religion",
              hint: "Please Select",
              prefixIcon: Assets.icons.christianity.svg(width: 24, height: 24),
            ),
            Gap(15.h),
            MentalDropdown(
              items:  _metalProps.data!.ethnicity!,
              value: seletedEthnicity,
              onChanged: (newValue) {
                setState(() {
                  seletedEthnicity = newValue;
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
            Gap(15.h),
            MentalDropdown(
              items:  _metalProps.data!.education!,
              value: seletedEducation,
              onChanged: (newValue) {
                setState(() {
                  seletedEducation = newValue;
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
            Gap(15.h),
            MentalDropdownMutipleSelection(
              items:  _metalProps.data!.demography!,
              value: seletedDemography,
              onChanged: (newValue) {
                setState(() {
                  seletedDemography = newValue;
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
            Gap(15.h),
            BaseButton(
              enabled: _value == true
                  ? true
                  : (seletedAgeRange != null &&
                      seletedReligion != null &&
                      seletedEthnicity != null &&
                      seletedEducation != null &&
                      seletedDemography != null),
              buttonText: "Next",
              onPressed: _onNextPressed,
            ),
          ],
        )));
  }

  void _onNextPressed() {
    final userData = ref.watch(updateProfileProvider).data;
    final Preferences preferences = Preferences();
    preferences.age_range = seletedAgeRange!.join(',');
    preferences.religion = seletedReligion!.join(',');
    preferences.demography = seletedDemography!.join(',');
    preferences.education = seletedEducation ?? "";
    preferences.ethnicity = seletedEthnicity?? "";
    userData!.preferences = preferences;
    ref.read(updateProfileProvider.notifier).updateUserData(userData);

     Navigator.pushNamed(context,  AppRoutes.homeAddressPage, );


 
  }
}
