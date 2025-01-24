import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/onboarding/chat_info_view.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

class SparksInfoSwitchView extends StatelessWidget {
  const SparksInfoSwitchView({super.key});

  @override
  Widget build(BuildContext context) {
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
                    Assets.images.onboard2.path,
                  ),
                  const Gap(24),
                  const TextView(
                    text: 'About Sparks!',
                    color: AppColors.metalWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                  const Gap(16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: TextView(
                      text:
                          'Our point payment in-app system.\n1 Dollar = 10 Sparks. You can refer friends and earn more sparks. You can also send and buy Sparks',
                      color: AppColors.metalWhite.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.5,
                      textAlign: TextAlign.center,
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatInfoView(),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        TextView(
                          text: 'NEXT',
                          color: AppColors.metalWhite,
                          fontWeight: FontWeight.bold,
                        ),
                        Gap(4),
                        Icon(Icons.arrow_forward, color: Colors.white),
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
