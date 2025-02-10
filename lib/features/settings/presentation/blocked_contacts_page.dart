import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

class BlockedContactsPage extends ConsumerStatefulWidget {
  const BlockedContactsPage({super.key});
  static const name = 'BlockedContactsPage';
  static const route = name;

  @override
  ConsumerState<BlockedContactsPage> createState() =>
      _BlockedContactsPageState();
}

class _BlockedContactsPageState extends ConsumerState<BlockedContactsPage> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider).data;
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
                      child: Image.asset(
                        Assets.images.chatSmilingFaceEmoji1.path,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 20),
                        itemCount: 20,
                        itemBuilder: (context, index) => Container(
                          color: AppColors.metalWhite,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ProfilePhoto(
                                  verfly: false,
                                  size: 51,
                                  meltId: authState!.metal!,
                                  imgUrl: authState.profilePhoto,
                                ),
                                const Gap(10),
                                TextView(
                                  text: authState.fullname!,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: AppColors.metalBrownColourForText,
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                        ),
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
