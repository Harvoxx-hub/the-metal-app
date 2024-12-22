import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gap/gap.dart';
import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/features/authentication/presentation/signup/verfication.argument.dart';
import 'package:metal/features/authentication/presentation/signup/verfication.page.dart';

import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/text_views.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  static const routeName = '/splash';

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  late final String _asset = Assets.images.bg1.path;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseServiceDb.instance.auth.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      } else {
        ref.read(authProvider.notifier).getCurrentUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (prev, current) {
      if (current.isSuccess) {
        current.data!.emailVerified == false
            ? Navigator.pushReplacementNamed(
                context,
                AppRoutes.verificationPage,
                arguments: VerificationSentArgument(
                    type: RouteFrom.AccountSetting,
                    code: 123456,
                    uuid: current.data?.id ?? "",
                    phoneNumber: current.data!.phone!,
                    email: current.data!.phone!),
              )
            : current.data!.profileUpdated ?? false
                ? Navigator.pushReplacementNamed(
                    context, AppRoutes.dashboardPage)
                : Navigator.pushReplacementNamed(
                    context, AppRoutes.welcomePage);
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
