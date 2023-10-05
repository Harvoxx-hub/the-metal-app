 
import 'package:flutter/material.dart';
import 'package:metal/res/res.dart';
import 'package:metal/widgets/text_views.dart';

class ButtonDivider extends StatelessWidget {
  const ButtonDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return  Row(
      children: [
        Expanded(
          child: Divider(
            color: CRColors.wGray3,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: TextView(text: 'Or')
        ),
        Expanded(
          child: Divider(
            color: CRColors.wGray3,
          ),
        ),
      ],
    );
  }
}
