import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/text_views.dart';

class OnboardingFlowView extends StatefulWidget {
  const OnboardingFlowView({super.key});

  @override
  State<OnboardingFlowView> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingFlowView> {
  int currentScreen = 0;

  void nextScreen() {
    if (currentScreen < 8) {
      setState(() {
        currentScreen++;
      });
    }
  }

  Widget buildScreen1() {
    return Center(
      child: Column(
        children: [
          const Gap(80),
          Image.asset(
            Assets.images.onboardOne.path,
          ),
          const SizedBox(height: 24),
          const TextView(
            text: "Explore Thoughts Posted \nAnonymously",
            fontSize: 20,
            fontFamily: 'Merri_weather',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: TextView(
              text:
                  "The 'Explore' section highlights \npopular posts, new mentions, or \nrecommended content to keep \neach user engaged with fresh content",
              fontSize: 16,
              fontFamily: 'Merri_weather',
              textAlign: TextAlign.center,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildScreen2() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 80),
          Align(
            alignment: Alignment.topLeft,
            child: Image.asset(
              Assets.images.onboardTwo.path,
            ),
          ),
          const Gap(80),
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
                  "The 'For You' section helps you \ndiscover new connections, \nconversations, and content tailored \nto your personality, preferences, \nand past behaviors on the app.",
              fontSize: 16,
              fontFamily: 'Merri_weather',
              textAlign: TextAlign.center,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildScreen3() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const Text(
            "Post Your Thoughts Anonymously",
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Merri_weather',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const TextView(
            text:
                "A simple and intuitive posting tool \nthat allows you to share your \nthoughts, feelings, or introduce \nyourself to the community.",
            fontSize: 16,
            fontFamily: 'Merri_weather',
            textAlign: TextAlign.center,
            color: Colors.white,
          ),
          const Gap(80),
          Image.asset(
            Assets.images.onboardThree.path,
          ),
        ],
      ),
    );
  }

  Widget buildScreen4() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
                  "Show appreciation by liking or \nreacting to each other’s thoughts.",
              fontSize: 16,
              fontFamily: 'Merri_weather',
              textAlign: TextAlign.center,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Image.asset(
            Assets.images.onboardThursday.path,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget buildScreen5() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextView(
            text: "It’s a melt🎉",
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: TextView(
              text:
                  "Click on the metal icon to \nview a metal profile and \nmelt with them",
              fontSize: 16,
              fontFamily: 'Merri_weather',
              textAlign: TextAlign.center,
              color: Colors.white,
            ),
          ),
        ],
      ),
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
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    Assets.icons.caretLeft.path,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Image.asset(
          Assets.images.onboard1.path,
        ),
        const Gap(20),
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
                "After 15 days and 10 sessions of having conversations, you can unravel the surprise to see the face behind the metal. Our goal is to build real connections. When eyes are closed, the hearts talk.Metal = Hiden faces + Real hearts",
            height: 1.5,
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget buildChatScreen() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    Assets.icons.caretLeft.path,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Image.asset(
          Assets.images.chatCircle.path,
        ),
        const Gap(20),
        const TextView(
          text: "About Chats!",
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: TextView(
            text:
                "Send and receive messages to build \nreal connections with each other for \nthe next 15days without sending \nyour pictures.",
            height: 1.5,
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: TextView(
            text:
                "Play games to deepen conversations \nand sparks to ignite connections",
            height: 1.5,
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
        ),
        Image.asset(
          Assets.images.onboardThursday.path,
        ),
      ],
    );
  }

  Widget buildAboutScreen() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    Assets.icons.caretLeft.path,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Image.asset(
          Assets.images.onboard2.path,
        ),
        const Gap(20),
        const TextView(
          text: "About Sparks!",
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: TextView(
            text:
                "Our point payment in-app system. \n1 Dollar = 10 Sparks. You can refer \nfriends and earn more sparks. You \ncan also send and buy Sparks",
            height: 1.5,
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
        ),
        Image.asset(
          Assets.images.onboardThursday.path,
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
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  Assets.icons.caretLeft.path,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
        Image.asset(
          Assets.icons.logoText.path,
        ),
        const Gap(20),
        const TextView(
          text: "Upgrade To Metal Plus",
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        const Gap(10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(16),
              const TextView(
                text:
                    "There are exciting features you would \nexperience when you upgrade your \naccount to Metal Plus",
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
      backgroundColor: Colors.black.withOpacity(0.8),
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
                  buildAboutScreen(),
                  buildChatScreen(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    currentScreen == 8
                        ? GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, AppRoutes.dashboardPage);
                            },
                            child: const Text(
                              'I’M DONE👌',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: nextScreen,
                            child: const Text(
                              'NEXT',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                    const SizedBox(width: 8),
                    Image.asset(
                      Assets.icons.chevronCircle.path,
                    ),
                  ],
                ),
              ),
            ),
            currentScreen == 7
                ? SizedBox(
                    width: double.infinity,
                    child: Expanded(
                      child: Image.asset(
                        fit: BoxFit.cover,
                        Assets.images.bottomSpark.path,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            currentScreen == 8
                ? SizedBox(
                    width: double.infinity,
                    child: Expanded(
                      child: Image.asset(
                        fit: BoxFit.cover,
                        Assets.images.bottomChat.path,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
