import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart' as geo_coding;

import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

import 'package:metal/features/authentication/provider/update.profile.notifier.dart';
import 'package:metal/gen/assets.gen.dart';

import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:geolocator/geolocator.dart' as geo;

class LocationEnablePage extends ConsumerStatefulWidget {
  const LocationEnablePage({super.key});
  static const name = 'location';
  static const route = name;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LocationEnablePageState();
}

class _LocationEnablePageState extends ConsumerState<LocationEnablePage> {
  geo.Position? _currentPosition;
  @override
  Widget build(BuildContext context) {
    final updateProfile = ref.watch(updateProfileProvider);

    ref.listen<UpdateProfileState>(updateProfileProvider, (prev, current) {
      if (current.isSuccess) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.dashboardPage, (route) => false);
      }
    });
    return BaseScreen(
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        Header: 'Location',
        authFlow: true,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset(
              Assets.images.location.path,
            ),
            const Gap(41),
            const TextView(
              text: "You'll need to enable location in order to use Metal",
              fontWeight: FontWeight.w400,
              fontSize: 20,
            ),
            const Gap(10),
            const TextView(
              text:
                  "Your location would be used to show you potential metals near you",
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
            const Gap(70),
            BaseButton(
              loading: updateProfile.isLoading,
              buttonText: "Enable Location",
              onPressed: () {
                _onNextPressed(updateProfile.data);
              },
            ),
          ]),
        ));
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    geo.LocationPermission permission;

    serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await geo.Geolocator.openLocationSettings();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == geo.LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _onNextPressed(user) async {
    await _getCurrentPosition();
    if (_currentPosition != null) {
      final userData = ref.watch(updateProfileProvider).data;

      // Get address from coordinates
      List<geo_coding.Placemark> placemarks =
          await geo_coding.placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        geo_coding.Placemark place = placemarks[0];
        String address =
            "${place.locality}, ${place.country}"; // e.g. "Lagos, Nigeria"

        Location location = Location(
          lat: _currentPosition!.latitude,
          lng: _currentPosition!.longitude,
          address: address,
        );

        final updated = userData?.copyWith(
          location: location,
          profileUpdated: true,
        );

        ref.read(updateProfileProvider.notifier).updateUserData(updated!);
        updateProfile(updated);
      }
    }
  }

  void updateProfile(UserModel user) {
    ref.read(updateProfileProvider.notifier).sendUserUpdate(user);
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await geo.Geolocator.getCurrentPosition(
            desiredAccuracy: geo.LocationAccuracy.high)
        .then((geo.Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {});
  }
}
