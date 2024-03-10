import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/update.profile.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/dashboard.dart/dashboard.dart';
import 'package:metal/route/routes.dart';
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
    final _updateProfile = ref.watch(updateProfileProvider);

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
            loading: _updateProfile.isLoading,
            buttonText: "Notify Me",
            onPressed: () {
              _onNextPressed(_updateProfile.data!);
            },
          ),
        ]));
  }

  void _onNextPressed(UserModel user) {
    ref.read(updateProfileProvider.notifier).sendUserUpdate(user);
  }
}
