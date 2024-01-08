import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/upgrade/make.payment.dart';
import 'package:metal/widgets/text_views.dart';

class UpgradePage extends StatelessWidget {
  UpgradePage({super.key});
  static const name = 'upgradePage';
  static const route = '$name';

  List plusMonthly = [
    "1 Month of subscription",
    "Ad-Free for a month",
    "See who read your messages",
    "See previous profile feeds",
    "See profiles you liked/pushed",
    "Send voice note to metals"
  ];
  List plusTriMonthly = [
    "3 months of subscription",
    "Ad-Free for 3 months",
    "See who read your messages",
    "See previous profile feeds",
    "See profiles you liked/pushed",
    "Send voice note to metals"
  ];
  List plusAnnually = [
    "12 months of subscription",
    "Ad-Free for a year",
    "See who read your messages",
    "See previous profile feeds",
    "See profiles you liked/pushed",
    "Send voice note to metals"
  ];
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        authFlow: true,
        Header: "Upgrade",
        body: Column(
          children: [
            Gap(16.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                  text: "Select any upgrade plan to continue your verification",
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w400,
                ),
                Gap(5.h),
                TextView(
                  text: "You can always cancel your subscription at anytime",
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.italic,
                ),
              ],
            ),
            Gap(16.h),
            upgradeCard1(
                context: context,
                linearGradient: const LinearGradient(
                  begin: Alignment(-0.69, -0.72),
                  end: Alignment(0.69, 0.72),
                  colors: [
                    Color(0xFFFF9ECC),
                    Color(0xFFFFDAE0),
                    Color(0xFF45C9EB)
                  ],
                ),
                title: "Metal Plus Monthly",
                list: plusMonthly,
                price: "5.00"),
            Gap(16.h),
            upgradeCard1(
                context: context,
                linearGradient: LinearGradient(
                  begin: Alignment(-0.69, -0.72),
                  end: Alignment(0.69, 0.72),
                  colors: [
                    Color(0xFFE39AFC),
                    Color(0xFFFFDAE0),
                    Color(0xFFAFBFF9)
                  ],
                ),
                title: "Metal Plus Tri-Monthly",
                list: plusTriMonthly,
                price: "15.00"),
            Gap(16.h),
            upgradeCard1(
                context: context,
                linearGradient: const LinearGradient(
                    begin: Alignment(-0.69, -0.72),
                    end: Alignment(0.69, 0.72),
                    colors: [
                      Color(0xFFFFAFB2),
                      Color(0xFFFFDAE0),
                      Color(0xFFFDA22F)
                    ]),
                title: "Metal Plus Annually",
                list: plusAnnually,
                price: "25.00"),
            Gap(16.h),
          ],
        ));
  }

  Container upgradeCard1(
      {linearGradient, title, list, price, required BuildContext context}) {
    return Container(
      width: double.infinity,
      height: 172,
      padding: EdgeInsets.all(16.h),
      decoration: ShapeDecoration(
        gradient: linearGradient,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadows: [
          const BoxShadow(
            color: Color(0x26000000),
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
          )
        ],
      ),
      child: GestureDetector(
        onTap: () {
          context.pushNamed(MakePayment.name);
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextView(
            text: title,
            fontWeight: FontWeight.w400,
            fontSize: 24,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [for (var item in list) TextView(text: "- $item")],
              ),
              const Gap(10),
              Column(
                children: [
                  TextView(
                    text: price,
                    fontWeight: FontWeight.w700,
                    fontSize: 23,
                  ),
                ],
              )
            ],
          )
        ]),
      ),
    );
  }
}
