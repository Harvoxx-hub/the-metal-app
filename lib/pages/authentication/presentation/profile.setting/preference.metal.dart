import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/pages/authentication/models/passion.card.model.dart';
import 'package:metal/pages/authentication/presentation/home.address/home.address.dart';
import 'package:metal/pages/authentication/presentation/widget/create.profile.header2.dart';
import 'package:metal/utils/screen.size.dart';
import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/dropdown/metal.dropdown.dart';
import 'package:metal/widgets/text_views.dart';

import '../widget/passions.card.dart';

class PreferenceMetalPage extends ConsumerStatefulWidget {
  PreferenceMetalPage({Key? key}) : super(key: key);
  static const name = 'PreferenceMetalPage';
  static const route = '$name';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PreferenceMetalPageState();
}

class _PreferenceMetalPageState extends ConsumerState<PreferenceMetalPage> {
  String? seletedAgeRange;
  String? seletedReligion;
  String? seletedEthnicity;
  String? seletedEducation;
  String? seletedDemography;
  @override
  Widget build(BuildContext context) {
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
                print('Value changed to $value');
              },
            ),
            Gap(16.h),
            TextView(
              text: "If you have special preferences, please select below.",
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
            Gap(15.h),
            MentalDropdown(
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
            MentalDropdown(
              items: const [
                "Christianity",
                "Islam",
                "Hinduism",
                "Buddhism",
                "Sikhim",
                "Judaism",
                "Indigenous religion",
                "Others (Please specify)",
              ],
              value: seletedReligion,
              onChanged: (newValue) {
                setState(() {
                  seletedReligion = newValue;
                });
              },
              floatingLabel: "Religion",
              hint: "Please Select",
              prefixIcon: SvgPicture.asset(
                Assets.icons.christianity.path,
                height: 24,
                width: 24,
              ),
            ),
            Gap(15.h),
            MentalDropdown(
              items: const [
                "African American",
                "Asian",
                "Blacks",
                "Afro Carribean",
                "Caucasian",
                "Others (Please specify)",
              ],
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
              items: const [
                "High School",
                "College/ University Graduate",
                "Masters Degree",
                "Doctoral Degree",
                "Trade Certificate",
                "Others (Please specify)",
              ],
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
            MentalDropdown(
              items: const [
                "Anywhere in the world",
                "Africa",
                "Asia",
                "North America",
                "Europe",
              ],
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
              buttonText: "Next",
              onPressed: _onNextPressed,
            ),
          ],
        )));
  }

  void _onNextPressed() {
    context.pushNamed(HomeAddressPage.name);
  }
}
