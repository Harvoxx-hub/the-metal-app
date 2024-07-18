import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/provider/update.profile.notifier.dart';
 
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';

class NotificationEnablePage extends ConsumerStatefulWidget {
  const NotificationEnablePage({super.key});
  static const name = 'NotificationEnablePage';
  static const route = name;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificationEnablePageState();
}

class _NotificationEnablePageState
    extends ConsumerState<NotificationEnablePage> {
  @override
  Widget build(BuildContext context) {
    final updateProfile = ref.watch(updateProfileProvider);

    ref.listen<UpdateProfileState>(updateProfileProvider, (prev, current) {
      if (current.isSuccess) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboardPage);
      }
    });
    return BaseScreen(
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        Header: 'Notifcations',
        authFlow: true,
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            Assets.images.notification.path,
          ),
          const Gap(41),
          const TextView(
            text: "Keep me informed!",
            fontWeight: FontWeight.w400,
            fontSize: 20,
          ),
          const Gap(10),
          const TextView(
            text: "Quickly find out when you have a Metal Match or message",
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
          const Gap(70),
          BaseButton(
            loading: updateProfile.isLoading,
            buttonText: "Notify Me",
            onPressed: () {
              //    _onNextPressed(_updateProfile.data!);
            },
          ),
        ]));
  }
}
