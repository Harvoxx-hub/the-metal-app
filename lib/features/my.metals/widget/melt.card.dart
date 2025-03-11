import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/home_page/domain/entries/connection.model.dart';
import 'package:metal/features/home_page/provider/get.user.notifier.dart';

import 'package:metal/route/routes.dart';
import 'package:metal/widgets/card.with.shadow.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

class MeltCard extends ConsumerWidget {
  const MeltCard({super.key, required this.user});
  final ConnectionModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).data;
    final metalId = user.users.firstWhere(
      (user) => user != currentUser!.id,
      orElse: () =>
          "", // Handle cases where all user IDs match the current user
    );
    final getUser = ref.watch(getUserProvider(metalId));
    return CardWithShadow(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.myMeltedUser,
            arguments: {"metalId" : metalId}  ,
          );
        },
        height: 105,
        child: getUser.isLoading
            ? const Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ProfilePhoto(
                      size: 56,
                      verfly: false,
                      meltId: getUser.data!.metal!,
                      imgUrl:
                          user.isAnonymous ? null : getUser.data!.profilePhoto),
                  const Gap(23),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      user.isAnonymous
                          ? TextView(
                              text: getUser.data!.username!,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            )
                          : TextView(
                              text: getUser.data!.fullname!,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                      const Gap(5),
                      TextView(
                        text: "-  ${getUser.data!.gender}",
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      const Gap(14),

                      ///TODO: add the melted for marriage
                      TextView(
                        text: "- ${getUser.data!.connectionOption?[0] ?? ""}",
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ],
              ));
  }
}
