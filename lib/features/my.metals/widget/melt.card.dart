import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/features/home_page/domain/entries/all.user.model.dart';
import 'package:metal/features/home_page/domain/entries/melt.user.model.dart';

import 'package:metal/features/my.metals/my.melted.user.dart';
import 'package:metal/widgets/card.with.shadow.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

class MeltCard extends StatelessWidget {
  MeltCard({super.key, required this.user});
  final MeltUserModel user;

  @override
  Widget build(BuildContext context) {
    return CardWithShadow(
        onTap: () {
          context.pushNamed(MyMeltedUser.name, extra: user.id);
        },
        height: 105,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProfilePhoto(size: 56, verfly: false, photourl: user.metal!.img!),
            Gap(23),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                  text: user!.name!,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                Gap(5),
                TextView(
                  text: "-  ${user!.gender}",
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                Gap(14),

                ///TODO: add the melted for marriage
                TextView(
                  text: "-  Melted for Marriage",
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ],
        ));
  }
}
