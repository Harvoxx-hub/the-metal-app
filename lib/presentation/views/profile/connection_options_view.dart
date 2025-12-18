import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:metal/presentation/widgets/profile_setup_cards.dart';

/// Connection Options View - Step 6 of profile setup
/// What are you looking for in a person
class ConnectionOptionsView extends ConsumerStatefulWidget {
  const ConnectionOptionsView({super.key});
  static const name = 'connectionOptions';
  static const route = '/$name';

  @override
  ConsumerState<ConnectionOptionsView> createState() =>
      _ConnectionOptionsViewState();
}

class _ConnectionOptionsViewState extends ConsumerState<ConnectionOptionsView> {
  final List<String> _selectedOptions = [];

  void _updateOption(String option) {
    setState(() {
      if (_selectedOptions.contains(option)) {
        _selectedOptions.remove(option);
      } else {
        if (_selectedOptions.length <
            ProfileSetupConstants.maxConnectionOptions) {
          _selectedOptions.add(option);
        } else {
          ProfileSetupHelpers.showWarning(context, AppStrings.maxTwoOptions);
        }
      }
    });
  }

  void _onNextPressed() async {
    if (_selectedOptions.isEmpty) {
      ProfileSetupHelpers.showValidationError(
        context,
        AppStrings.pleaseSelectAtLeastOneOption,
      );
      return;
    }

    final stepData = {
      'connectWith': _selectedOptions.join(","),
    };

    await ProfileSetupHelpers.saveStepAndNavigate(
      context: context,
      ref: ref,
      step: ProfileSetupStep.connectionOptions,
      stepData: stepData,
      nextRoute: AppRoutes.preferenceMetalPage,
      mounted: mounted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final metalProps = ref.watch(metalPropertiesProvider);
    final setupState = ref.watch(profileSetupViewModelProvider);

    if (metalProps.data == null || metalProps.data!.lookingFor == null) {
      return const BaseScreen(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BaseScreen(
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: AppStrings.connectionOption,
      authFlow: true,
      body: Column(
        children: [
          CreateProfileHeader2(
            path: Assets.images.heartLocks1.path,
            title: AppStrings.connectionOptionsTitle,
            subtitle: AppStrings.connectionOptionsSubtitle,
          ),
          Expanded(
            child: GridView.builder(
              padding:
                  const EdgeInsets.all(ProfileSetupConstants.horizontalPadding),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ProfileSetupConstants.gridCrossAxisCount,
                crossAxisSpacing: ProfileSetupConstants.gridSpacing,
                mainAxisSpacing: ProfileSetupConstants.gridSpacing,
                childAspectRatio:
                    ProfileSetupConstants.gridChildAspectRatioConnection,
              ),
              itemCount: metalProps.data!.lookingFor!.length,
              itemBuilder: (BuildContext context, int index) {
                final model = metalProps.data!.lookingFor![index];
                return ConnectionOptionsCard(
                  model: model,
                  onTap: () => _updateOption(model.title!),
                  selected: _selectedOptions.contains(model.title),
                );
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.all(ProfileSetupConstants.horizontalPadding),
            child: BaseButton(
              enabled: _selectedOptions.isNotEmpty && !setupState.isLoading,
              loading: setupState.isLoading,
              buttonText:
                  ProfileSetupHelpers.getButtonText(setupState.isLoading),
              onPressed: _onNextPressed,
            ),
          )
        ],
      ),
    );
  }
}
