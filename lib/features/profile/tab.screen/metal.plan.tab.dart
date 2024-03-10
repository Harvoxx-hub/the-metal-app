import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/profile/widget/edit.field.dart';
import 'package:metal/features/upgrade/domain/entries/metal.plan.model.dart';
import 'package:metal/features/upgrade/domain/entries/subscribed.plan.model.dart';
import 'package:metal/features/upgrade/provider/metal.plan.notifier.dart';
import 'package:metal/features/upgrade/provider/subscribe.metal.notifier.dart';
import 'package:metal/features/upgrade/upgrade.page.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:pie_chart/pie_chart.dart';

class MetalPlanTab extends ConsumerStatefulWidget {
  const MetalPlanTab({super.key});

  @override
  ConsumerState<MetalPlanTab> createState() => _MetalPlanTabState();
}

class _MetalPlanTabState extends ConsumerState<MetalPlanTab> {
  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(authProvider);
    final metalPlans = ref.watch(metalPlansProvider);

    return userData.data?.subscription == null
        ? metalPlans.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _noSubscriptionContent(metalPlans: metalPlans.data!)
        : _subscriptionContent(
            subscribedPlanModel: userData.data!.subscription!);
  }
}

class _subscriptionContent extends StatelessWidget {
  const _subscriptionContent({
    super.key,
    required this.subscribedPlanModel,
  });

  final SubscribedPlanModel subscribedPlanModel;

  @override
  Widget build(BuildContext context) {
    final startingDate = DateTime.fromMicrosecondsSinceEpoch(
        subscribedPlanModel.startingDate * 1000);
    final endingDate = DateTime.fromMicrosecondsSinceEpoch(
        subscribedPlanModel.endingDate * 1000);
    Map<String, double> dataMap = {
      "Days Remaining": DateTime.now().difference(endingDate).inDays.toDouble(),
      "Days exhausted":
          DateTime.now().difference(startingDate).inDays.toDouble(),
    };
    return Column(
      children: [
        EditField(
          text:
              "${subscribedPlanModel.planName}  - *${subscribedPlanModel.price}.00/month*",
          onSubLabel: () {},
          floatingLabel: "Current plan",
          subLabel: "Upgrade",
        ),
        const Gap(46),
        TextView(
            textAlign: TextAlign.center,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            text:
                "Your current Metal plus plan will terminate on * ${getDateFromTimeStamp(endingDate)}"),
        const Gap(46),
        PieChart(
          dataMap: dataMap,
          animationDuration: const Duration(milliseconds: 800),
          chartLegendSpacing: 32,
          chartRadius: MediaQuery.of(context).size.width / 3.2,

          initialAngleInDegree: 270,
          chartType: ChartType.disc,
          ringStrokeWidth: 32,
          colorList: [Colors.green, Colors.grey.withOpacity(0.2)],

          legendOptions: const LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: const ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: false,
            showChartValuesOutside: false,
            decimalPlaces: 1,
          ),
          // gradientList: ---To add gradient colors---
          // emptyColorGradient: ---Empty Color gradient---
        ),
        const Gap(46),
        BaseButton(buttonText: "Extend Plan", onPressed: () {}),
        const Gap(38),
        TextView(
            textAlign: TextAlign.start,
            fontStyle: FontStyle.italic,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            text: "Buying more will extend from the date of expiration."),
      ],
    );
  }
}

class _noSubscriptionContent extends StatelessWidget {
  const _noSubscriptionContent({
    super.key,
    required this.metalPlans,
  });

  final List<MetalPlanModel> metalPlans;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          Assets.gifs.empty.path,
          height: 200,
          width: 200,
        ),
        const Gap(46),
        TextView(
          textAlign: TextAlign.center,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          text: "You don't have any active subscription",
        ),
        const Gap(46),
        BaseButton(
            buttonText: "Subscribe",
            onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.upgradePage,
                );
 
            
            }),
      ],
    );
  }
}

String getDateFromTimeStamp(date) {
  DateFormat formatter =
      DateFormat('d MMMM yyyy'); // Adjust the format as needed
  String formattedDate = formatter.format(date);

  return formattedDate;
}

int getDaysBetweenTimestamps(int timeStamp1, int timeStamp2) {
  // Convert timestamps to DateTime objects
  DateTime date1 = DateTime.fromMillisecondsSinceEpoch(timeStamp1);
  DateTime date2 = DateTime.fromMillisecondsSinceEpoch(timeStamp2);

  // Calculate the difference in days
  Duration difference = date2.difference(date1);

  // Return the difference in days
  return difference.inDays;
}
