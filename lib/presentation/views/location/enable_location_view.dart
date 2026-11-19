import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/services/location_service.dart';
import 'package:metal/core/utils/permission_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/presentation/views/home/widgets/location_permission_screen.dart';
import 'package:metal/route/routes.dart';

/// Central location screen: request permission, get location, update user profile (storage).
/// Used when discovery (or any feature) needs location but user model has none.
/// When [fromSplash] is true, opening from splash (user denied there); on success go to dashboard/welcome instead of popping.
class EnableLocationView extends ConsumerStatefulWidget {
  const EnableLocationView({
    super.key,
    this.fromSplash = false,
    this.profileUpdated = false,
  });

  static const routeName = '/enableLocation';

  final bool fromSplash;
  final bool profileUpdated;

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

  void _navigateAfterSuccess() {
    if (!mounted) return;
    if (widget.fromSplash) {
      Navigator.of(context).pushReplacementNamed(
        widget.profileUpdated ? AppRoutes.dashboardPage : AppRoutes.welcomePage,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  /// User tapped "Enable Location" — request permission then get location and update profile.
  /// BUG-027: Only request if not already granted to avoid repeated permission prompts.
  Future<void> _onEnablePressed() async {
    final status = await PermissionHelper.getLocationPermissionStatus();
    if (status == PermissionStatus.granted || status == PermissionStatus.limited) {
      await _getLocationAndUpdateProfile();
      _navigateAfterSuccess();
      return;
    }
    final result = await PermissionHelper.requestLocationPermission();
    if (!mounted) return;
    if (!result.granted) {
      setState(() => _permanentlyDenied = result.permanentlyDenied);
      return;
    }
    await _getLocationAndUpdateProfile();
    _navigateAfterSuccess();
  }

  /// Called when permission is granted (e.g. after returning from Settings).
  Future<void> _onLocationGranted() async {
    await _getLocationAndUpdateProfile();
    if (!mounted) return;
    _navigateAfterSuccess();
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
