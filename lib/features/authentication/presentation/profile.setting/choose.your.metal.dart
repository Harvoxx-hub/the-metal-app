import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/screen.size.dart';

import 'package:metal/features/authentication/domain/entries/metal.properties.model.dart';
import 'package:metal/features/authentication/presentation/widget/create.profile.header2.dart';
import 'package:metal/features/authentication/provider/metal.properties.notifier.dart';
import 'package:metal/features/authentication/provider/update.profile.notifier.dart';

import 'package:metal/gen/assets.gen.dart';

import 'package:metal/route/routes.dart';

import 'package:metal/widgets/button/buttons.dart';

import '../widget/choose.metal.card.dart';

class ChooseYourMetalPage extends ConsumerStatefulWidget {
  const ChooseYourMetalPage({super.key});
  static const name = 'ChooseYourMetal';
  static const route = name;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChooseYourMetalPageState();
}

class _ChooseYourMetalPageState extends ConsumerState<ChooseYourMetalPage> {
  Metal? _selectedMetal;

  @override
  Widget build(BuildContext context) {
    final metalProps = ref.watch(metalPropertiesProvider);
    return BaseScreen(
        //   isLoading: metalProps.isLoading,
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        Header: 'Choose Your Metal',
        authFlow: true,
        body: metalProps.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                children: [
                  CreateProfileHeader2(
                      path: Assets.images.chooseMetal.path,
                      title: "Choose one Metal that represents your values",
                      subtitle: "You can only select one metal"),
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 60.0),
                        child: SizedBox(
                          height: getDeviceHeight(context) * 0.59,
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  2, // You can adjust the number of columns here
                              crossAxisSpacing: 10.0,

                              mainAxisSpacing: 10.0,
                              childAspectRatio: 16 / 14,
                            ),
                            itemCount: metalProps.data!.metals!.length,
                            itemBuilder: (BuildContext context, int index) {
                              final Metal model =
                                  metalProps.data!.metals![index];
                              return ChooseMetalCard(
                                model: model,
                                onTap: () => updateMetal(model),
                                selected: model == _selectedMetal,
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
                          buttonText: "Next",
                          enabled: _selectedMetal != null,
                          onPressed: _onNextPressed,
                        ),
                      )
                    ],
                  )
                ],
              )));
  }

  void updateMetal(Metal item) {
    setState(() {
      _selectedMetal = item;
    });
  }

  void _onNextPressed() {
    final userData = ref.watch(updateProfileProvider).data;
    userData!.metal = _selectedMetal;
    ref.read(updateProfileProvider.notifier).updateUserData(userData);

    Navigator.pushNamed(
      context,
      AppRoutes.locationEnablePage,
    );
  }
}
