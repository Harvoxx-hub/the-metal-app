import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/provider/profile_setup_manager.dart';
import 'package:metal/features/authentication/presentation/widget/create.profile.header2.dart';

import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/res/colors/cr_colors.dart';

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
    final setupState = ref.watch(profileSetupManagerProvider);

     
    return BaseScreen(
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: 'Notifications',
      authFlow: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CreateProfileHeader2(
              path: Assets.images.notification.path,
              title: "Keep me informed!",
              subtitle:
                  "Quickly find out when you have a Metal Match or message"),
          const Gap(100),
          BaseButton(
            loading: setupState.isLoading,
            buttonText: "Enable Notifications",
            onPressed: () async {
              await _requestNotificationPermission();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _requestNotificationPermission() async {
    try {
      // Save notification preferences and complete profile
      final notificationData = {
        'notificationPermissionGranted': true,
      };

      // Save notification step data
      await ref.read(profileSetupManagerProvider.notifier).saveStepData(
            step: ProfileSetupStep.notifications,
            stepData: notificationData,
            moveToNext: false,
          );

      // Complete the entire profile setup
      await ref
          .read(profileSetupManagerProvider.notifier)
          .completeProfileSetup();
    final setupState = ref.watch(profileSetupManagerProvider);
    if(mounted && setupState.errorMessage == null){
     // Navigate to dashboard after profile completion
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboardPage,
          (route) => false,
        );
    }     
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error enabling notifications: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
