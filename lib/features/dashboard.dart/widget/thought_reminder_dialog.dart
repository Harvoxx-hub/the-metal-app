import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';

class ThoughtReminderDialog extends StatelessWidget {
  const ThoughtReminderDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Gap(38),
        Assets.images.meltProfile.image(),
        const Gap(15),
        const TextView(
          text: "Share Your First Thought!",
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        const Gap(15),
        const TextView(
          text:
              "Start your journey by sharing a thought - it's the best way to connect with other metals and find your perfect match!",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(38),
        BaseButton(
            buttonText: "Post a Thought",
            onPressed: () async {
              Navigator.pop(context);
              await Navigator.pushNamed(
                context,
                AppRoutes.postThought,
              );
            }),
        const Gap(23),
        TextView(
          text: "Maybe Later",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          onTap: () => Navigator.pop(context),
        ),
        const Gap(21),
      ],
    );
  }
}
