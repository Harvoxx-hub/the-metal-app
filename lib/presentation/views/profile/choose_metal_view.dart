import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/screen.size.dart';
import 'package:metal/core/utils/strings/app_strings.dart';
import 'package:metal/data/models/metal_properties_model.dart';
import 'package:metal/presentation/widgets/profile_setup_header.dart';
import 'package:metal/presentation/viewmodels/profile/metal_properties_provider.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/profile/profile_setup_viewmodel.dart';
import 'package:metal/presentation/views/profile/profile_setup_constants.dart';
import 'package:metal/presentation/views/profile/profile_setup_helpers.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/presentation/widgets/profile_setup_cards.dart';

/// Choose Metal View - Step 2 of profile setup
class ChooseMetalView extends ConsumerStatefulWidget {
  const ChooseMetalView({super.key});
  static const name = 'chooseMetal';
  static const route = '/$name';

  @override
  ConsumerState<ChooseMetalView> createState() => _ChooseMetalViewState();
}

class _ChooseMetalViewState extends ConsumerState<ChooseMetalView> {
  Metal? _selectedMetal;

  void _updateMetal(Metal item) {
    setState(() {
      _selectedMetal = item;
    });
  }

  void _onNextPressed() async {
    if (_selectedMetal == null) return;

    final metalData = {
      'metal': _selectedMetal!.id,
    };

    await ProfileSetupHelpers.saveStepAndNavigate(
      context: context,
      ref: ref,
      step: ProfileSetupStep.metalSelection,
      stepData: metalData,
      nextRoute: AppRoutes.passionsPage,
      mounted: mounted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final metalProps = ref.watch(metalPropertiesProvider);
    final setupState = ref.watch(profileSetupViewModelProvider);

    return BaseScreen(
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: AppStrings.chooseYourMetal,
      authFlow: true,
      body: metalProps.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  CreateProfileHeader2(
                    path: Assets.images.chooseMetal.path,
                    title: AppStrings.chooseMetalTitle,
                    subtitle: AppStrings.chooseMetalSubtitle,
                  ),
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: ProfileSetupConstants.buttonBottomPadding,
                        ),
                        child: SizedBox(
                          height: getDeviceHeight(context) *
                              ProfileSetupConstants.gridHeightRatio,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount =
                                  constraints.maxWidth < 600 ? 2 : 3;
                              return GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing:
                                      ProfileSetupConstants.gridSpacing,
                                  mainAxisSpacing:
                                      ProfileSetupConstants.gridSpacing,
                                  childAspectRatio: constraints.maxWidth < 600
                                      ? ProfileSetupConstants
                                          .gridChildAspectRatioMetal
                                      : 16 / 20,
                                ),
                                itemCount: metalProps.data?.metals?.length ?? 0,
                                itemBuilder: (BuildContext context, int index) {
                                  final Metal model =
                                      metalProps.data!.metals![index];
                                  return ChooseMetalCard(
                                    model: model,
                                    onTap: () => _updateMetal(model),
                                    selected: model == _selectedMetal,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: BaseButton(
                          buttonText: ProfileSetupHelpers.getButtonText(
                              setupState.isLoading),
                          enabled:
                              _selectedMetal != null && !setupState.isLoading,
                          onPressed: _onNextPressed,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
    );
  }
}
