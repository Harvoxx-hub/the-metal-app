import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/widgets/card.with.shadow.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

class BlockedCard extends StatelessWidget {
  const BlockedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CardWithShadow(
        onTap: () {},
        height: 105,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const ProfilePhoto(size: 56, verfly: true),
            Gap(23),
            TextView(
              text: "Felix August_titanium",
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ],
        ));
  }
}
