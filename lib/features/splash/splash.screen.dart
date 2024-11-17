import 'dart:async';

 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gap/gap.dart';
import 'package:metal/core/services/auth.pref.service.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  static const routeName = '/splash';

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  late final String _asset = Assets.images.bg1.path;
  late Connectivity _connectivity;

  @override
  void initState() {
    super.initState();

    _connectivity = Connectivity();

    _retryConnection();
    // Use post-frame callback to ensure the button is shown after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
 
    });
  }

  _checkLoginState() {
    AuthManager.getLoginState().then((value) {
      if (value == LoginState.loggedIn) {
        ref.read(authProvider.notifier).getCurrentUser();
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    });
  }

  // Method to show a no internet connection dialog
  void _showNoConnectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("No Internet Connection"),
        content:
            const Text("Please check your internet connection and try again."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _retryConnection(); // Retry login check after dialog is dismissed
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  // Method to retry the connection check and login state
  void _retryConnection() async {
    List<ConnectivityResult> result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      _showNoConnectionDialog(); // Retry login check if connection is restored
    } else {
      // Show the dialog again if there's still no connection
      _checkLoginState();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (prev, current) {
      if (current.isSuccess) {
        current.data!.profileUpdated ?? false
            ? Navigator.pushReplacementNamed(context, AppRoutes.dashboardPage)
            : Navigator.pushReplacementNamed(context, AppRoutes.welcomePage);
      }
      if (current.isError) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    });

    return Scaffold(
      body: Container(
        /// We need to use decoration to occupy the entire screen
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_asset),
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
            ],
          ),
        ),
      ),
    );
  }
}
