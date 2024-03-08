import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/profile/widget/edit.field.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/profile/update.email/update.email.page.dart';
import 'package:metal/features/profile/update.phone.number/update.phone.number.page.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';

class PersonalTab extends ConsumerStatefulWidget {
  const PersonalTab({super.key});

  @override
  ConsumerState<PersonalTab> createState() => _PersonalTabState();
}

class _PersonalTabState extends ConsumerState<PersonalTab> {
 
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authProvider).data;
    return Column(
      children: [
        EditField(
          text: userState?.fullname ?? " Your name here",
          floatingLabel: "First name & Last name",
        ),
        Gap(20.h),
        EditField(
          text: "@${userState?.username}" ?? "Username",
          floatingLabel: "Username",
        ),
        Gap(20.h),
        EditField(
          text: userState?.email ?? "Email address",
          floatingLabel: "Email address",
          subLabel: "Edit",
          onSubLabel: () {
            context.pushNamed(UpdateEmailPage.name);
          },
        ),
        Gap(20.h),
        EditField(
          text: userState?.phone ?? "Phone Number",
          floatingLabel: "Phone Number",
          subLabel: "Edit",
          onSubLabel: () {
            context.pushNamed(UpdatePhoneNumberPage.name);
          },
        ),
        Gap(20.h),
        EditField(
          text: userState?.gender ?? "Gender",
          floatingLabel: "Gender",
          subLabel: "Edit",
          onSubLabel: () {},
        ),
        Gap(20.h),
        EditField(
          text: userState?.metal?.title ?? "Metal that represents your value",
          floatingLabel: " Metal that represents your value",
          subLabel: "Edit",
          onSubLabel: () {},
        ),
        Gap(20.h),
        EditField(
          text: userState?.passion?.join(",") ?? "Passion/Interest",
          floatingLabel: "Passion/Interest",
          subLabel: "Edit",
          onSubLabel: () {},
        ),
        Gap(20.h),
        EditField(
          text: userState?.extra_data?.marital_status ?? "Marital status",
          floatingLabel: "Marital status",
          subLabel: "Edit",
          onSubLabel: () {},
        ),
        Gap(20.h),
        EditField(
          text: userState?.extra_data?.religion ?? "Religion",
          floatingLabel: "Religion",
          subLabel: "Edit",
          onSubLabel: () {},
        ),
        Gap(20.h),
        EditField(
          text: "Home address details",
          floatingLabel: "Home address details",
          subLabel: "Edit",
          onSubLabel: () {},
        ),

        Gap(20.h),
        EditField(
          text: userState?.extra_data?.profession ?? "Proffession",
          floatingLabel: "Proffession",
          subLabel: "Edit",
          onSubLabel: () {},
        ),

        // Gap(20.h),
        // EditFormField(
        //   floatingLabel: 'Interested in',
        //   label: 'Interested in',
        //   controller: _intrestedInController,
        //   keyboardType: TextInputType.name,
        //   radius: 10,
        //   editButton: true,
        //   onEditTap: () {},
        // ),
        Gap(20.h),
        EditField(
          text: userState?.description ?? "Little Bio about me",
          floatingLabel: "Little Bio about me",
          subLabel: "Edit",
          onSubLabel: () {},
        ),

        Gap(20.h),
        PlainButton(
          buttonText: "Delete my account",
          onPressed: () {},
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
