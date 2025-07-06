import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart' as geo_coding;

import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

import 'package:metal/features/authentication/provider/profile_setup_manager.dart';
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
    final setupState = ref.watch(profileSetupManagerProvider);

    return BaseScreen(
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: AppStrings.locationTitle,
      authFlow: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CreateProfileHeader2(
              path: Assets.images.location.path,
              title: AppStrings.enableLocationDesc,
              subtitle:
                  "Your location would be used to show you potential metals near you"),
          const Gap(100),
          BaseButton(
            loading: setupState.isLoading,
            buttonText: AppStrings.enableLocation,
            onPressed: () async {
              await _requestLocationPermission();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _requestLocationPermission() async {
    try {
      // First check if location services are enabled
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Location services are disabled. Please enable location services in Settings.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => geo.Geolocator.openLocationSettings(),
              ),
            ),
          );
        }
        return;
      }

      // Check current permission status
      geo.LocationPermission geoPermission =
          await geo.Geolocator.checkPermission();

      if (geoPermission == geo.LocationPermission.denied) {
        // Request permission
        geoPermission = await geo.Geolocator.requestPermission();

        if (geoPermission == geo.LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Location permission is required for better matching'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 4),
              ),
            );
          }
          return;
        }
      }

      if (geoPermission == geo.LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Location permission is permanently denied. Please enable it in Settings.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
        return;
      }

      // Permission granted, get location
      geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15), // Increased timeout
      );

      // Get address from coordinates
      List<geo_coding.Placemark> placemarks =
          await geo_coding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        geo_coding.Placemark place = placemarks[0];
        String address =
            "${place.locality ?? ''}, ${place.country ?? ''}".trim();

        if (address.startsWith(',')) {
          address = address.substring(1).trim();
        }

        Location location = Location(
          lat: position.latitude,
          lng: position.longitude,
          address: address,
        );

        // Save location data using profile setup manager
        final locationData = {
          'location': location.toJson(),
        };

        await ref.read(profileSetupManagerProvider.notifier).saveStepData(
              step: ProfileSetupStep.location,
              stepData: locationData,
              moveToNext: true,
            );

        if (mounted) {
          Navigator.pushNamed(context, AppRoutes.notificationEnablePage);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
