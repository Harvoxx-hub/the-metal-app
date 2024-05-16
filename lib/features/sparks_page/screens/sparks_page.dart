import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/sparks_page/provider/get.spark.notifier.dart';

import 'package:metal/features/sparks_page/screens/widget/spark.header.card.dart';
import 'package:metal/features/sparks_page/screens/widget/spark.history.item.dart';
import 'package:metal/gen/assets.gen.dart';

import 'package:metal/widgets/text_views.dart';

import '../../../res/colors/cr_colors.dart';

class SparksPage extends ConsumerWidget {
  const SparksPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sparks = ref.watch(getSparkProvider);
    return SingleChildScrollView(
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
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                margin: const EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                    color: AppColors.metalWhite,
                    borderRadius: BorderRadius.circular(13)),
                child: Column(
                  children: [
                    const SparkHeaderCard(),
                    const Gap(15),
                    Container(
                      decoration: ShapeDecoration(
                        color: AppColors.metalPinkColour.withOpacity(0.1),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(13),
                      child: const Row(
                        children: [
                          TextView(
                            text: "Transaction History",
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          Spacer(),
                          TextView(
                            text: "See all",
                            fontSize: 14,
                            color: AppColors.metalPinkColour,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                    const Gap(9),
                    sparks.isLoading
                        ? const CircularProgressIndicator()
                        : sparks.data?.isEmpty ?? true
                            ? Column(
                                children: [
                                  Image.asset(
                                    Assets.gifs.empty.path,
                                    height: 250,
                                    width: 250,
                                  ),
                                  const Gap(20),
                                  const TextView(
                                    textAlign: TextAlign.center,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    text: "You have no transaction history yet",
                                  ),
                                  const Gap(20),
                                  const TextView(
                                    textAlign: TextAlign.center,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                    text:
                                        "You can start by sending or receiving Sparks",
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  for (var item in sparks.data!)
                                    SparkHistoryItem(
                                      sparkModel: item,
                                    ),
                                ],
                              ),
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
