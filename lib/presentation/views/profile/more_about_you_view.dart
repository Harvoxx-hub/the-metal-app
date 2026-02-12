import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/strings/app_strings.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';

/// More About You View - Step 5 of profile setup
/// Now redirects to Prompt Creation (replaces Bio/Description)
class MoreAboutYouView extends ConsumerStatefulWidget {
  const MoreAboutYouView({super.key});
  static const name = 'moreAboutYou';
  static const route = '/$name';

  @override
  ConsumerState<MoreAboutYouView> createState() => _MoreAboutYouViewState();
}

class _MoreAboutYouViewState extends ConsumerState<MoreAboutYouView> {
  @override
  void initState() {
    super.initState();
    // Automatically navigate to prompt creation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.promptCreationPage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while navigating
    return BaseScreen(
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: AppStrings.moreAboutYou,
      authFlow: true,
      body: const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
