import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:gap/gap.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/features/sparks_page/screens/widget/spark.card.item.dart';
import 'package:metal/gen/assets.gen.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/text_views.dart';

class SparkHeaderCard extends ConsumerWidget {
  const SparkHeaderCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userStateProvider);
    return Container(
      height: 229,
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
          color: AppColors.metalPinkColour,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow()]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextView(
            text: "Sparks Balance ✨",
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.metalWhite,
          ),
          TextView(
            text: userData.data!.sparkBalance.toString(),
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: AppColors.metalWhite,
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SparkCardItem(
                  title: "Send Sparks",
                  path: Assets.images.sendSpark.path,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.sendSpark)),
              // SparkCardItem(
              //     title: "Buy Sparks",
              //     onTap: () =>  Navigator.pushNamed(context, AppRoutes.buySpark),

              //     path: Assets.images.buySpark.path),
              SparkCardItem(
                  title: "Refer & Earn",
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.referEarnSpark),
                  path: Assets.images.refer.path),
            ],
          )
        ],
      ),
    );
  }
}
