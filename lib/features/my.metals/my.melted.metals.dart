import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/my.metals/widget/melt.card.dart';

import 'package:metal/widgets/profile.photo.dart';

class MyMeltedMetals extends StatelessWidget {
  const MyMeltedMetals({super.key});
  static const name = 'meltedPage';
  static const route = '$name';

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        subAppBar: true,
        appBarState: AppBarState.HambugerWithHeader,
        Header: "My melted metals",
        body: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                Assets.images.heartLocks1.path,
                height: 138,
                width: 138,
              ),
              MeltCard(),
              MeltCard(),
              MeltCard(),
              MeltCard(),
              MeltCard(),
              MeltCard(),
              MeltCard(),
              MeltCard(),
            ],
          ),
        ));
  }
}
