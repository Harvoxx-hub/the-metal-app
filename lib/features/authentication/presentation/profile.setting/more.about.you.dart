import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/update.profile.notifier.dart';
import 'package:metal/gen/assets.gen.dart';

import 'package:metal/features/authentication/presentation/profile.setting/connection.option.dart';
import 'package:metal/features/authentication/presentation/widget/create.profile.header2.dart';

import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';

class MoreAboutYouPage extends ConsumerStatefulWidget {
  MoreAboutYouPage({Key? key}) : super(key: key);
  static const name = 'moreAboutYou';
  static const route = '$name';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MoreAboutYouPageState();
}

class _MoreAboutYouPageState extends ConsumerState<MoreAboutYouPage> {
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        Header: 'More about you',
        authFlow: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              CreateProfileHeader2(
                  path: Assets.images.chooseMetal.path,
                  title:
                      "Anything more, you would love us to know about being an aluminium?",
                  subtitle: "This will be displayed to your matched metals."),
              Gap(22.h),
              EditFormField(
                floatingLabel: '',
                label:
                    'I term myself a Aluminium because I am light and emotional. I like to be cared for as I have some tendencies to get rusty',
                controller: _controller,
                keyboardType: TextInputType.name,
                minLines: 13,
                maxLines: 13,
                validator: Validators.validateString(),
                autoValidate: true,

                // fillColor: AppColors.appGrey,
              ),
              Gap(20),
              BaseButton(
                buttonText: "Next",
                onPressed: _onNextPressed,
              ),
            ],
          ),
        ));
  }

  void _onNextPressed() {
    final userData = ref.watch(updateProfileProvider).data;
    userData!.description = _controller.text;

    ref.read(updateProfileProvider.notifier).updateUserData(userData);
    context.pushNamed(ConnectionOptionsPage.name);
  }
}
