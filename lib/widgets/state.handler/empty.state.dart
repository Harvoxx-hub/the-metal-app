import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/text_views.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          Assets.gifs.empty.path,
          height: 250,
          width: 250,
        ),
        const Gap(46),
        TextView(
          textAlign: TextAlign.center,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          text: text,
        ),
      ],
    );
  }
}
