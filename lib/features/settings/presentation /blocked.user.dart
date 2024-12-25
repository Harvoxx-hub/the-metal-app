import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/settings/provider/get.blocked.user.notifier.dart';

import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/settings/presentation%20/widget/blocked.card.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';

class BlockedUser extends ConsumerWidget {
  const BlockedUser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedUserList = ref.watch(getBlockUserProvider).data ?? [];
    return BaseScreen(
      appBarState: AppBarState.BackWithHeader,
      Header: "Blocked Contact",
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.00, -1.00),
                        end: Alignment(0, 1),
                        colors: [Color(0xFFDB217A), Color(0xFFF00E3E)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(35),
                        bottomRight: Radius.circular(35),
                      )),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 24.0, right: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [],
                    ),
                  ),
                ),
              ],
            ),
            blockedUserList.isEmpty
                ? Center(
                    child: const EmptyState(text: "No Metal Has been Blocked"))
                : Padding(
                    padding: const EdgeInsets.only(top: 29, left: 9, right: 9),
                    child: Container(
                      padding:
                          const EdgeInsets.only(top: 55, left: 22, right: 22),
                      decoration: const BoxDecoration(
                          color: AppColors.metalWhite,
                          borderRadius: BorderRadius.all(
                            Radius.circular(35),
                          )),
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            Assets.icons.meltedMetalsSmileyXEyes.path,
                            height: 90,
                            width: 90,
                          ),
                          const Gap(13),
                          Column(
                            children: [
                              for (var element in blockedUserList ?? [])
                                BlockedCard(
                                  id: element["id"],
                                ),
                            ],
                          ),
                          const Gap(30)
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
