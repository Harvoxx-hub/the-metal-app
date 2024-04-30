import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';

class ComplecteProfileDialog extends StatelessWidget {
  const ComplecteProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        Gap(38.h),
        Assets.images.meltProfile.image(),
        Gap(15.h),
        TextView(
          text: "Complecte Profile Setup",
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        Gap(15.h),
        TextView(
          text:
              "Complete your profile and let your personality shine! Show other users who you are and let the melting begin! 🔥 Your complete profile is the key to connecting with others and sparking meaningful conversations. Don't miss out on the fun, complete your profile now!",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        Gap(38.h),
        BaseButton(
            buttonText: "Complete your profile",
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                AppRoutes.passionsPage,
              );
              Navigator.pop(context);
            }),
        Gap(23.h),
        TextView(
          text: "Skip for Now",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          onTap: () => Navigator.pop(context),
        ),
        Gap(21.h),
      ],
    );
  }

  }
