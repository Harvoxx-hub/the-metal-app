import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/screen.size.dart';
import 'package:metal/features/authentication/domain/entries/connection.options.card.dart';
import 'package:metal/gen/assets.gen.dart';

import 'package:metal/features/authentication/presentation/profile.setting/preference.metal.dart';
import 'package:metal/features/authentication/presentation/widget/connection.options.card.dart';
import 'package:metal/features/authentication/presentation/widget/create.profile.header1.dart';
import 'package:metal/features/authentication/presentation/widget/create.profile.header2.dart';
import 'package:metal/res/colors/cr_colors.dart';

import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';

import '../../../../widgets/dropdown/metal.dropdown.dart';
import '../widget/passions.card.dart';

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
  List data = [
    ConnectionOptionsCardModel(
        title: "Marriage",
        subTitle: "Match with Metals that are interestedin walking the aisle"),
    ConnectionOptionsCardModel(
        title: "Mentorship",
        subTitle: "Match with Metals that can support your goal advancements"),
    ConnectionOptionsCardModel(
        title: "Casual Friendship",
        subTitle:
            "Match with Metal that are not interested in serious relationship "),
    ConnectionOptionsCardModel(
        title: "Romance",
        subTitle: "Match with Metal that wants a physical relationship"),
    ConnectionOptionsCardModel(
        title: "Listening ear ",
        subTitle: "Match with Metal to pour our your mind to"),
    ConnectionOptionsCardModel(
        title: "Companion",
        subTitle:
            " Match with metal looking for frienship. Someone to go to mivies, parks, shopping or simply hangout"),
    ConnectionOptionsCardModel(
        title: "Father Figure",
        subTitle:
            "Match with metal to gain motherly advise on family topics, attend family dinners, or show up on your special days"),
    ConnectionOptionsCardModel(
        title: "Daughter Figure",
        subTitle:
            "Match with metal to gain fatherly advise on family topics, attend family dinners, or show up on your special days"),
  ];
  @override
  Widget build(BuildContext context) {
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
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      final model = data[index];
                      return ConnectionOptionsCard(
                        model: model,
                        onTap: () => updateMetal(model.title),
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
    context.pushNamed(PreferenceMetalPage.name);
  }
}
