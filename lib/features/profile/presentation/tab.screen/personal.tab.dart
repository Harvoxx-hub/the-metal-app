import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/svg.dart';

import 'package:metal/features/profile/presentation/widget/edit.profile.dart';

import 'package:metal/gen/assets.gen.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';

import 'package:metal/widgets/button/plain.button.dart';

class PersonalTab extends ConsumerStatefulWidget {
  const PersonalTab({super.key});

  @override
  ConsumerState<PersonalTab> createState() => _PersonalTabState();
}

class _PersonalTabState extends ConsumerState<PersonalTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const EditProfile(),
        PlainButton(
          buttonText: "Delete my account",
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.delete);
          },
          textColor: AppColors.metalWhite,
          color: AppColors.metalRed,
          leftIcon: SvgPicture.asset(
            Assets.icons.profileTrash.path,
            height: 24,
            width: 24,
          ),
        )
      ],
    );
  }
}
