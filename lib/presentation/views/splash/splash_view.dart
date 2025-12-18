import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/profile/profile_viewmodel_providers.dart';
import 'package:metal/presentation/viewmodels/splash/splash_viewmodel_providers.dart';
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
  @override
  void initState() {
    super.initState();
    // Check auth state after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
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
      // User is not authenticated, go to onboarding/login
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    } else {
      // User is authenticated - fetch profile to maintain state and navigate
      await ref.read(profileViewModelProvider.notifier).fetchUserProfile();

      // Navigate based on user state
      if (!mounted) return;

      if (user.emailVerified == false) {
        // User needs email verification - just pass email
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.verificationPage,
          arguments: user.email,
        );
      } else {
        // User is verified, go to dashboard or welcome based on profile completion
        Navigator.pushReplacementNamed(
          context,
          user.profileUpdated == true
              ? AppRoutes.dashboardPage
              : AppRoutes.welcomePage,
        );
      }
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
