import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/pages/authentication/models/passion.card.model.dart';
import 'package:metal/pages/authentication/presentation/profile.setting/connection.option.dart';
import 'package:metal/pages/authentication/presentation/widget/create.profile.header1.dart';
import 'package:metal/pages/authentication/presentation/widget/create.profile.header2.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/utils/screen.size.dart';
import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';

import '../../../../widgets/dropdown/metal.dropdown.dart';
import '../widget/passions.card.dart';

class MoreAboutYouPage extends ConsumerStatefulWidget {
  MoreAboutYouPage({Key? key}) : super(key: key);
  static const name = 'moreAboutYou';
  static const route = '$name';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MoreAboutYouPageState();
}

class _MoreAboutYouPageState extends ConsumerState<MoreAboutYouPage> {
  String? maritalStatus;
  String? religion;
  String? profession;
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
                floatingLabel: 'Please Select your Date Of Birth',
                label:
                    'I term myself a Aluminium because I am light and emotional. I like to be cared for as I have some tendencies to get rusty',
                //  controller: _dobController,
                keyboardType: TextInputType.name,
                minLines: 15,
                maxLines: 15,
                // validator: EmailValidator.validate(email),
                radius: 10,

                // fillColor: AppColors.appGrey,
              ),
              Gap(20),
              BaseButton(
                buttonText: "Next 5/5",
                onPressed: _onNextPressed,
              ),
            ],
          ),
        ));
  }

  void _onNextPressed() {
    context.pushNamed(ConnectionOptionsPage.name);
  }
}
