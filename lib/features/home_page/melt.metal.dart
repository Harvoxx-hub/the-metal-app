import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/home_page/domain/entries/all.user.model.dart';
import 'package:metal/features/home_page/provider/get.all.users.notifier.dart';
import 'package:metal/features/home_page/provider/get.melt.users.notifier.dart';
import 'package:metal/features/home_page/provider/melt.user.notifier.dart';
import 'package:metal/features/sparks_page/screens/send.spark/send.spark.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/chat/presentation/chat.window/chat.window.dart';
import 'package:metal/features/my.metals/user.profile.dart';

import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:provider/provider.dart';

class MeltMetal extends ConsumerWidget {
  const MeltMetal(this.meltUserData, {super.key});
  static const name = 'meltMetal';
  static const route = '$name';
  final ALLUserModel meltUserData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meltUser = ref.watch(meltUserProvider(meltUserData.id!));

    ref.listen<MeltUsersState>(meltUserProvider(meltUserData.id!),
        (prev, current) {
      if (current.isSuccess) {
        ref.read(getAllUserProvider.notifier).removeUser(meltUserData.id!);

        // context.pushReplacementNamed(DashboardPage.name);
      }
    });
    final user = ref.watch(authProvider);
    return BaseScreen(
      subAppBar: true,
      appBarState: AppBarState.HambugerWithHeader,
      Header: "My melted metals",
      body: meltUser.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              const Gap(74),
              TextView(
                text: "It’s a melt🎉",
                fontWeight: FontWeight.w600,
                fontSize: 28,
              ),
              const Gap(8),
              TextView(
                text: "You and @${meltUserData.username}\n just melted",
                fontWeight: FontWeight.w400,
                textAlign: TextAlign.center,
                fontSize: 15,
              ),
              const Gap(66),
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
                          username(
                            name: user.data!.username!,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 30,
                      child: Column(
                        children: [
                          ProfilePhoto(size: 156, verfly: false),
                          Gap(28),
                          username(
                            name: meltUserData.username!,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(70),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  meltItem("Chat", Assets.images.meltChat.path, () {
                    context.pushNamed(ChatWindowsPage.name,
                        extra: meltUserData.phone);
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
        const Gap(9),
        GestureDetector(onTap: onTap, child: Image.asset(path))
      ],
    );
  }
}

class username extends StatelessWidget {
  const username({
    super.key,
    required this.name,
  });
  final String name;

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
        text: "@$name",
        textAlign: TextAlign.center,
      ),
    );
  }
}
