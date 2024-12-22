import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/core/utils/screen.size.dart';
import 'package:metal/features/refer.earn/provider/get.reffered.user.notifier.dart';
import 'package:metal/features/sparks_page/screens/widget/single.spark.header.card.dart';

import 'package:metal/gen/assets.gen.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';

import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/state.handler/error.state.dart';

import 'package:metal/widgets/text_views.dart';

class ReferEarn extends ConsumerWidget {
  const ReferEarn({super.key});
  static const name = 'referEarn';
  static const route = name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCount = ref.watch(getRefferedUserProvider);
    return BaseScreen(
        appBarState: AppBarState.BackWithHeader,
        Header: "Refer & Earn",
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        color: AppColors.metalPinkColour,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(35),
                          bottomRight: Radius.circular(35),
                        )),
                  ),

                  // This container is for the background image decoration
                  Container()
                ],
              ),
              userCount.isLoading
                  ? const Center(
                      child: CircularProgressIndicator.adaptive(),
                    )
                  : userCount.isError
                      ? ErrorState(
                          retry: () {
                            ref
                                .read(getRefferedUserProvider.notifier)
                                .getReffered();
                          },
                          text: userCount.errorMessage,
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            margin: const EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                                color: AppColors.metalWhite,
                                borderRadius: BorderRadius.circular(13)),
                            child: Column(
                              children: [
                                SingleSparkHeaderCard(
                                  title: "Refer \n& Earn",
                                  path: Assets.images.refer.path,
                                ),
                                const Gap(56),
                                const SizedBox(
                                  width: 218,
                                  child: TextView(
                                      textAlign: TextAlign.center,
                                      text:
                                          "You’re doing great! Your counts are increasing. Invite more friends to earn more sparks with Metal."),
                                ),
                                const Gap(29),
                                Container(
                                  width: 200,
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                      color: AppColors.metalTabBg,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Column(
                                    children: [
                                      TextView(
                                        text: "Referral count",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      Gap(8),
                                      TextView(
                                        text:
                                            userCount.data?.length.toString() ??
                                                "0",
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      )
                                    ],
                                  ),
                                ),
                                Gap(getDeviceHeight(context) * 0.1),
                                BaseButton(
                                  buttonText: "Refer friends",
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.referEarnSpark);
                                  },
                                ),
                              ],
                            ),
                          ))
            ],
          ),
        ));
  }
}
