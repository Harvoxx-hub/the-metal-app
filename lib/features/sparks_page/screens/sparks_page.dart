import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/sparks_page/provider/get.spark.notifier.dart';
import 'package:metal/features/sparks_page/provider/reconcile.sparks.notifier.dart';

import 'package:metal/features/sparks_page/screens/widget/spark.header.card.dart';
import 'package:metal/features/sparks_page/screens/widget/spark.history.item.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/widgets/state.handler/error.state.dart';

import 'package:metal/widgets/text_views.dart';

import '../../../res/colors/cr_colors.dart';

class SparksPage extends ConsumerWidget {
  const SparksPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sparks = ref.watch(getSparkProvider);
    final userData = ref.watch(authProvider).data;
    final reconcileState = ref.watch(reconcileSparkProvider);

    ref.listen(reconcileSparkProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.data?['message'] ??
                'Spark balance reconciled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh spark history after reconciliation
        ref.read(getSparkProvider.notifier).getSpark();
      } else if (next.isError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(next.errorMessage ?? 'Failed to reconcile spark balance'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

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
                      child: Row(
                        children: [
                          const TextView(
                            text: "Transaction History",
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          const Spacer(),
                          // Reconcile button
                          GestureDetector(
                            onTap: () {
                              if (!reconcileState.isLoading) {
                                ref
                                    .read(reconcileSparkProvider.notifier)
                                    .reconcileSparkBalance();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color:
                                    AppColors.metalPinkColour.withOpacity(0.2),
                              ),
                              child: Row(
                                children: [
                                  if (reconcileState.isLoading)
                                    SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.metalPinkColour,
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.refresh,
                                      size: 14,
                                      color: AppColors.metalPinkColour,
                                    ),
                                  const Gap(5),
                                  TextView(
                                    text: reconcileState.isLoading
                                        ? "Checking..."
                                        : "Reconcile",
                                    fontSize: 12,
                                    color: AppColors.metalPinkColour,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(9),
                    sparks.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : sparks.isError
                            ? ErrorState(
                                retry: () {
                                  ref
                                      .read(getSparkProvider.notifier)
                                      .getSpark();
                                },
                                text: sparks.errorMessage,
                              )
                            : sparks.data?.isEmpty ?? true
                                ? const EmptyState(
                                    text: "You have no transaction history yet",
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: sparks.data!.length,
                                    itemBuilder: (context, index) {
                                      return SparkHistoryItem(
                                        sparkModel: sparks.data![index],
                                        userID: userData!.id!,
                                      );
                                    },
                                  ),
                    const Gap(20),
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
