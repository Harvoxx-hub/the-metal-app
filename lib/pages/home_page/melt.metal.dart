import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/pages/chat/chat.window/chat.window.dart';
import 'package:metal/pages/my.metals/user.profile.dart';
import 'package:metal/pages/sparks_page/send.spark/send.spark.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

class MeltMetal extends StatelessWidget {
  const MeltMetal({super.key});
  static const name = 'meltMetal';
  static const route = '$name';

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      subAppBar: true,
      appBarState: AppBarState.HambugerWithHeader,
      Header: "My melted metals",
      body: Column(children: [
        Gap(74),
        TextView(
          text: "It’s a melt🎉",
          fontWeight: FontWeight.w600,
          fontSize: 28,
        ),
        Gap(8),
        TextView(
          text: "You and @abel_aluminium \n just melted",
          fontWeight: FontWeight.w400,
          textAlign: TextAlign.center,
          fontSize: 15,
        ),
        Gap(66),
        Container(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: 300,
              ),
              Positioned(
                left: 30,
                child: Column(
                  children: [
                    ProfilePhoto(size: 156, verfly: false),
                    Gap(28),
                    username(),
                  ],
                ),
              ),
              Positioned(
                right: 30,
                child: Column(
                  children: [
                    ProfilePhoto(size: 156, verfly: false),
                    Gap(28),
                    username(),
                  ],
                ),
              ),
            ],
          ),
        ),
        Gap(70),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            meltItem("Chat", Assets.images.meltChat.path, () {
              context.pushNamed(ChatWindowsPage.name);
            }),
            meltItem("Spark", Assets.images.meltSpark.path, () {
              context.pushNamed(SendSpark.name);
            }),
            meltItem("Profile", Assets.images.meltProfile.path, () {
              context.pushNamed(UserProfilePage.name);
            }),
            meltItem("Dashboard", Assets.images.meltDashboard.path, () {
              context.pop();
            })
          ],
        )
      ]),
    );
  }

  Widget meltItem(
    String title,
    String path,
    Function() onTap,
  ) {
    return Column(
      children: [
        TextView(
          text: title,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        Gap(9),
        GestureDetector(onTap: onTap, child: Image.asset(path))
      ],
    );
  }
}

class username extends StatelessWidget {
  const username({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: 150,
      decoration: ShapeDecoration(
        color: const Color(0x0CD9197B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      child: TextView(
        text: "@felix august_aluminium ",
        textAlign: TextAlign.center,
      ),
    );
  }
}
