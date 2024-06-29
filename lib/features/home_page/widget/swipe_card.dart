import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class SwipeCard extends StatefulWidget {
  final Widget child;
  final void Function(Offset finalPosition)? onSwipeLeft;

  const SwipeCard({
    required this.child,
    this.onSwipeLeft,
    Key? key,
  }) : super(key: key);

  @override
  SwipeCardState createState() => SwipeCardState();
}

class SwipeCardState extends State<SwipeCard> {
  double _positionY = 0;
  double _positionX = 0;
  int _duration = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        onPanStart: _onPanStart,
        onPanEnd: _onPanEnd,
        onPanUpdate: _onPanUpdate,
        child: AnimatedPositioned(
          duration: Duration(milliseconds: _duration),
          top: _positionY,
          left: _positionX,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: constraints.maxHeight,
              maxWidth: constraints.maxWidth,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _positionX += details.delta.dx;
      _positionY += details.delta.dy;
    });
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _duration = 0;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    var newX = 0.0;
    var newY = 0.0;

    setState(() {
      _positionX = newX;
      _positionY = newY;
      _duration = 100;
    });

    if (widget.onSwipeLeft != null) {
      Future.delayed(Duration(milliseconds: 100), () {
        widget.onSwipeLeft!(Offset(-MediaQuery.of(context).size.width, 0));
      });
    }
  }

  void swipeLeft() {
    print("object");
    setState(() {
      _positionX = -MediaQuery.of(context).size.width;
      _positionY = 0;
      _duration = 1000;
    });
  }
}
