import 'package:flutter/material.dart';

import '../res/colors/cr_colors.dart';

class TextView extends StatelessWidget {
  final String text;
  final TextOverflow? textOverflow;
  final TextAlign? textAlign;
  final Color? color;
  final double fontSize;
  final double padding;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final Function()? onTap;
  final int? maxLines;
  final String? fontFamily;
  final bool heading;
  final bool underline;
  final String boldSymbol;

  const TextView({super.key, 
    required this.text,
    this.textOverflow = TextOverflow.clip,
    this.textAlign = TextAlign.left,
    this.color,
    this.onTap,
    this.padding = 0.0,
    this.fontSize = 14.0,
    this.maxLines,
    this.fontWeight = FontWeight.normal,
    this.fontStyle = FontStyle.normal,
    this.fontFamily,
    this.heading = false,
    this.boldSymbol = '*',
    this.underline = false,
  });

  @override
  Widget build(BuildContext context) {
    final List<InlineSpan> textSpans = [];
    final parts = text.split(boldSymbol);
    final defaultStyle = TextStyle(
      fontFamily: fontFamily ?? 'Plus_Jakarta',
      color: color ?? AppColors.metalBlack,
      fontWeight: fontWeight,
      decoration: underline ? TextDecoration.underline : TextDecoration.none,
      fontSize: fontSize,
      fontStyle: fontStyle,
    );

    for (int i = 0; i < parts.length; i++) {
      final isBold = i % 2 == 1;
      final textStyle = isBold
          ? defaultStyle.copyWith(fontWeight: FontWeight.bold)
          : defaultStyle;

      textSpans.add(
        TextSpan(
          text: parts[i],
          style: textStyle,
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: RichText(
          text: TextSpan(
            children: textSpans,
          ),
          textAlign: textAlign!,
          overflow: textOverflow!,
          maxLines: maxLines,
        ),
      ),
    );
  }
}
