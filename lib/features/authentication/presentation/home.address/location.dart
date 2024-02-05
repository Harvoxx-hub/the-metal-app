import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/update.profile.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/authentication/presentation/home.address/notification.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:geolocator/geolocator.dart';

class LocationEnablePage extends ConsumerStatefulWidget {
  LocationEnablePage({Key? key}) : super(key: key);
  static const name = 'location';
  static const route = '$name';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LocationEnablePageState();
}

class _LocationEnablePageState extends ConsumerState<LocationEnablePage> {
  Position? _currentPosition;
  @override
  Widget build(BuildContext context) {
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
                _onNextPressed();
                // context.pushNamed(NotificationEnablePage.name);
              },
            ),
          ]),
        ));
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _onNextPressed() async {
    await _getCurrentPosition();
    if (_currentPosition != null) {
      final userData = ref.watch(updateProfileProvider).data;
      userData!.location = Location(
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
      );
      ref.read(updateProfileProvider.notifier).updateUserData(userData);
      context.pushNamed(NotificationEnablePage.name);
    }
    // context.pushNamed(NotificationEnablePage.name);
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
  }
}
