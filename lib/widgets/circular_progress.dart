import 'dart:math';

import 'package:flutter/material.dart';

/// CircularProgress Class
/// [percentage] from 0 to 100 percentage circle
/// [color] percentage line color
/// [backColor] back circle color
/// [showPercentage] show percentage text
/// [gradient] show gradient instead of color
/// [textStyle] text percentage style
/// [stroke] stroke size
/// [round] round stroke
/// [padding] circle padding
///
/// https://pub.dev/packages/progress_indicator
/// In our version we just change padding of AnimatedBuilder
class CircularProgress extends StatefulWidget {
  const CircularProgress({
    required this.percentage,
    this.color = Colors.orange,
    this.backColor = Colors.transparent,
    this.showPercentage = true,
    this.gradient,
    TextStyle? textStyle,
    this.stroke = 10,
    this.round = true,
    this.padding = const EdgeInsets.all(50),
    this.child,
    this.animationDuration = const Duration(milliseconds: 400),
    super.key,
  }) : textStyle = textStyle ?? const TextStyle(color: Colors.black);

  final double percentage;
  final Color color;
  final Color backColor;
  final bool showPercentage;
  final Gradient? gradient;
  final TextStyle textStyle;
  final double stroke;
  final bool round;
  final EdgeInsets padding;
  final Widget? child;
  final Duration? animationDuration;

  @override
  _CircularProgressState createState() => _CircularProgressState();
}

class _CircularProgressState extends State<CircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late double oldPercentage;

  @override
  void initState() {
    oldPercentage = widget.percentage;
    controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    controller.forward(from: 0);

    final diferencia = widget.percentage - oldPercentage;
    oldPercentage = widget.percentage;
    final child = widget.child;

    return Padding(
      padding: EdgeInsets.all(widget.stroke * 0.5),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (BuildContext context, Widget? child) {
              final text = (widget.showPercentage)
                  ? TextSpan(
                      text:
                          '${((widget.percentage - diferencia) + (diferencia * controller.value)).toInt()} %',
                      style: widget.textStyle,
                    )
                  : null;

              return CustomPaint(
                painter: _Circle(
                  percentage: (widget.percentage - diferencia) +
                      (diferencia * controller.value),
                  color: widget.color,
                  backColor: widget.backColor,
                  text: text,
                  gradient: widget.gradient,
                  stroke: widget.stroke,
                  round: widget.round,
                ),
              );
            },
          ),
          if (child != null) child,
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class _Circle extends CustomPainter {
  _Circle({
    required this.percentage,
    required this.color,
    required this.backColor,
    required this.stroke,
    this.text,
    this.gradient,
    this.round = true,
  });

  final double percentage;
  final Color color;
  final Color backColor;
  final TextSpan? text;
  final Gradient? gradient;
  final double stroke;
  final bool round;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = backColor;

    final center = Offset(size.width * 0.5, size.height * 0.5);
    final radius = min(size.width * 0.5, size.height * 0.5);
    // ignore: prefer-trailing-comma
    canvas.drawCircle(center, radius, paint);

    final paintProgress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = round ? StrokeCap.round : StrokeCap.butt
      ..strokeWidth = stroke;

    final localGradient = gradient;
    if (localGradient != null) {
      final rect = Rect.fromCircle(center: const Offset(0, 0), radius: 360);
      paintProgress.shader = localGradient.createShader(rect);
    } else {
      paintProgress.color = color;
    }

    final arcAngle = pi * 2 * (percentage / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      arcAngle,
      false,
      paintProgress,
    );

    if (text != null) {
      final textPainter =
          TextPainter(text: text, textDirection: TextDirection.ltr)..layout();

      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) * 0.5,
          (size.height - textPainter.height) * 0.5,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
