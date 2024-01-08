import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/pages/authentication/models/passion.card.model.dart';
import 'package:metal/features/authentication/presentation/profile.setting/about.you.dart';
import 'package:metal/features/authentication/presentation/widget/create.profile.header1.dart';
import 'package:metal/features/authentication/presentation/widget/create.profile.header2.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/core/utils/utils/screen.size.dart';
import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';

import '../../../../widgets/dropdown/metal.dropdown.dart';
import '../widget/passions.card.dart';

class PassionsPage extends ConsumerStatefulWidget {
  PassionsPage({Key? key}) : super(key: key);
  static const name = 'passions';
  static const route = '$name';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PassionsPageState();
}

class _PassionsPageState extends ConsumerState<PassionsPage> {
  List _seletedPassion = [];
  List data = [
    PassionCardModel(title: "Photography", path: Assets.icons.cameraPlus.path),
    PassionCardModel(title: "Shopping", path: Assets.icons.shoppingCart01.path),
    PassionCardModel(title: "Karaoke", path: Assets.icons.microphone01.path),
    PassionCardModel(title: "Painting", path: Assets.icons.brush01.path),
    PassionCardModel(title: "Games", path: Assets.icons.gamingPad01.path),
    PassionCardModel(title: "Writing", path: Assets.icons.edit04.path),
    PassionCardModel(title: "Advocacy", path: Assets.icons.scales01.path),
    PassionCardModel(title: "Swimming", path: Assets.icons.icon.path),
    PassionCardModel(title: "Architecture", path: Assets.icons.building07.path),
    PassionCardModel(title: "Traveling", path: Assets.icons.luggage03.path),
    PassionCardModel(title: "Reading", path: Assets.icons.bookOpen01.path),
    PassionCardModel(title: "Music", path: Assets.icons.musicNote01.path),
  ];
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        Header: 'Passions',
        authFlow: true,
        body: SingleChildScrollView(
            child: Column(
          children: [
            CreateProfileHeader2(
                path: Assets.images.flame.path,
                title: "Tell us your passions and what interest you most",
                subtitle: "We could add it your profile!"),
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
                      childAspectRatio: 16 / 6,
                    ),
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      final model = data[index];
                      return PassionsCard(
                        model: model,
                        onTap: () => updateMetal(model.title),
                        selected: _seletedPassion.contains(model.title),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: BaseButton(
                    buttonText: "Next 3/5",
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
      _seletedPassion.contains(item)
          ? _seletedPassion.remove(item)
          : _seletedPassion.add(item);
    });
  }

  void _onNextPressed() {
    context.pushNamed(AboutYouPage.name);
  }
}
