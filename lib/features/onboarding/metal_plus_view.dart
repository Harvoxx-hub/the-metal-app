import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';

class MetalPlusView extends StatelessWidget {
  const MetalPlusView({super.key});

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
                  const Spacer(),
                  Row(
                    children: [
                      Image.asset(
                        Assets.gifs.logo.path,
                        width: 40,
                        height: 40,
                      ),
                      const Gap(10),
                      const Text(
                        'Metal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '+',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upgrade To Metal Plus',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(12),
                      Text(
                        'There are exciting features you would experience when you upgrade your account to Metal Plus.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                      const Gap(24),
                      const Text(
                        'With Metal Plus, you can:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Gap(16),
                      _buildFeaturesList(),
                    ],
                  ),
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
                      Navigator.pushNamed(context, '/unmetal');
                    },
                    child: const Row(
                      children: [
                        Text(
                          'NEXT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildFeaturesList() {
    final features = [
      'Can delete chat',
      'Can edit chat',
      'Can see that a message is read',
      'Can make unlimited video calls',
      'Can see who pushed on their profile (5 days)',
      'Can see who liked their profile (15 days)',
      'Can see a list of profiles liked (15 days)',
      'See the profiles you pushed (15 days)',
      'Send voice notes',
      'See previous profiles/feeds (only during a session)',
      'Can upload up to three files on eyes',
      'No ads',
      'All the above in one inclusive tier',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
