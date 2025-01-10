import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';

class TutoralDialog extends StatelessWidget {
  const TutoralDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Gap(38),
        Assets.images.rocketEmoji1.image(height: 54, width: 54),
        const Gap(15),
        const TextView(
          text: "Let’s get you ready!",
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        const Gap(15),
        const TextView(
          text:
              "Here is everything you need to know about Metal to get started quickly. Let the arrows guide you!",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(38),
        BaseButton(
            buttonText: "Start Tutorial",
            onPressed: () async {
              // await Navigator.pushNamed(
              //   context,
              //   AppRoutes.passionsPage,
              // );
              //   Navigator.pop(context);
            }),
        const Gap(23),
        TextView(
          text: "Skip for Now",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          onTap: () => Navigator.pop(context),
        ),
        const Gap(21),
      ],
    );
  }
}
