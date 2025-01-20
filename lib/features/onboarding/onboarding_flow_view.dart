import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/onboarding/metal_plus_view.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

class OnboardingFlowView extends StatefulWidget {
  const OnboardingFlowView({super.key});

  @override
  _OnboardingFlowViewState createState() => _OnboardingFlowViewState();
}

class _OnboardingFlowViewState extends State<OnboardingFlowView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isMainOnboardingDone = false;

  final List<OnboardingItem> _pages = [
    OnboardingItem(
      title: 'Explore Community Posts',
      description:
          'Discover popular posts, new members, and trending conversations to stay connected with fresh content.',
      icon: Icons.explore,
    ),
    OnboardingItem(
      title: 'Personalized For You',
      description:
          'Get recommendations tailored to your interests, preferences, and past interactions on the platform.',
      icon: Icons.person,
    ),
    OnboardingItem(
      title: 'Share Your Thoughts',
      description:
          'A simple way to express yourself and connect with the community through posts and discussions.',
      icon: Icons.create,
    ),
    OnboardingItem(
      title: 'Engage With Others',
      description:
          'React to posts and show appreciation for content that resonates with you.',
      icon: Icons.favorite,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_isMainOnboardingDone) {
      return const MetalPlusView();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
                if (page == _pages.length - 1) {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    setState(() {
                      _isMainOnboardingDone = true;
                    });
                  });
                }
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildDot(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              item.icon,
              size: 80,
              color: Colors.white,
            ),
          ),
          const Gap(40),
          TextView(
            text: item.title,
            color: AppColors.metalWhite,
            textAlign: TextAlign.center,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          const Gap(20),
          TextView(
            text: item.description,
            color: AppColors.metalWhite.withOpacity(0.8),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index
            ? Colors.white
            : Colors.white.withOpacity(0.4),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}
