import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/home_page/domain/entries/melt.user.model.dart';
import 'package:metal/features/my.metals/melted.user.agurment.dart';

import 'package:metal/route/routes.dart';
import 'package:metal/widgets/card.with.shadow.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

class MeltCard extends StatelessWidget {
  const MeltCard({super.key, required this.user});
  final MeltUserModel user;

  @override
  Widget build(BuildContext context) {
    
    return CardWithShadow(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.myMeltedUser,
              arguments: MeltedUserAgurment(
                                userId: user.id!,
                                melted: true,
                                conversationID: user.conversationId!
                              ));
        },
        height: 105,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProfilePhoto(size: 56, verfly: false, photourl: user.metal!.img!),
            const Gap(23),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                  text: user.username!,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                const Gap(5),
                TextView(
                  text: "-  ${user.gender}",
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                const Gap(14),

                ///TODO: add the melted for marriage
                  TextView(
                  text: "- ${user.metal!.title}",
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ],
        ));
  }
}
