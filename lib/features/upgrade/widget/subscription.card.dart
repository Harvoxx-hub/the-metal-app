import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import 'package:metal/features/upgrade/domain/entries/metal.plan.model.dart';
import 'package:metal/features/upgrade/make.payment.dart';
import 'package:metal/features/upgrade/provider/subscribe.metal.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/shimmer.loading.dart';
import 'package:metal/widgets/text_views.dart';

class subscriptionCard extends ConsumerWidget {
  subscriptionCard({
    super.key,
    required this.model,
  });

  final MetalPlanModel model;

  List<Gradient> gradient = [
    const LinearGradient(
      begin: Alignment(-0.69, -0.72),
      end: Alignment(0.69, 0.72),
      colors: [Color(0xFFE39AFC), Color(0xFFFFDAE0), Color(0xFFAFBFF9)],
    ),
    const LinearGradient(
        begin: Alignment(-0.69, -0.72),
        end: Alignment(0.69, 0.72),
        colors: [Color(0xFFFFAFB2), Color(0xFFFFDAE0), Color(0xFFFDA22F)]),
    const LinearGradient(
      begin: Alignment(-0.69, -0.72),
      end: Alignment(0.69, 0.72),
      colors: [Color(0xFFFF9ECC), Color(0xFFFFDAE0), Color(0xFF45C9EB)],
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subState = ref.watch(subscribeMetalProvider);
    ref.listen<SubscribeMetalState>(subscribeMetalProvider, (prev, current) {
      if (current.isSuccess) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(content: _upgreadeDialog(context));
          },
        );
      }
    });
    return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: ShimmerLoading(
          isLoading: subState.isLoading,
          child: Container(
            width: double.infinity,
            height: 172,
            padding: EdgeInsets.all(16),
            decoration: ShapeDecoration(
              gradient: pickRandomItem(gradient),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                )
              ],
            ),
            child: GestureDetector(
              onTap: () async {
                final paymentState = await Navigator.pushNamed(
                    context, AppRoutes.makePayment,
                    arguments: [PaymentType.metalPlan, model.price.toDouble()]);
                if (paymentState == PaymentState.success)
                  ref
                      .read(subscribeMetalProvider.notifier)
                      .subscribeMetalPlan(model.id!);
              },
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: model.planeName,
                      fontWeight: FontWeight.w400,
                      fontSize: 24,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var item in model.metaData)
                              TextView(text: "- $item")
                          ],
                        ),
                        const Gap(10),
                        Column(
                          children: [
                            TextView(
                              text: model.price.toString(),
                              fontWeight: FontWeight.w700,
                              fontSize: 23,
                            ),
                          ],
                        )
                      ],
                    )
                  ]),
            ),
          ),
        ));
  }

  T pickRandomItem<T>(List<T> items) {
    if (items.isEmpty) {
      throw Exception('List is empty');
    }

    Random random = Random();
    int index = random.nextInt(items.length);

    return items[index];
  }

  Widget _upgreadeDialog(BuildContext context) {
    return Column(
      children: [
        Gap(38.h),
        SvgPicture.asset(
          Assets.icons.meltedMetalsSmileyXEyes.path,
          height: 45,
          width: 45,
        ),
        Gap(15.h),
        TextView(
          text: "Metal Plus Upgrade",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        Gap(15.h),
        TextView(
          text:
              "Woohoo! You have successfully upgraded to Metal Plus Monthly. Now you have:",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        Gap(15.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var item in model.metaData) TextView(text: "- $item")
          ],
        ),
        Gap(38.h),
        BaseButton(
            buttonText: "Go to dashboard",
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.dashboardPage);
            }),
        Gap(21.h),
      ],
    );
  }
}
