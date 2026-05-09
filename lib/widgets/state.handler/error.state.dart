import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/button/outiline.button.dart';
import 'package:metal/widgets/text_views.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.retry,
    this.text,
    this.retryButtonText = 'Try Again',
  });
  final Function() retry;
  final String? text;
  final String retryButtonText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Gap(10),
          Assets.gifs.error.image(),
          const Gap(30),
          const TextView(
            text: "Error",
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          const Gap(10),
          TextView(
            text: text ?? "Connection Could not be made",
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          const Gap(10),
          OutilineButton(
            buttonText: retryButtonText,
            onPressed: retry,
          ),
        ],
      ),
    );
  }
}
