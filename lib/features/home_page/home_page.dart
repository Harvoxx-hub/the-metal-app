import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/home_page/provider/get.all.users.notifier.dart';
import 'package:metal/gen/assets.gen.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

import 'widget/metal.user.card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final allUsers = ref.watch(getAllUserProvider);
    // final _currentUser = ref.watch(authProvider);
    if (allUsers.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return allUsers.data != null && allUsers.data!.isNotEmpty
          ? SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                            color: AppColors.metalPinkColour,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(35),
                              bottomRight: Radius.circular(35),
                            )),
                      ),

                      // This container is for the background image decoration
                      Container()
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Column(
                        children: [
                          for (var user in allUsers.data!)
                            MetalUserCard(
                              user: user,
                            ),
                        ],
                      )),
                ],
              ),
            )
          : Center(
              child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Assets.gifs.empty.path,
                    height: 250,
                    width: 250,
                  ),
                  const Gap(46),
                  const TextView(
                    textAlign: TextAlign.center,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    text: "No metal users found that matchs your Preference",
                  ),
                  const Gap(20),
                ],
              ),
            ));
    }
  }
}
