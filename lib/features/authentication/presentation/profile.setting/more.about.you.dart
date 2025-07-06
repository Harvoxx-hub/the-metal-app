import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/input/validators/validators.dart';

import 'package:metal/features/authentication/presentation/widget/create.profile.header2.dart';
import 'package:metal/features/authentication/provider/profile_setup_manager.dart';

import 'package:metal/gen/assets.gen.dart';

import 'package:metal/route/routes.dart';

import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';

class MoreAboutYouPage extends ConsumerStatefulWidget {
  const MoreAboutYouPage({super.key});
  static const name = 'moreAboutYou';
  static const route = name;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MoreAboutYouPageState();
}

class _MoreAboutYouPageState extends ConsumerState<MoreAboutYouPage> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final TextEditingController _bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(profileSetupManagerProvider);

    return BaseScreen(
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        Header: 'More About You',
        authFlow: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              CreateProfileHeader2(
                  path: Assets.images.aboutYou.path,
                  title: "Tell us about yourself",
                  subtitle: "Write something about yourself"),
              const Gap(40),
              Form(
                  key: _form,
                  child: Column(
                    children: [
                      EditFormField(
                        floatingLabel: "Bio",
                        label: "Tell us about yourself",
                        controller: _bioController,
                        minLines: 4,
                        maxLines: 6,
                        validator: Validators.validateString(),
                        keyboardType: TextInputType.multiline,
                        radius: 10,
                      ),
                      const Gap(20),
                      BaseButton(
                        enabled: !setupState.isLoading,
                        loading: setupState.isLoading,
                        buttonText: "Next",
                        onPressed: _onNextPressed,
                      ),
                    ],
                  )),
            ],
          ),
        ));
  }

  void _onNextPressed() async {
    if (!_form.currentState!.validate()) return;

    final bioData = {
      'bio': _bioController.text.trim(),
    };

    await ref.read(profileSetupManagerProvider.notifier).saveStepData(
          step: ProfileSetupStep.moreAboutYou,
          stepData: bioData,
          moveToNext: true,
        );

    // Check if save was successful before navigating
    final setupState = ref.read(profileSetupManagerProvider);
    if (setupState.errorMessage == null && mounted) {
      Navigator.pushNamed(
        context,
        AppRoutes.connectionOptionsPage,
      );
    }
  }
}
