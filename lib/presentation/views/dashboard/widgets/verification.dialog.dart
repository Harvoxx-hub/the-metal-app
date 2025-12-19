import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

// TODO: Re-implement video verification in new architecture
// import 'package:metal/features/verification/provider/verification.notifier.dart';
import 'package:metal/presentation/viewmodels/verification/work_email_verification_viewmodel.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerificationDialog extends ConsumerStatefulWidget {
  const VerificationDialog({super.key});

  @override
  ConsumerState<VerificationDialog> createState() => _VerificationDialogState();
}

class _VerificationDialogState extends ConsumerState<VerificationDialog> {
  String? livenessStatus;
  //final _faceSDKService = FaceSDKService();
  Uint8List? capturedImage;

  var _status = "nil";

  set status(String val) => setState(() => _status = val);

  @override
  void initState() {
    super.initState();
    //  _initialize();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Re-implement video verification provider
    // final verificationState = ref.watch(verficationVideoProvider);
    final verificationState = ref.watch(workEmailVerificationViewModelProvider);

    // ref.listen<VerificationState>(verficationVideoProvider, (prev, current) {
    //   if (current.isSuccess) {
    //     Navigator.pop(context);
    //     Navigator.pop(context);
    //   }
    // });
    ref.listen<WorkEmailVerificationState>(workEmailVerificationViewModelProvider, (prev, current) {
      if (current.isVerified) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    });
    return Column(
      children: [
        const Gap(38),
        Assets.images.checkVerified.image(),
        const Gap(15),
        const TextView(
          text: "Confirmation",
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        const Gap(15),
        const TextView(
          text:
              "Verifying your identity means telling other metals that you are authentic, and your information is accurate which helps to increase your chances for real connections and we can vouch that we know you.",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(38),
        BaseButton(
          buttonText: "Verify Me",
          loading: verificationState.isLoading,
          onPressed: () async {
            Navigator.pop(context);
            Navigator.pushNamed(context, AppRoutes.workEmail);
          },
        ),
        const Gap(23),
        TextView(
          text: "Skip for Now",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          onTap: () => Navigator.pop(context),
        ),
        const Gap(21),
      ],
    );
  }
}
