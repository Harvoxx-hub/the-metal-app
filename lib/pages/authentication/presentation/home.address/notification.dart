import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/pages/dashboard.dart/dashboard.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';

class NotificationEnablePage extends ConsumerStatefulWidget {
  NotificationEnablePage({Key? key}) : super(key: key);
  static const name = 'NotificationEnablePage';
  static const route = '$name';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificationEnablePageState();
}

class _NotificationEnablePageState
    extends ConsumerState<NotificationEnablePage> {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        Header: 'Notifcations',
        authFlow: true,
        body: Center(
          child: Column(children: [
            Image.asset(
              Assets.images.notification.path,
            ),
            Gap(41.h),
            TextView(
              text: "Keep me informed!",
              fontWeight: FontWeight.w400,
              fontSize: 20,
            ),
            Gap(10.h),
            TextView(
              text: "Quickly find out when you have a Metal Match or message",
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
            Gap(70.h),
            BaseButton(
              buttonText: "Notify Me",
              onPressed: () {
                context.pushNamed(DashboardPage.name);
              },
            ),
          ]),
        ));
  }

  void _onNextPressed() {
    // widget.onNextPress();
  }
}
