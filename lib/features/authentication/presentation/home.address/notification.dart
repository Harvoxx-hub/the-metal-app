import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
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
    final userState = ref.watch(userStateProvider);

    return BaseScreen(
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        Header: 'Notifications',
        authFlow: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              CreateProfileHeader2(
                  path: Assets.images.notification.path,
                  title: "Stay connected with notifications",
                  subtitle: "Get notified about new matches and messages"),
              const Gap(26),
              BaseButton(
                loading: userState.isLoading,
                buttonText: "Enable Notifications",
                onPressed: () async {
                  await _requestNotificationPermission();
                },
              ),
              const Gap(16),
              BaseButton(
                outlined: true,
                buttonText: "Skip for now",
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.dashboardPage, (route) => false);
                },
              ),
              const Gap(80),
              _buildNotificationFeatures(),
            ],
          ),
        ));
  }

  Future<void> _requestNotificationPermission() async {
    try {
      // Update user notification permission status
      await ref.read(userStateProvider.notifier).updateUserField(
            field: 'notificationPermissionGranted',
            value: true,
          );

      // Complete profile setup
      await ref.read(userStateProvider.notifier).updateUserField(
            field: 'profileUpdated',
            value: true,
          );

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.dashboardPage, (route) => false);
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

  Widget _buildNotificationFeatures() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.metalWhite.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notifications help you:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.metalWhite,
            ),
          ),
          const Gap(12),
          _buildFeatureItem('💕', 'Get notified about new matches'),
          _buildFeatureItem('💬', 'Receive message alerts'),
          _buildFeatureItem('⚡', 'See when someone likes you'),
          _buildFeatureItem('🎉', 'Stay updated on app features'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const Gap(8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.metalWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
