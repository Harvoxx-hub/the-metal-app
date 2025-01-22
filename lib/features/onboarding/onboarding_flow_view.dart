import 'package:flutter/material.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/text_views.dart';

class OnboardingFlowView extends StatefulWidget {
  const OnboardingFlowView({super.key});

  @override
  State<OnboardingFlowView> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingFlowView> {
  int currentScreen = 0;

  void nextScreen() {
    if (currentScreen < 6) {
      setState(() {
        currentScreen++;
      });
    }
  }

  Widget buildScreen1() {
    return Column(
      children: [
        const SizedBox(height: 80),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey,
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          child: const Center(
            child: Icon(Icons.person_outline, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 24),
        const TextView(
          text: "Explore Thoughts Posted Anonymously",
          fontSize: 20,
          fontFamily: 'Merri_weather',
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: TextView(
            text:
                "The 'Explore' section highlights popular posts, new mentions, or recommended content to keep each user engaged with fresh content",
            fontSize: 16,
            fontFamily: 'Merri_weather',
            textAlign: TextAlign.center,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget buildScreen2() {
    return Column(
      children: [
        const SizedBox(height: 80),
        Stack(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.pink.withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),
            Positioned(
              right: -5,
              bottom: -5,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.pink.withOpacity(0.5),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const TextView(
          text: "See Personalized Thoughts",
          fontSize: 20,
          fontFamily: 'Merri_weather',
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: TextView(
            text:
                "The 'For You' recommends personalized discoveries, connections, conversations, and content tailored to your interests",
            fontSize: 16,
            fontFamily: 'Merri_weather',
            textAlign: TextAlign.center,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget buildScreen3() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Post Your Thoughts",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: TextView(
            text:
                "A simple and intuitive posting tool that allows you to share your thoughts anonymously",
            fontSize: 16,
            fontFamily: 'Merri_weather',
            textAlign: TextAlign.center,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget buildScreen4() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.pink),
          ),
          child: const Icon(
            Icons.favorite,
            color: Colors.pink,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        const TextView(
          text: "Tap to Like & React",
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: TextView(
            text:
                "Show appreciation by liking or reacting to another's thoughts",
            fontSize: 16,
            fontFamily: 'Merri_weather',
            textAlign: TextAlign.center,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget buildScreen5() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "🫠",
          style: TextStyle(fontSize: 48),
        ),
        SizedBox(height: 24),
        TextView(
          text: "It's a melt",
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: TextView(
            text:
                "Join us on this mind-boggling view through another eye's melt with them",
            fontSize: 16,
            fontFamily: 'Merri_weather',
            textAlign: TextAlign.center,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget buildUnmetalScreen() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {},
                color: Colors.grey,
              ),
              const Expanded(
                child: TextView(
                  text: "Unmetal",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
              child: const Icon(Icons.remove_red_eye, color: Colors.grey),
            ),
            const SizedBox(width: 20),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
              child: const Icon(Icons.favorite, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const TextView(
          text: "Unmetal",
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: TextView(
            text:
                "After 15 days and 10 sessions of having conversations, you can unveil the surprise to see the face behind the metal.\n\nOur goal is to build real connections.\nWhen eyes are closed, the hearts talk.\nMetal → Hidden faces → Real hearts",
            height: 1.5,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget buildMetalScreen() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Assets.gifs.logo.path,
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 8),
            const TextView(
              text: "Metal",
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const TextView(
          text: "Upgrade To Metal Plus",
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextView(
                text:
                    "There are exciting features you would experience when you upgrade your account to Metal Plus",
                textAlign: TextAlign.start,
                color: Colors.white,
                height: 1.5,
              ),
              const SizedBox(height: 16),
              const TextView(
                text: "With Metal Plus, you can:",
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              _buildFeatureItem("Can initiate chat"),
              _buildFeatureItem("Can left chat"),
              _buildFeatureItem("Can see that a message is read"),
              _buildFeatureItem("Can make unlimited video calls"),
              _buildFeatureItem("Can see who pushed on their profile (5 days)"),
              _buildFeatureItem("Can see a list of profiles liked (5 days)"),
              _buildFeatureItem("See the profiles you pushed (5 days)"),
              _buildFeatureItem("Push one profile/day"),
              _buildFeatureItem(
                  "See previous profiles/feeds (only during a session)"),
              _buildFeatureItem("Can upload up to three files on eyes"),
              _buildFeatureItem("No ads"),
              _buildFeatureItem("All the above in one inclusive tier"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ",
              style: TextStyle(
                color: Colors.white,
              )),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: currentScreen,
                children: [
                  buildScreen1(),
                  buildScreen2(),
                  buildScreen3(),
                  buildScreen4(),
                  buildScreen5(),
                  buildMetalScreen(),
                  buildUnmetalScreen(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: nextScreen,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'NEXT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
