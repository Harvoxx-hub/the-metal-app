import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/screen.size.dart';
import 'package:metal/features/authentication/domain/entries/connection.options.card.dart';
import 'package:metal/features/authentication/provider/metal.properties.notifier.dart';
import 'package:metal/features/authentication/provider/update.profile.notifier.dart';
import 'package:metal/gen/assets.gen.dart';

import 'package:metal/features/authentication/presentation/profile.setting/preference.metal.dart';
import 'package:metal/features/authentication/presentation/widget/connection.options.card.dart';
import 'package:metal/features/authentication/presentation/widget/create.profile.header2.dart';

import 'package:metal/widgets/button/buttons.dart';

class ConnectionOptionsPage extends ConsumerStatefulWidget {
  ConnectionOptionsPage({Key? key}) : super(key: key);
  static const name = 'ConnectionOptionsPage';
  static const route = '$name';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ConnectionOptionsPageState();
}

class _ConnectionOptionsPageState extends ConsumerState<ConnectionOptionsPage> {
  List _seletedOption = [];

  @override
  Widget build(BuildContext context) {
    final _metalProps = ref.watch(metalPropertiesProvider);
    return BaseScreen(
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        Header: 'Connection option',
        authFlow: true,
        body: SingleChildScrollView(
            child: Column(
          children: [
            CreateProfileHeader2(
                path: Assets.images.heartLocks1.path,
                title: "What are you looking for in a person?",
                subtitle:
                    "**Please select up to two. You can always change your selection in settings"),
            Stack(
              children: [
                Container(
                  height: getDeviceHeight(context) * 0.59,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          2, // You can adjust the number of columns here
                      crossAxisSpacing: 10.0,

                      mainAxisSpacing: 10.0,
                      childAspectRatio: 16 / 10,
                    ),
                    itemCount: _metalProps.data!.lookingFor!.length,
                    itemBuilder: (BuildContext context, int index) {
                      final model = _metalProps.data!.lookingFor![index];
                      return ConnectionOptionsCard(
                        model: model,
                        onTap: () => updateMetal(model.title!),
                        selected: _seletedOption.contains(model.title),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: BaseButton(
                    enabled: _seletedOption.length >= 2,
                    buttonText: "Next ",
                    onPressed: _onNextPressed,
                  ),
                )
              ],
            )
          ],
        )));
  }

  void updateMetal(String item) {
    setState(() {
      _seletedOption.contains(item)
          ? _seletedOption.remove(item)
          : _seletedOption.add(item);
    });
  }

  void _onNextPressed() {
    final userData = ref.watch(updateProfileProvider).data;

    userData!.connection_option = _seletedOption.cast<String>();
    ref.read(updateProfileProvider.notifier).updateUserData(userData);
    context.pushNamed(PreferenceMetalPage.name);
  }
}
