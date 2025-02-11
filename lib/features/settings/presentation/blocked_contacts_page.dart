import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/home_page/provider/get.user.notifier.dart';
import 'package:metal/features/settings/presentation/widget/blocked_user_action.dart';
import 'package:metal/features/settings/provider/get.blocked.user.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/card.with.shadow.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/widgets/text_views.dart';

class BlockedContactsPage extends ConsumerStatefulWidget {
  final String? id;
  const BlockedContactsPage({
    super.key,
    this.id = "unknow",
  });
  static const name = 'BlockedContactsPage';
  static const route = name;

  @override
  ConsumerState<BlockedContactsPage> createState() =>
      _BlockedContactsPageState();
}

class _BlockedContactsPageState extends ConsumerState<BlockedContactsPage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).data;
    final blockedUserList = ref.watch(getBlockUserProvider).data ?? [];

    final creatorUserdata = ref.watch(getUserProvider(user!.id!));

    return BaseScreen(
      Header: "Blocked contacts",
      appBarState: AppBarState.HambugerWithHeader,
      body: Stack(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.metalPinkColour,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                height: MediaQuery.of(context).size.height - 150,
                decoration: const BoxDecoration(
                  color: AppColors.metalWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: SvgPicture.asset(
                        Assets.icons.meltedMetalsSmileyXEyes.path,
                      ),
                    ),
                    blockedUserList.isEmpty
                        ? const Center(
                            child:
                                EmptyState(text: "No Metal Has been Blocked"))
                        : Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.only(top: 20),
                              itemCount: blockedUserList.length,
                              itemBuilder: (context, index) => CardWithShadow(
                                  onTap: () {
                                    showBlockedUserActions(
                                      context,
                                      creatorUserdata.data!.username!,
                                      user.id!,
                                    );
                                  },
                                  height: 105,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ProfilePhoto(
                                        meltId: creatorUserdata.data!.metal!,
                                      ),
                                      const Gap(23),
                                      TextView(
                                        text: creatorUserdata.data!.username!,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
