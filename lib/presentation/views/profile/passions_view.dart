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
import 'package:metal/widgets/shimmer.loading.dart';
import 'package:metal/presentation/widgets/profile_setup_cards.dart';

/// Passions View - Step 3 of profile setup
class PassionsView extends ConsumerStatefulWidget {
  const PassionsView({super.key});
  static const name = 'passions';
  static const route = '/$name';

  @override
  ConsumerState<PassionsView> createState() => _PassionsViewState();
}

class _PassionsViewState extends ConsumerState<PassionsView> {
  final List<String> _selectedPassions = [];

  void _updatePassion(String passion) {
    setState(() {
      if (_selectedPassions.contains(passion)) {
        _selectedPassions.remove(passion);
      } else {
        _selectedPassions.add(passion);
      }
    });
  }

  void _onNextPressed() async {
    if (_selectedPassions.isEmpty) {
      ProfileSetupHelpers.showValidationError(
        context,
        AppStrings.pleaseSelectAtLeastOnePassion,
      );
      return;
    }

    final stepData = {
      'passion': _selectedPassions,
    };

    await ProfileSetupHelpers.saveStepAndNavigate(
      context: context,
      ref: ref,
      step: ProfileSetupStep.passions,
      stepData: stepData,
      nextRoute: AppRoutes.aboutYouPage,
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
      Header: AppStrings.passions,
      authFlow: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            CreateProfileHeader2(
              path: Assets.images.flame.path,
              title: AppStrings.passionsTitle,
              subtitle: AppStrings.passionsSubtitle,
            ),
            Stack(
              children: [
                ShimmerLoading(
                  isLoading: metalProps.isLoading,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: ProfileSetupConstants.buttonBottomPadding,
                    ),
                    child: SizedBox(
                      height: getDeviceHeight(context) *
                          ProfileSetupConstants.gridHeightRatio,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              ProfileSetupConstants.gridCrossAxisCount,
                          crossAxisSpacing: ProfileSetupConstants.gridSpacing,
                          mainAxisSpacing: ProfileSetupConstants.gridSpacing,
                          childAspectRatio:
                              ProfileSetupConstants.gridChildAspectRatio,
                        ),
                        itemCount: metalProps.data?.passions?.length ?? 0,
                        itemBuilder: (BuildContext context, int index) {
                          final model =
                              metalProps.data?.passions?[index] ?? Passion();
                          return PassionsCard(
                            model: model,
                            onTap: () => _updatePassion(model.title!),
                            selected: _selectedPassions.contains(model.title),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: BaseButton(
                    buttonText:
                        ProfileSetupHelpers.getButtonText(setupState.isLoading),
                    enabled:
                        _selectedPassions.isNotEmpty && !setupState.isLoading,
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
