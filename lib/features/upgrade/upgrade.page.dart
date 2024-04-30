import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/upgrade/provider/metal.plan.notifier.dart';
import 'package:metal/features/upgrade/widget/subscription.card.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/upgrade/make.payment.dart';
import 'package:metal/widgets/text_views.dart';

class UpgradePage extends ConsumerWidget {
  UpgradePage({super.key});
  static const name = 'upgradePage';
  static const route = '$name';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metalPlanState = ref.watch(metalPlansProvider);
    return BaseScreen(
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        authFlow: true,
        Header: "Upgrade",
        body: metalPlanState.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Gap(16.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextView(
                          text:
                              "Select any upgrade plan to continue your verification",
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        Gap(5.h),
                        TextView(
                          text:
                              "You can always cancel your subscription at anytime",
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.italic,
                        ),
                      ],
                    ),
                    Gap(16.h),
                    for (var i = 0; i < (metalPlanState.data ?? []).length; i++)
                      subscriptionCard(
                        model: metalPlanState.data![i],
                      ),
                    Gap(16.h),
                  ],
                ),
              ));
  }
}
