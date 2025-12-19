import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/spark/spark_viewmodel.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/presentation/views/spark/widgets/send_spark_dialog.dart';
import 'package:metal/presentation/views/spark/widgets/spark_transaction_tile.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/text_views.dart';

/// Spark View - displays spark balance and transaction history
class SparkView extends ConsumerWidget {
  const SparkView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sparkState = ref.watch(sparkViewModelProvider);
    final currentUser = ref.watch(currentUserProvider);

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
                  ),
                ),
              ),
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
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                children: [
                  _buildSparkHeader(context, ref, sparkState.balance),
                  const Gap(15),
                  _buildTransactionHistoryHeader(context, ref),
                  const Gap(9),
                  _buildTransactionList(context, ref, sparkState, currentUser?.id),
                  const Gap(20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSparkHeader(BuildContext context, WidgetRef ref, int balance) {
    return Container(
      height: 229,
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: AppColors.metalPinkColour,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow()],
      ),
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
            text: balance.toString(),
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: AppColors.metalWhite,
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionCard(
                context,
                title: "Send Sparks",
                imagePath: Assets.images.sendSpark.path,
                onTap: () => _showSendSparkDialog(context, ref),
              ),
              _buildActionCard(
                context,
                title: "Refer & Earn",
                imagePath: Assets.images.refer.path,
                onTap: () => Navigator.pushNamed(context, AppRoutes.referEarn),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 84,
        width: 158,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.metalWhite,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imagePath,
              height: 32,
              width: 32,
            ),
            const Spacer(),
            TextView(
              text: title,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistoryHeader(BuildContext context, WidgetRef ref) {
    return Container(
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
          GestureDetector(
            onTap: () {
              ref.read(sparkViewModelProvider.notifier).refreshSparks();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppColors.metalPinkColour.withOpacity(0.2),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.refresh,
                    size: 14,
                    color: AppColors.metalPinkColour,
                  ),
                  Gap(5),
                  TextView(
                    text: "Refresh",
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
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    WidgetRef ref,
    SparkState sparkState,
    String? currentUserId,
  ) {
    if (sparkState.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (sparkState.isError) {
      return ErrorState(
        retry: () {
          ref.read(sparkViewModelProvider.notifier).loadSparks();
        },
        text: sparkState.errorMessage,
      );
    }

    if (sparkState.transactions.isEmpty) {
      return const EmptyState(
        text: "You have no transaction history yet",
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sparkState.transactions.length,
      itemBuilder: (context, index) {
        return SparkTransactionTile(
          transaction: sparkState.transactions[index],
          currentUserId: currentUserId ?? '',
        );
      },
    );
  }

  void _showSendSparkDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const SendSparkDialog(),
    );
  }
}
