import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';

import 'package:metal/features/upgrade/domain/entries/metal.plan.model.dart';
import 'package:metal/features/upgrade/payment.core.dart';
import 'package:metal/features/upgrade/provider/subscribe.metal.notifier.dart';
import 'package:metal/features/upgrade/widget/paywall.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/shimmer.loading.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';
import 'package:purchases_flutter/models/offering_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class subscriptionCard extends ConsumerWidget {
  subscriptionCard({
    super.key,
    required this.model,
  });

  final MetalPlanModel model;
  //  final Offering offering;

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

  void perfomMagic(context) async {
    // setState(() {
    //   _isLoading = true;
    // });

    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    print(customerInfo.toString());
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        // Display packages for sale
        print(offerings.toString());
      }
    } on PlatformException catch (e) {
      print(e.message);
      // optional error handling
    }
    // if (customerInfo.entitlements.all["Metal Plus Monthly"] != null &&
    //     customerInfo.entitlements.all["Metal Plus Monthly"]?.isActive == true) {
    //   print("Have sub");
    //   // appData.currentData = WeatherData.generateData();

    //   // setState(() {
    //   //   _isLoading = false;
    //   // });
    // } else {
    //   Offerings? offerings;
    //   try {
    //     offerings = await Purchases.getOfferings();
    //   } on PlatformException catch (e) {
    //     print(e.message);
    //   }

    //   if (offerings == null || offerings.current == null) {
    //     // offerings are empty, show a message to your user
    //   } else {
    //     // current offering is available, show paywall
    //     await showModalBottomSheet(
    //       useRootNavigator: true,
    //       isDismissible: true,
    //       isScrollControlled: true,
    //       backgroundColor: Colors.amber,
    //       shape: const RoundedRectangleBorder(
    //         borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    //       ),
    //       context: context,
    //       builder: (BuildContext context) {
    //         return StatefulBuilder(
    //             builder: (BuildContext context, StateSetter setModalState) {
    //           return Paywall(
    //             offering: offerings!.current!,
    //           );
    //         });
    //       },
    //     );
    //   }
    // }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subState = ref.watch(subscribeMetalProvider);
    final userData = ref.watch(authProvider).data;
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
            height: 180,
            padding: const EdgeInsets.all(16),
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
                // StripePaymentHandle().stripeMakePayment(
                //   context: context,
                //     amount: model.price.toString(),
                //     userModel: userData!,
                //     onSuccess: () {
                //       ref
                //           .read(subscribeMetalProvider.notifier)
                //           .subscribeMetalPlan(model.id!);
                //     });
                perfomMagic(context);
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
                        const Spacer(),
                        Column(
                          children: [
                            TextView(
                              text: "${model.price.toString()} USD",
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
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
        const Gap(38),
        SvgPicture.asset(
          Assets.icons.meltedMetalsSmileyXEyes.path,
          height: 45,
          width: 45,
        ),
        const Gap(15),
        const TextView(
          text: "Metal Plus Upgrade",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        const Gap(15),
        const TextView(
          text:
              "Woohoo! You have successfully upgraded to Metal Plus Monthly. Now you have:",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var item in model.metaData) TextView(text: "- $item")
          ],
        ),
        const Gap(38),
        BaseButton(
            buttonText: "Go to dashboard",
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.dashboardPage);
            }),
        const Gap(21),
      ],
    );
  }
}
