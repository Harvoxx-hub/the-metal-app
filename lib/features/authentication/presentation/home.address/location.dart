import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/authentication/presentation/home.address/notification.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';

class LocationEnablePage extends ConsumerStatefulWidget {
  LocationEnablePage({Key? key}) : super(key: key);
  static const name = 'location';
  static const route = '$name';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LocationEnablePageState();
}

class _LocationEnablePageState extends ConsumerState<LocationEnablePage> {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        Header: 'Location',
        authFlow: true,
        body: Center(
          child: Column(children: [
            Image.asset(
              Assets.images.location.path,
            ),
            Gap(41.h),
            TextView(
              text: "You’ll need to enable location in order to use Metal",
              fontWeight: FontWeight.w400,
              fontSize: 20,
            ),
            Gap(10.h),
            TextView(
              text:
                  "Your location would be used to show you potential metals near you",
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
            Gap(70.h),
            BaseButton(
              buttonText: "Enable Location",
              onPressed: () {
                context.pushNamed(NotificationEnablePage.name);
              },
            ),
          ]),
        ));
  }

  void _onNextPressed() {
    // widget.onNextPress();
  }
}
