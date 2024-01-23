import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/screen.size.dart';
import 'package:metal/features/authentication/domain/entries/choose.metal.card.model.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/authentication/presentation/profile.setting/passions.dart';
import 'package:metal/features/authentication/presentation/widget/create.profile.header2.dart';

import 'package:metal/widgets/button/buttons.dart';

import '../widget/choose.metal.card.dart';

class ChooseYourMetalPage extends ConsumerStatefulWidget {
  ChooseYourMetalPage({Key? key}) : super(key: key);
  static const name = 'ChooseYourMetal';
  static const route = '$name';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChooseYourMetalPageState();
}

class _ChooseYourMetalPageState extends ConsumerState<ChooseYourMetalPage> {
  String? _selectedMetal;

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        Header: 'Choose Your Metal',
        authFlow: true,
        body: SingleChildScrollView(
            child: Column(
          children: [
            CreateProfileHeader2(
                path: Assets.images.chooseMetal.path,
                title: "Choose one Metal that represents your values",
                subtitle: "You can only select one metal"),
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
                      childAspectRatio: 16 / 12,
                    ),
                    itemCount: metalList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final ChooseYourMetalModel model = metalList[index];
                      return ChooseMetalCard(
                        model: model,
                        onTap: () => updateMetal(model.Title),
                        selected: model.Title == _selectedMetal,
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: BaseButton(
                    buttonText: "Next 2/5",
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
      _selectedMetal = item;
    });
  }

  void _onNextPressed() {
    context.pushNamed(PassionsPage.name);
  }
}
