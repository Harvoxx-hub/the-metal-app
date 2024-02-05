import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/features/authentication/domain/entries/metal.properties.model.dart';
import 'package:metal/features/upgrade/domain/entries/metal.plan.model.dart';
import 'package:metal/features/upgrade/make.payment.dart';
import 'package:metal/widgets/text_views.dart';

class subscriptionCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
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
          onTap: () {
            context.pushNamed(MakePayment.name, extra: model);
          },
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    for (var item in model.metaData) TextView(text: "- $item")
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
    );
  }

  T pickRandomItem<T>(List<T> items) {
    if (items.isEmpty) {
      throw Exception('List is empty');
    }

    Random random = Random();
    int index = random.nextInt(items.length);

    return items[index];
  }
}
