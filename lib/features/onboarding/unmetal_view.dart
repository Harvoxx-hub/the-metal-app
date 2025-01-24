import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

class UnmetalView extends StatelessWidget {
  const UnmetalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Assets.images.onboard1.path,
                    ),
                    const Gap(24),
                    const TextView(
                      text: 'Unmetal',
                      color: AppColors.metalWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    const Gap(16),
                    TextView(
                      text:
                          'After 15 days and 10 sessions of having conversations, you can unravel the surprise to see the face behind the metal.',
                      color: AppColors.metalWhite.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      textAlign: TextAlign.center,
                    ),
                    const Gap(8),
                    TextView(
                      text:
                          'Our goal is to build real connections.\nWhen eyes are closed, the hearts talk.',
                      color: AppColors.metalWhite.withOpacity(0.8),
                      fontSize: 16,
                      textAlign: TextAlign.center,
                    ),
                    const Gap(16),
                    TextView(
                      text:
                          'Our goal is to build real connections.\nWhen eyes are closed, the hearts talk.',
                      color: AppColors.metalWhite.withOpacity(0.8),
                      fontSize: 16,
                      textAlign: TextAlign.center,
                    ),
                    TextView(
                      text: 'Metal + Hidden faces + Real hearts',
                      color: AppColors.metalWhite.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/sparkInfoSwitchView');
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
