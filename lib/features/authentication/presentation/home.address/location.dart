import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart' as geo_coding;

import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/gen/assets.gen.dart';

import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:metal/core/utils/permission_helper.dart';
import 'package:metal/core/utils/strings/app_strings.dart';
import 'package:metal/features/authentication/presentation/widget/create.profile.header2.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationEnablePage extends ConsumerStatefulWidget {
  const LocationEnablePage({super.key});
  static const name = 'locationEnable';
  static const route = name;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LocationEnablePageState();
}

class _LocationEnablePageState extends ConsumerState<LocationEnablePage> {
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userStateProvider);

    return BaseScreen(
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        Header: AppStrings.enableLocationTitle,
        authFlow: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              CreateProfileHeader2(
                  path: Assets.images.location.path,
                  title: AppStrings.enableLocationDesc,
                  subtitle:
                      "Your location helps us match you with nearby people"),
              const Gap(26),
              BaseButton(
                loading: userState.isLoading,
                buttonText: AppStrings.enableLocation,
                onPressed: () async {
                  await _requestLocationPermission();
                },
              ),
              const Gap(16),
              BaseButton(
                outlined: true,
                buttonText: AppStrings.skipForNow,
                onPressed: () {
                  Navigator.pushNamed(
                      context, AppRoutes.notificationEnablePage);
                },
              ),
              const Gap(80),
              _buildFeaturesList(),
            ],
          ),
        ));
  }

  Future<void> _requestLocationPermission() async {
    try {
      final permissionStatus = await Permission.location.request();

      if (permissionStatus.isGranted) {
        // Update user location permission status
        await ref.read(userStateProvider.notifier).updateUserField(
              field: 'locationPermissionGranted',
              value: true,
            );

        if (mounted) {
          Navigator.pushNamed(context, AppRoutes.notificationEnablePage);
        }
      } else if (permissionStatus.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Location permission permanently denied. Please enable it in Settings.'),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
      } else {
        // Show error or handle permission denied
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Location permission is required for better matching'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error requesting location permission: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildFeaturesList() {
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
            'Location helps us:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.metalWhite,
            ),
          ),
          const Gap(12),
          _buildFeatureItem('🎯', 'Match you with nearby people'),
          _buildFeatureItem('📍', 'Show distance in profiles'),
          _buildFeatureItem('🔒', 'Keep your exact location private'),
          _buildFeatureItem('⚡', 'Find local events and activities'),
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
