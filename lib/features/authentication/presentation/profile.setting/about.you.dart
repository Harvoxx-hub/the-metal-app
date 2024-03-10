import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/metal.properties.notifier.dart';
import 'package:metal/features/authentication/provider/update.profile.notifier.dart';
import 'package:metal/gen/assets.gen.dart';

import 'package:metal/features/authentication/presentation/profile.setting/more.about.you.dart';
import 'package:metal/features/authentication/presentation/widget/create.profile.header2.dart';
import 'package:metal/route/routes.dart';

import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/dropdown/metal.dropdownMutipleSelection.dart';

import '../../../../widgets/dropdown/metal.dropdown.dart';

class AboutYouPage extends ConsumerStatefulWidget {
  AboutYouPage({Key? key}) : super(key: key);
  static const name = 'aboutYou';
  static const route = '$name';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AboutYouPageState();
}

class _AboutYouPageState extends ConsumerState<AboutYouPage> {
  String? maritalStatus;
  String? religion;
  String? profession;
  List<String>? language;
  @override
  Widget build(BuildContext context) {
    final _metalProps = ref.watch(metalPropertiesProvider);
    return BaseScreen(
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        Header: 'About You',
        authFlow: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              CreateProfileHeader2(
                  path: Assets.images.aboutYou.path,
                  title: "Just a little more about you",
                  subtitle:
                      "The more we know you, the easier it is to match you!"),
              Gap(40.h),
              MentalDropdown(
                items: _metalProps.data!.marriageStatus!,
                onChanged: (String? value) {
                  setState(() {
                    maritalStatus = value;
                  });
                },
                prefixIcon: Assets.icons.single.svg(width: 24, height: 24),
                value: maritalStatus,
                hint: "Please Select",
                floatingLabel: "Marital Status",
              ),
              Gap(22.h),
              MentalDropdown(
                items: _metalProps.data!.religion!,
                onChanged: (String? value) {
                  setState(() {
                    religion = value;
                  });
                },
                prefixIcon:
                    Assets.icons.christianity.svg(width: 24, height: 24),
                value: religion,
                hint: "Please Select",
                floatingLabel: "Religon",
              ),
              Gap(22.h),
              MentalDropdown(
                items: _metalProps.data!.profession!,
                onChanged: (String? value) {
                  setState(() {
                    profession = value;
                  });
                },
                prefixIcon: Assets.icons.profession.svg(width: 24, height: 24),
                value: profession,
                hint: "Please Select",
                floatingLabel: "Profession",
              ),
              Gap(22.h),
              MentalDropdownMutipleSelection(
                items: _metalProps.data!.language!,
                onChanged: (List? value) {
                  setState(() {
                    language = value!.cast<String>();
                  });
                },
                prefixIcon: Assets.icons.profession.svg(width: 24, height: 24),
                value: language,
                hint: "Please Select",
                floatingLabel: "language",
              ),
              Gap(20),
              BaseButton(
                enabled: language != null &&
                    language!.isNotEmpty &&
                    maritalStatus != null &&
                    religion != null &&
                    profession != null,
                buttonText: "Next 4/5",
                onPressed: _onNextPressed,
              ),
            ],
          ),
        ));
  }

  void _onNextPressed() {
    final userData = ref.watch(updateProfileProvider).data;
    final ExtraData extraData = ExtraData();
    extraData.marital_status = maritalStatus;
    extraData.religion = religion;
    extraData.profession = profession;
    extraData.language = language!.join(',');
    userData!.extra_data = extraData;

    
    ref.read(updateProfileProvider.notifier).updateUserData(userData);
    Navigator.pushNamed(context, AppRoutes.moreAboutYouPage,  
                 );
 
  }
}
