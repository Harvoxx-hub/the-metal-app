import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/services/location_service.dart';
import 'package:metal/core/utils/permission_helper.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/fcm/fcm_client.dart';
import 'package:metal/presentation/viewmodels/splash/splash_viewmodel_providers.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/text_views.dart';

/// Splash view using Clean Architecture
/// Checks authentication state and navigates accordingly
class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});
  static const name = 'splash';
  static const route = '/$name';

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {
  static const _minSplashDuration = Duration(milliseconds: 1500);
  DateTime? _splashShownAt;

  @override
  void initState() {
    super.initState();
    _splashShownAt = DateTime.now();
    // Check auth state after first frame so splash is visible
    // Request location on splash (with notification/camera/mic from main) so user isn’t asked on home
 
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  /// Ensure splash stays visible at least [_minSplashDuration] before navigating.
  Future<void> _waitMinSplashDuration() async {
    if (_splashShownAt == null) return;
    final elapsed = DateTime.now().difference(_splashShownAt!);
    if (elapsed < _minSplashDuration) {
      await Future.delayed(_minSplashDuration - elapsed);
    }
  }

  Future<void> _checkAuthAndNavigate() async {

    await _requestLocationAndStoreIfGranted();
    final viewModel = ref.read(splashViewModelProvider.notifier);

    // Check if user has seen onboarding
    final hasSeenOnboarding = await viewModel.hasSeenOnboarding();

    if (!hasSeenOnboarding) {
      // User hasn't seen onboarding, go to onboarding
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
      return;
    }

    // Check authentication state
    await viewModel.checkAuthState();
  }

  void _handleNavigation(UserDto? user) async {
    if (!mounted) return;

    if (user == null) {
      ref.read(userStateProvider.notifier).clear();
      await _waitMinSplashDuration();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      return;
    }

    ref.read(userStateProvider.notifier).setUser(user);
    try {
      await FCMClient.instance.registerTokenWithBackend(ref);
    } catch (_) {}

    if (!mounted) return;

    if (user.emailVerified == false) {
      await _waitMinSplashDuration();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.verificationPage,
        arguments: user.email,
      );
      return;
    }

    

    await _waitMinSplashDuration();
    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      user.profileUpdated == true
          ? AppRoutes.dashboardPage
          : AppRoutes.welcomePage,
    );
  }

  /// Request location permission at app start; if granted, get location and send to API.
  /// This way discovery (and any other feature) never hits the API before location is stored.
  Future<void> _requestLocationAndStoreIfGranted() async {
    if (!mounted) return;
    final result = await PermissionHelper.requestLocationPermission();
    if (!mounted) return;
    if (!result.granted) return;

    final locResult = await LocationService().getCurrentLocation();
    if (!mounted) return;
    if (locResult.isSuccess && locResult.location != null) {
      await ref.read(userStateProvider.notifier).updateUserField(
            field: 'location',
            value: locResult.location!.toJson(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final splashState = ref.watch(splashViewModelProvider);

    // Listen to state changes for navigation
    ref.listen(
      splashViewModelProvider,
      (previous, current) {
        if (current.isSuccess) {
          _handleNavigation(current.data);
        } else if (current.isError) {
          // On error, go to onboarding
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
          }
        }
      },
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.images.bg1.path),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Assets.gifs.logo.path,
                width: 53,
                height: 53,
              ),
              const Gap(10),
              const TextView(
                text: 'Metal',
                fontSize: 32,
              ),
              const Gap(10),
              const TextView(
                text: '...True Friendship is built \n on real connections',
                fontSize: 16,
                textAlign: TextAlign.center,
              ),
              if (splashState.isLoading) ...[
                const Gap(20),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
