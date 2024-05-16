import 'package:flutter/material.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

class SparkCardItem extends StatelessWidget {
  const SparkCardItem(
      {super.key,
      required this.title,
      required this.path,
      required this.onTap});
  final String title;
  final String path;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(path),
          TextView(
            text: title,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.metalWhite,
          )
        ],
      ),
    );
  }
}
