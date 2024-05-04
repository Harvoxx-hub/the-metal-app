import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/core/utils/screen.size.dart';
import 'package:metal/features/home_page/provider/get.melt.users.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/my.metals/widget/melt.card.dart';

import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

class MyMeltedMetals extends ConsumerWidget {
  const MyMeltedMetals({super.key});
  static const name = 'meltedPage';
  static const route = '$name';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myMelt = ref.watch(getMeltUserProvider);
    return BaseScreen(
        subAppBar: true,
        appBarState: AppBarState.HambugerWithHeader,
        Header: "My melted metals",
        body: SingleChildScrollView(
          child: myMelt.isLoading
              ? const Center(child: CircularProgressIndicator())
              : myMelt.data != null && myMelt.data!.isNotEmpty
                  ? Column(
                      children: [
                        Image.asset(
                          Assets.images.heartLocks1.path,
                          height: 138,
                          width: 138,
                        ),
                        SizedBox(
                          height: getDeviceHeight(context) / 1.2,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: myMelt.data!.length,
                            itemBuilder: (context, index) {
                              return MeltCard(
                                user: myMelt.data![index]!,
                              );
                            },
                          ),
                        )
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          Assets.gifs.empty.path,
                          height: 250,
                          width: 250,
                        ),
                        const Gap(46),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextView(
                              textAlign: TextAlign.center,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              text: "You have no melted metals yet",
                            ),
                          ],
                        ),
                      ],
                    ),
        ));
  }
}
