import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/features/authentication/provider/auth.notifier.dart';

import 'package:metal/features/profile/presentation/tab.screen/discovery.tab.dart';
import 'package:metal/features/profile/presentation/tab.screen/metal.plan.tab.dart';
import 'package:metal/features/profile/presentation/tab.screen/personal.tab.dart';
import 'package:metal/features/profile/presentation/widget/profile.header.dart';

import 'package:metal/res/colors/cr_colors.dart';

import 'package:metal/widgets/tab/base.tab.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).data!;

    return SingleChildScrollView(
      child: ProfileHeader(
        metal: user.metal!,
        profileUrl: user.profilePhoto,
        child: Padding(
          padding: const EdgeInsets.only(top: 110, left: 20, right: 20),
          child: Container(
            padding: const EdgeInsets.only(top: 122),
            decoration: const BoxDecoration(
              color: AppColors.metalWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35),
                topRight: Radius.circular(35),
              ),
            ),
            child: Column(
              children: [
                BaseTab(
                  tabs: [
                    BaseTabModel(child: const PersonalTab(), title: 'Personal'),
                    // BaseTabModel(
                    //     child: const MetalPlanTab(), title: 'Metal Plan'),
                    BaseTabModel(
                        child: const DiscoveryTab(), title: 'Discovery'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
