import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/features/eyes/presentation/eye.select.media.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text_views.dart';

class EyesIntro extends StatelessWidget {
  const EyesIntro({super.key});
  static const name = 'EyesIntro';
  static const route = '$name';

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        subAppBar: true,
        appBarState: AppBarState.BackWithHeader,
        Header: "Eyes",
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Gap(100),
              Assets.images.eyesImage.image(
                height: 200,
                width: 200,
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    TextView(
                      text:
                          "With eyes you can share pictures or video clips of you",
                      fontSize: 18,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.w300,
                    ),
                    Gap(20),
                    TextView(
                      text:
                          "- You can upload a maximum of 1 files or\n UPGRADE to Metal Plus for more.\n - A maximum of 30 secs video clip. \n - Only your melted unmetals can see your \neyes (after 30 days of interacting).",
                      fontSize: 14,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.w300,
                    ),
                    Gap(100),
                    BaseButton(
                        buttonText: "Upload files to eyes",
                        onPressed: () {
                          context.pushNamed(EyeSelectMedia.name);
                        }),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
