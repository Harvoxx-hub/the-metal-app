import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
 
import 'package:metal/features/home_page/provider/get.melt.users.notifier.dart';
 

import 'package:metal/gen/assets.gen.dart';

import 'package:metal/route/routes.dart';

import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

class MeltMetal extends ConsumerStatefulWidget {
  const MeltMetal({super.key, required this.id});
  static const name = 'meltMetal';
  static const route = name;
  final String id;
  @override
  ConsumerState<MeltMetal> createState() => _MeltMetalState();
}

class _MeltMetalState extends ConsumerState<MeltMetal> {
  UserModel? meltUserData;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(getMeltUserProvider.notifier).getMeltUsers();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userStateProvider);
  
    ref.listen<GetMeltUsersState>(getMeltUserProvider, (prev, current) {
      if (current.isSuccess) {
        meltUserData = ref
            .watch(getMeltUserProvider.notifier)
            .getMeltUserById(widget.id)!
            .otherUser;
        setState(() {});
      }
    });
    return BaseScreen(
      subAppBar: true,
      isLoading: meltUserData == null,
      appBarState: AppBarState.BackWithHeader,
      Header: "My melted metals",
      body: meltUserData == null
          ? const Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : Column(children: [
              const Gap(74),
              const TextView(
                text: "It’s a melt🎉",
                fontWeight: FontWeight.w600,
                fontSize: 28,
              ),
              const Gap(8),
              TextView(
                text:
                    "*You* and *@${meltUserData?.username ?? ""}*\n just melted",
                fontWeight: FontWeight.w400,
                textAlign: TextAlign.center,
                fontSize: 15,
              ),
              const Gap(66),
              Container(
                child: Stack(
                  children: [
                    const SizedBox(
                      width: double.infinity,
                      height: 300,
                    ),
                    Positioned(
                      left: 40,
                      child: Column(
                        children: [
                          ProfilePhoto(
                            size: 156,
                            verfly: false,
                            meltId: user.data!.metal!,
                          ),
                          const Gap(28),
                          username(
                            name: user.data!.username!,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 40,
                      child: Column(
                        children: [
                          ProfilePhoto(
                              size: 156,
                              meltId: meltUserData!.metal!,
                              verfly: false),
                          const Gap(28),
                          username(
                            name: meltUserData!.username!,
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
                    Navigator.pushNamed(context, AppRoutes.chatWindowsPage,
                        arguments: meltUserData!.id);
                  }),
                  meltItem("Spark", Assets.images.meltSpark.path, () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.sendSpark,
                      arguments: meltUserData,
                    );
                  }),
                  // meltItem("Profile", Assets.images.meltProfile.path, () {
                  //   Navigator.pushNamed(context, AppRoutes.userProfilePage,
                  //       arguments: UserModel.fromJson(meltUserData.toJson()));
                  // }),
                  meltItem("Dashboard", Assets.images.meltDashboard.path, () {
                    Navigator.pop(context);
                    Navigator.pop(context);
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
