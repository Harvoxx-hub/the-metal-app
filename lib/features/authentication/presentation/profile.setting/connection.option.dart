import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/screen.size.dart';
import 'package:metal/features/authentication/presentation/widget/create.profile.header2.dart';

import 'package:metal/features/authentication/provider/metal.properties.notifier.dart';
import 'package:metal/features/authentication/provider/profile_setup_manager.dart';

import 'package:metal/gen/assets.gen.dart';

import 'package:metal/features/authentication/presentation/widget/connection.options.card.dart';

import 'package:metal/route/routes.dart';

import 'package:metal/widgets/button/buttons.dart';

class ConnectionOptionsPage extends ConsumerStatefulWidget {
  const ConnectionOptionsPage({super.key});
  static const name = 'ConnectionOptionsPage';
  static const route = name;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ConnectionOptionsPageState();
}

class _ConnectionOptionsPageState extends ConsumerState<ConnectionOptionsPage> {
  final List _seletedOption = [];

  @override
  Widget build(BuildContext context) {
    final metalProps = ref.watch(metalPropertiesProvider);
    final setupState = ref.watch(profileSetupManagerProvider);

    return BaseScreen(
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: 'Connection option',
      authFlow: true,
      body: Column(
        children: [
          CreateProfileHeader2(
              path: Assets.images.heartLocks1.path,
              title: "What are you looking for in a person?",
              subtitle:
                  "**Please select up to two. You can always change your selection in settings"),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // You can adjust the number of columns here
                crossAxisSpacing: 10.0,

                mainAxisSpacing: 10.0,
                childAspectRatio: 12 / 10,
              ),
              itemCount: metalProps.data!.lookingFor!.length,
              itemBuilder: (BuildContext context, int index) {
                final model = metalProps.data!.lookingFor![index];
                return ConnectionOptionsCard(
                  model: model,
                  onTap: () => updateMetal(model.title!),
                  selected: _seletedOption.contains(model.title),
                );
              },
            ),
          ),
          BaseButton(
            enabled: _seletedOption.isNotEmpty && !setupState.isLoading,
            loading: setupState.isLoading,
            buttonText: setupState.isLoading ? "Saving..." : "Next",
            onPressed: _onNextPressed,
          )
        ],
      ),
    );
  }

  void updateMetal(String item) {
    setState(() {
      _seletedOption.contains(item)
          ? _seletedOption.remove(item)
          : _seletedOption.length < 2
              ? _seletedOption.add(item)
              : null;
    });
  }

  void _onNextPressed() async {
    if (_seletedOption.isEmpty) return;

    final connectionData = {
      'connectionOption': _seletedOption.cast<String>(),
    };

    await ref.read(profileSetupManagerProvider.notifier).saveStepData(
          step: ProfileSetupStep.connectionOptions,
          stepData: connectionData,
          moveToNext: true,
        );

    // Check if save was successful before navigating
    final setupState = ref.read(profileSetupManagerProvider);
    if (setupState.errorMessage == null && mounted) {
      Navigator.pushNamed(
        context,
        AppRoutes.preferenceMetalPage,
      );
    }
  }
}
