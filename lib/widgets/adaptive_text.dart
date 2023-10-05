import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Adaptable text which uses [SelectableText] for Web and
/// [Text] for other platforms.
class AdaptiveText extends StatelessWidget {
  const AdaptiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.softWrap,
    this.maxLines,
    this.useSelectableForWeb = true,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final bool? softWrap;
  final int? maxLines;
  final bool useSelectableForWeb;

  @override
  Widget build(BuildContext context) {
    return kIsWeb && useSelectableForWeb
        ? SelectableText(
            text,
            style: style,
            textAlign: textAlign,
          )
        : Text(
            text,
            style: style,
            textAlign: textAlign,
            softWrap: softWrap,
            overflow: overflow,
            maxLines: maxLines,
          );
  }
}
