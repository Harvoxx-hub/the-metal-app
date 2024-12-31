import 'package:flutter/material.dart';

import '../res/colors/cr_colors.dart';

class DashProgressIndicator extends StatelessWidget {
  final int pageCount; // Total number of pages in onboarding
  final int currentPage; // Current page index
  final double? width;
  const DashProgressIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        pageCount,
        (index) {
          return Container(
            width: 7.0,
            height: 7.0,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              color: currentPage == index
                  ? AppColors.metalBrownColour
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(20.0),
            ),
          );
        },
      ),
    );
  }
}
