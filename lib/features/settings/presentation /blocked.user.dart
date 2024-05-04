import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/features/settings/provider/get.block.user.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/settings/presentation%20/widget/blocked.card.dart';
import 'package:metal/res/colors/cr_colors.dart';

class BlockedUser extends ConsumerWidget {
  const BlockedUser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _blockedUserState = ref.watch(getBlockUserProvider);
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
                  height: 220.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment(0.00, -1.00),
                        end: Alignment(0, 1),
                        colors: [Color(0xFFDB217A), Color(0xFFF00E3E)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(35.sp),
                        bottomRight: Radius.circular(35.sp),
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
            Padding(
              padding: const EdgeInsets.only(top: 29, left: 9, right: 9),
              child: Container(
                padding: const EdgeInsets.only(top: 55, left: 22, right: 22),
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
                    Gap(13),
                    _blockedUserState.isLoading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Column(
                            children: [
                              for (var element in _blockedUserState.data ?? [])
                                BlockedCard(
                                  id: element["id"],
                                  name: element["name"],
                                ),
                            ],
                          ),
                    Gap(30)
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
