import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/core/utils/strings/app_strings.dart';
import 'package:metal/presentation/widgets/profile_setup_header.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/profile/profile_setup_viewmodel.dart';
import 'package:metal/presentation/views/profile/profile_setup_constants.dart';
import 'package:metal/presentation/views/profile/profile_setup_helpers.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';

/// More About You View - Step 5 of profile setup
/// Collects: Bio/Description
class MoreAboutYouView extends ConsumerStatefulWidget {
  const MoreAboutYouView({super.key});
  static const name = 'moreAboutYou';
  static const route = '/$name';

  @override
  ConsumerState<MoreAboutYouView> createState() => _MoreAboutYouViewState();
}

class _MoreAboutYouViewState extends ConsumerState<MoreAboutYouView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _bioController = TextEditingController();

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  void _onNextPressed() async {
    if (!_formKey.currentState!.validate()) return;

    final stepData = {
      'bio': _bioController.text.trim(),
    };

    await ProfileSetupHelpers.saveStepAndNavigate(
      context: context,
      ref: ref,
      step: ProfileSetupStep.moreAboutYou,
      stepData: stepData,
      nextRoute: AppRoutes.promptCreationPage,
      mounted: mounted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(profileSetupViewModelProvider);

    return BaseScreen(
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: AppStrings.moreAboutYou,
      authFlow: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            CreateProfileHeader2(
              path: Assets.images.aboutYou.path,
              title: AppStrings.moreAboutYouTitle,
              subtitle: AppStrings.moreAboutYouSubtitle,
            ),
            Gap(ProfileSetupConstants.gapLarge),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ProfileSetupConstants.horizontalPadding,
                ),
                child: Column(
                  children: [
                    EditFormField(
                      floatingLabel: AppStrings.bio,
                      label: AppStrings.tellUsAboutYourself,
                      controller: _bioController,
                      minLines: 4,
                      maxLines: 6,
                      validator: Validators.validateString(),
                      keyboardType: TextInputType.multiline,
                      radius: 10,
                    ),
                    Gap(ProfileSetupConstants.gapSmall + 4),
                    BaseButton(
                      enabled: !setupState.isLoading,
                      loading: setupState.isLoading,
                      buttonText: ProfileSetupHelpers.getButtonText(
                          setupState.isLoading),
                      onPressed: _onNextPressed,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
