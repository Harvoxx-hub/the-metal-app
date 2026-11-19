import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/strings/app_strings.dart';
import 'package:metal/presentation/widgets/profile_setup_header.dart';
import 'package:metal/presentation/viewmodels/profile/metal_properties_provider.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/profile/profile_setup_viewmodel.dart';
import 'package:metal/presentation/views/profile/profile_setup_constants.dart';
import 'package:metal/presentation/views/profile/profile_setup_helpers.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/dropdown/metal.dropdown.dart';
import 'package:metal/widgets/dropdown/metal.dropdownMutipleSelection.dart';

/// About You View - Step 4 of profile setup
/// Collects: Marital Status, Religion, Profession, Language
class AboutYouView extends ConsumerStatefulWidget {
  const AboutYouView({super.key});
  static const name = 'aboutYou';
  static const route = '/$name';

  @override
  ConsumerState<AboutYouView> createState() => _AboutYouViewState();
}

class _AboutYouViewState extends ConsumerState<AboutYouView> {
  String? _maritalStatus;
  String? _religion;
  String? _profession;
  List<String>? _language;

  void _onNextPressed() async {
    final stepData = {
      'extraData': {
        // Must match [UserExtraDataModel] / API: `marriageStatus`, not `maritalStatus`.
        'marriageStatus': _maritalStatus,
        'religion': _religion,
        'profession': _profession,
        'language': _language?.join(","),
      },
    };

    await ProfileSetupHelpers.saveStepAndNavigate(
      context: context,
      ref: ref,
      step: ProfileSetupStep.aboutYou,
      stepData: stepData,
      nextRoute: AppRoutes.moreAboutYouPage,
      mounted: mounted,
    );
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
      Header: AppStrings.aboutYou,
      authFlow: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            CreateProfileHeader2(
              path: Assets.images.aboutYou.path,
              title: AppStrings.aboutYouTitle,
              subtitle: AppStrings.aboutYouSubtitle,
            ),
            Gap(ProfileSetupConstants.gapLarge),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ProfileSetupConstants.horizontalPadding,
              ),
              child: Column(
                children: [
                  MentalDropdown(
                    items: metalProps.data!.marriageStatus!,
                    onChanged: (String? value) {
                      setState(() {
                        _maritalStatus = value;
                      });
                    },
                    prefixIcon: Assets.icons.single.svg(
                      width: ProfileSetupConstants.iconSize,
                      height: ProfileSetupConstants.iconSize,
                    ),
                    value: _maritalStatus,
                    hint: AppStrings.pleaseSelect,
                    floatingLabel: AppStrings.maritalStatus,
                  ),
                  Gap(ProfileSetupConstants.gapMedium),
                  MentalDropdown(
                    items: metalProps.data!.religion!,
                    onChanged: (String? value) {
                      setState(() {
                        _religion = value;
                      });
                    },
                    prefixIcon: Assets.icons.christianity.svg(
                      width: ProfileSetupConstants.iconSize,
                      height: ProfileSetupConstants.iconSize,
                    ),
                    value: _religion,
                    hint: AppStrings.pleaseSelect,
                    floatingLabel: AppStrings.yourReligionLabel,
                  ),
                  Gap(ProfileSetupConstants.gapMedium),
                  MentalDropdown(
                    items: metalProps.data!.profession!,
                    onChanged: (String? value) {
                      setState(() {
                        _profession = value;
                      });
                    },
                    prefixIcon: Assets.icons.profession.svg(
                      width: ProfileSetupConstants.iconSize,
                      height: ProfileSetupConstants.iconSize,
                    ),
                    value: _profession,
                    hint: AppStrings.pleaseSelect,
                    floatingLabel: AppStrings.professionLabel,
                  ),
                  Gap(ProfileSetupConstants.gapMedium),
                  MentalDropdownMutipleSelection(
                    items: metalProps.data!.language!,
                    value: _language ?? [],
                    onChanged: (List<String> newValue) {
                      setState(() {
                        _language = newValue;
                      });
                    },
                    floatingLabel: AppStrings.language,
                    hint: AppStrings.pleaseSelect,
                    prefixIcon: Assets.icons.profession.svg(
                      width: ProfileSetupConstants.iconSize,
                      height: ProfileSetupConstants.iconSize,
                    ),
                  ),
                  Gap(ProfileSetupConstants.gapLarge),
                  BaseButton(
                    buttonText:
                        ProfileSetupHelpers.getButtonText(setupState.isLoading),
                    enabled: !setupState.isLoading,
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
