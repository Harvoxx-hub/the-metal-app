import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/pages/authentication/presentation/create.profile/pages/choose.your.metal.dart';
import 'package:metal/pages/authentication/presentation/create.profile/pages/dob.page.dart';
import 'package:metal/pages/authentication/presentation/create.profile/pages/profile.setting.dart';
import 'package:metal/pages/authentication/presentation/welcome/presentation/welcome.page.dart';
import 'package:metal/res/res.dart';
import 'package:metal/utils/screen.size.dart';
import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../widgets/dropdown/metal.dropdown.dart';

class CreateProfilePage extends ConsumerStatefulWidget {
  CreateProfilePage({Key? key}) : super(key: key);
  static const name = 'createProfile';
  static const route = '$name';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateProfilePageState();
}

class _CreateProfilePageState extends ConsumerState<CreateProfilePage> {
  late PageController _controller;
  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: 0,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _pages = [
      ProfileSettingPage(
        onNextPress: nextPage,
      ),
      DobPage(
        onNextPress: nextPage,
      ),
      ChooseYourMetal(
        onNextPress: nextPage,
      )
    ];
  }

  List<Widget> _pages = [];
  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: 'Create Profile',
      authFlow: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(30.h),
          SizedBox(
            height: getDeviceHeight(context) * 0.79,
            child: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _controller,
              onPageChanged: (value) {
                setState(() {
                  currentPage = value;
                });
              },
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }

  void onCompleted(String value, context) {
    print(value);
    context.pushNamed(WelcomePage.name);
  }

  Future<void> nextPage() async {
    setState(() {
      if (_controller.page == 3) {
        // ref.read(gettingStartedControllerProvider.notifier).gettingStarted();
      } else {
        _controller.nextPage(
            duration: const Duration(
              milliseconds: 100,
            ),
            curve: Curves.easeIn);
      }
    });
  }
}
