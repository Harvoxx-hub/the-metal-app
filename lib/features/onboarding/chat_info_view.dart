import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/authentication/presentation/signup/verfication.argument.dart';
import 'package:metal/features/authentication/presentation/signup/verfication.page.dart';
import 'package:metal/features/authentication/provider/login.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/text_views.dart';

class ChatInfoView extends ConsumerWidget {
  const ChatInfoView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('Build was called...');
    ref.listen<LoginStates>(loginProvider, (prev, current) {
      debugPrint('Login state changed: $current');
      if (current.isSuccess) {
        debugPrint('Login success. Proceeding to next page.');
        !(current.data!.emailVerified ?? false)
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
            : Navigator.pushNamed(
                context,
                current.data?.profileUpdated ?? false
                    ? AppRoutes.dashboardPage
                    : AppRoutes.welcomePage,
              );
      }
      debugPrint('Navigating to the last');
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Assets.images.chatCircle.path,
                  ),
                  const Gap(24),
                  const TextView(
                    text: 'About Chats!',
                    color: AppColors.metalWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  const Gap(16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: TextView(
                      text:
                          'Send and receive messages to build real connections with each other for the next 15 days without sending your pictures.\n\nPlay games to deepen conversations and sparks to ignite connections',
                      color: AppColors.metalWhite.withOpacity(0.8),
                      textAlign: TextAlign.center,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      final current = ref.read(loginProvider);
                      if (current.isSuccess) {
                        debugPrint('Login success. Proceeding to next page.');
                        !(current.data!.emailVerified ?? false)
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
                            : Navigator.pushNamed(
                                context,
                                current.data?.profileUpdated ?? false
                                    ? AppRoutes.dashboardPage
                                    : AppRoutes.welcomePage,
                              );
                      }
                    },
                    child: const Row(
                      children: [
                        TextView(
                          text: "I'M DONE",
                          color: AppColors.metalWhite,
                          fontWeight: FontWeight.bold,
                        ),
                        Gap(4),
                        Icon(Icons.waving_hand, color: Colors.amber),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
