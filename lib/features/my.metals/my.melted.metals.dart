import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';

import 'package:metal/features/home_page/provider/get.melt.users.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/my.metals/widget/melt.card.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/widgets/state.handler/error.state.dart';

class MyMeltedMetals extends ConsumerStatefulWidget {
  const MyMeltedMetals({super.key});
  static const name = 'meltedPage';
  static const route = name;

  @override
  ConsumerState<MyMeltedMetals> createState() => _MyMeltedMetalsState();
}

class _MyMeltedMetalsState extends ConsumerState<MyMeltedMetals> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final myMelt = ref.watch(getMeltUserProvider);

    return BaseScreen(
      subAppBar: false,
      appBarState: AppBarState.HambugerWithHeader,
      Header: "melted metal",
      body: myMelt.isLoading
          ? const Center(child: CircularProgressIndicator())
          : myMelt.isError
              ? ErrorState(
                  retry: () {
                    ref.read(getMeltUserProvider.notifier).getMeltUsers();
                  },
                  text: myMelt.errorMessage,
                )
              : myMelt.data != null && myMelt.data!.isNotEmpty
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          Assets.images.heartLocks1.path,
                          height: 138,
                          width: 138,
                        ),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: myMelt.data!.length,
                            itemBuilder: (context, index) {
                              return MeltCard(
                                user: myMelt.data![index],
                              );
                            },
                          ),
                        )
                      ],
                    )
                  : const EmptyState(text: "You have no melted metals yet"),
    );
  }
}
