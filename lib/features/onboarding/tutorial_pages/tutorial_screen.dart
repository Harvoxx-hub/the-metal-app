import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/text_views.dart';
import 'dart:math' as math;

class OnboardingFlowView extends StatefulWidget {
  const OnboardingFlowView({super.key});

  @override
  State<OnboardingFlowView> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingFlowView> {
  int currentScreen = 0;

  void nextScreen() {
    if (currentScreen < 9) {
      pageViewController.nextPage(
          duration: Duration(milliseconds: 3), curve: Curves.ease);
    }
  }

  Widget tutorialText(String title, String body) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: TextView(
            text: title,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
            color: Colors.white,
          ),
        ),
        Gap(16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: TextView(
            text: body,
            fontSize: 16,
            fontWeight: FontWeight.w300,
            textAlign: TextAlign.center,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget buildScreen1() {
    return Center(
      child: Column(
        children: [
          const Gap(150),
          Align(
            alignment: Alignment.centerRight,
            child: Image.asset(
              Assets.images.onboardOne.path,
            ),
          ),
          const SizedBox(height: 24),
          tutorialText(
            "Explore Thoughts Posted \nAnonymously",
            "The 'Explore' section highlights \npopular posts, new mentions, or \nrecommended content to keep \neach user engaged with fresh content",
          ),
        ],
      ),
    );
  }

  Widget buildScreen2() {
    return Column(
      children: [
        const Gap(150),
        Align(
          alignment: Alignment.centerRight,
          child: Image.asset(
            Assets.images.onboardTwo.path,
          ),
        ),
        const Gap(80),
        tutorialText(
          "See Personalized Thoughts",
          "The 'For You' section helps you \ndiscover new connections, \nconversations, and content tailored \nto your personality, preferences, \nand past behaviors on the app.",
        ),
      ],
    );
  }

  Widget buildScreen3() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 18.0, right: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            tutorialText("Post Your Thoughts Anonymously",
                "A simple and intuitive posting tool that allows you to share your thoughts, feelings, or introduce yourself to the community."),
            Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(
                Assets.images.onboardThree.path,
              ),
            ),
            const Gap(80),
          ],
        ),
      ),
    );
  }

  Widget buildScreen4() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          tutorialText("Tap to Like & React",
              "Show appreciation by liking or \nreacting to each other’s thoughts."),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.bottomLeft,
            child: Image.asset(
              Assets.images.onboardThursday.path,
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget buildScreen5() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        tutorialText("How to Melt with another Metal",
            "Click on the metal icon to \nview a metal profile and \nmelt with them"),
        Align(
          child: Image.asset(
            Assets.images.itsIsMelt.path,
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
          Assets.images.unmeltIcon.path,
        ),
        const Gap(20),
        tutorialText("How to Unmetal",
            "After 15 days and 10 sessions of having conversations, you can unravel the surprise to see the face behind the metal. Our goal is to build real connections. When eyes are closed, the hearts talk.\n *Metal = Hidden faces + Real hearts*"),
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
        tutorialText(
            "About Chats!",
            "Send and receive messages to build \nreal connections with each other for \nthe next 15days without sending \nyour pictures.\n" +
                "\nPlay games to deepen conversations \nand sparks to ignite connections"),
        const Gap(20),
        Image.asset(
          Assets.images.guideline.path,
        ),
      ],
    );
  }

  Widget buildWelcomeScreen() {
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
        Assets.icons.handshake.svg(),
        const Gap(20),
        tutorialText(
            "Welcome to the Metal App",
            "*Post a thought to get started*\n" +
                "  Don’t post your names, social handles, phone numbers or home address.\n" +
                "\nThe experiment is to fall in love blindly or connect deeply through your words, passion and values. Can love be truly disguised?\n" +
                "\nRemember, every match is a mystery. Let your passions lead you\n"),
        const Gap(20),
        Image.asset(
          Assets.images.guideline.path,
        ),
      ],
    );
  }

  Widget buildSparksScreen() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Row(
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
        const Spacer(),
        Image.asset(
          Assets.images.onboard2.path,
        ),
        const Gap(20),
        tutorialText("About Sparks!",
            "Our point payment in-app system. 1 Dollar = 10 Sparks. You can refer friends and earn more sparks. You can also send and buy Sparks."),
        const Gap(20),
        Transform.rotate(
          angle: -math.pi / -4,
          child: Image.asset(
            Assets.images.guideline.path,
          ),
        ),
        const Gap(20),
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
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset(
                Assets.icons.caretLeft.path,
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(16),
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
              fontSize: 18,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            _buildFeatureItem("delete chat"),
            _buildFeatureItem("edit chat"),
            _buildFeatureItem("send direct message"),
            _buildFeatureItem("see that a message is read"),
            _buildFeatureItem("make video calls"),
            _buildFeatureItem("see who liked your profile"),
            _buildFeatureItem("see a list of profiles you liked"),
            _buildFeatureItem("view metals with double verification"),
            _buildFeatureItem("send voice notes"),
            _buildFeatureItem("no ads"),
            _buildFeatureItem("all the above in one inclusive tier"),
          ],
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

  PageController pageViewController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18.0, vertical: 25),
              child: PageView(
                onPageChanged: (value) {
                  setState(() {
                    currentScreen = value;
                  });
                },
                //  index: currentScreen,
                controller: pageViewController,
                children: [
                  buildScreen1(),
                  buildScreen2(),
                  buildScreen3(),
                  buildScreen4(),
                  buildScreen5(),
                  buildMetalScreen(),
                  buildUnmetalScreen(),
                  buildSparksScreen(),
                  buildChatScreen(),
                  buildWelcomeScreen()
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0, right: 30),
            child: SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  currentScreen == 9
                      ? GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, AppRoutes.dashboardPage);
                          },
                          child: Row(
                            children: [
                              const Text(
                                'I’M DONE👌',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Image.asset(
                                Assets.icons.chevronCircle.path,
                              ),
                            ],
                          ),
                        )
                      : GestureDetector(
                          onTap: nextScreen,
                          child: Row(
                            children: [
                              const Text(
                                'NEXT',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Image.asset(
                                Assets.icons.chevronCircle.path,
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
          currentScreen == 7
              ? SizedBox(
                  width: double.infinity,
                  child: Image.asset(
                    fit: BoxFit.cover,
                    Assets.images.sparksBottomSheet.path,
                  ),
                )
              : const SizedBox.shrink(),
          currentScreen == 8
              ? SizedBox(
                  width: double.infinity,
                  child: Image.asset(
                    fit: BoxFit.cover,
                    Assets.images.chatBottomSheet.path,
                  ),
                )
              : currentScreen == 9
                  ? SizedBox(
                      width: double.infinity,
                      child: Image.asset(
                        fit: BoxFit.cover,
                        Assets.images.nonBottomSheet.path,
                      ),
                    )
                  : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
