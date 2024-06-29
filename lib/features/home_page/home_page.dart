import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/home_page/provider/get.all.users.notifier.dart';
import 'package:metal/features/home_page/widget/thought_card.dart';
import 'package:metal/gen/assets.gen.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
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
  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final allUsers = ref.watch(getAllUserProvider);

    if (allUsers.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return allUsers.data != null && allUsers.data!.isNotEmpty
          ? Column(
              children: [
                Container(
                  height: 50,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.metalPinkColour,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: TextView(
                      text: "Share Your Thought Anonymously",
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Gap(20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const TextView(
                            text: "Feeds",
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          const Spacer(),
                          feed_tab_item(
                            selected: tabIndex == 0,
                            onPress: () {
                              setState(() {
                                tabIndex = 0;
                              });
                            },
                            title: "Explore",
                          ),
                          const Gap(20),
                          feed_tab_item(
                            selected: tabIndex == 1,
                            onPress: () {
                              setState(() {
                                tabIndex = 1;
                              });
                            },
                            title: "For You",
                          ),
                        ],
                      ),
                      EditFormField(
                        floatingLabel: '',
                        label: "Write your thoughts",
                        //  controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        suffixWidget: PlainButton(
                          width: 70,
                          buttonText: "Post",
                          onPressed: () {},
                        ),
                      ),

                      // Expanded widget should be placed in a flexible container
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.639,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return PostCard();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                      text: "No metal users found that match your preference",
                    ),
                    const Gap(20),
                  ],
                ),
              ),
            );
    }
  }
}

class feed_tab_item extends StatelessWidget {
  const feed_tab_item({
    super.key,
    required this.selected,
    required this.title,
    required this.onPress,
  });
  final bool selected;
  final String title;
  final Function() onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: selected ? AppColors.metalPinkColour40 : null,
            border: selected
                ? null
                : Border.all(color: AppColors.metalBlack, width: 1.0),
            borderRadius: BorderRadius.circular(20)),
        child: TextView(
          text: title,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

