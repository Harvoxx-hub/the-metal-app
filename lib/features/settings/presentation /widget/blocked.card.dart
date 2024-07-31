import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/settings/provider/block.user.notifier.dart';
import 'package:metal/widgets/card.with.shadow.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

class BlockedCard extends ConsumerWidget {
  const BlockedCard({
    super.key,
    required this.name,
    required this.id,
  });
  final String name;
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CardWithShadow(
        onTap: () {
       ref.read(blockUserProvider.notifier).unBlockUser(id);
        },
        height: 105,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const ProfilePhoto(size: 56, verfly: true),
            const Gap(23),
            TextView(
              text: name,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ],
        ));
  }
}
