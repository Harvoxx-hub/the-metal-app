import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/home_page/provider/get.user.notifier.dart';
import 'package:metal/features/settings/provider/block.user.notifier.dart';
import 'package:metal/widgets/card.with.shadow.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

class BlockedCard extends ConsumerWidget {
  const BlockedCard({
    super.key,
    required this.id,
  });

  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
   final creatorUserdata = ref.watch(getUserProvider(id));
    return Center(
       child: creatorUserdata.isLoading
          ? CircularProgressIndicator.adaptive()
          : CardWithShadow(
              onTap: () {
                ref.read(blockUserProvider.notifier).unBlockUser(id);
              },
              height: 105,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
    );
  }
}
