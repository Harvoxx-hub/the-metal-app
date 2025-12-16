import 'package:flutter/material.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/res/colors/cr_colors.dart';

/// A simple widget that displays text with a "Read more" button when truncated
class ReadMoreText extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;

  const ReadMoreText({
    super.key,
    required this.text,
    this.onTap,
  });

  @override
  State<ReadMoreText> createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText> {
  bool _showReadMore = false;
  final GlobalKey _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkIfTruncated());
  }

  void _checkIfTruncated() {
    final renderBox = _textKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: const TextStyle(fontSize: 14, fontFamily: 'Plus_Jakarta'),
      ),
      maxLines: 3,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: renderBox.constraints.maxWidth);

    if (mounted && textPainter.didExceedMaxLines != _showReadMore) {
      setState(() {
        _showReadMore = textPainter.didExceedMaxLines;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _checkIfTruncated());

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              key: _textKey,
              width: constraints.maxWidth,
              child: TextView(
                text: widget.text,
                maxLines: 3,
                textOverflow: TextOverflow.ellipsis,
              ),
            ),
            if (_showReadMore) ...[
              const SizedBox(height: 6),
              GestureDetector(
                onTap: widget.onTap,
                child: TextView(
                  text: 'Read more',
                  fontSize: 12,
                  color: AppColors.metalPinkColour,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
