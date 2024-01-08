import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/features/chat/widget/profile.image.dart';
import 'package:metal/features/my.metals/my.melted.user.dart';
import 'package:metal/widgets/card.with.shadow.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

class MeltCard extends StatelessWidget {
  const MeltCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CardWithShadow(
        onTap: () {
          context.pushNamed(MyMeltedUser.name);
        },
        height: 105,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProfilePhoto(size: 56, verfly: true),
            Gap(23),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                  text: "Felix August_titanium",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                Gap(5),
                TextView(
                  text: "-  Male",
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                Gap(14),
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
