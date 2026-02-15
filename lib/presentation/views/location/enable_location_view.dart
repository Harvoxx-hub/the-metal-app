import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/services/location_service.dart';
import 'package:metal/core/utils/permission_helper.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/presentation/views/home/widgets/location_permission_screen.dart';

/// Central location screen: request permission, get location, update user profile (storage).
/// Used when discovery (or any feature) needs location but user model has none.
/// Location is only requested and updated here and at splash; discovery uses stored user model.
class EnableLocationView extends ConsumerStatefulWidget {
  const EnableLocationView({super.key});

  static const routeName = '/enableLocation';

  @override
  ConsumerState<EnableLocationView> createState() => _EnableLocationViewState();
}

class _EnableLocationViewState extends ConsumerState<EnableLocationView> {
  bool _permanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
  }

  Future<void> _checkPermissionStatus() async {
    final denied = await PermissionHelper.isLocationPermanentlyDenied();
    if (mounted) setState(() => _permanentlyDenied = denied);
  }

  /// Get device location and update user profile (storage). Call after permission is granted.
  Future<void> _getLocationAndUpdateProfile() async {
    final locResult = await LocationService().getCurrentLocation();
    if (!mounted) return;
    if (locResult.isSuccess && locResult.location != null) {
      await ref.read(userStateProvider.notifier).updateUserField(
            field: 'location',
            value: locResult.location!.toJson(),
          );
    }
  }

  /// User tapped "Enable Location" — request permission then get location and update profile.
  Future<void> _onEnablePressed() async {
    final result = await PermissionHelper.requestLocationPermission();
    if (!mounted) return;
    if (!result.granted) {
      setState(() => _permanentlyDenied = result.permanentlyDenied);
      return;
    }
    await _getLocationAndUpdateProfile();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  /// Called when permission is granted (e.g. after returning from Settings).
  Future<void> _onLocationGranted() async {
    await _getLocationAndUpdateProfile();
  }

  @override
  Widget build(BuildContext context) {
    return LocationPermissionScreen(
      isPermanentlyDenied: _permanentlyDenied,
      onEnablePressed: _permanentlyDenied ? null : _onEnablePressed,
      onLocationGranted: () async {
        await _onLocationGranted();
      },
    );
  }
}
