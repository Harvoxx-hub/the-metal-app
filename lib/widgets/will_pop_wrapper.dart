import 'package:flutter/material.dart';

typedef BackPressedCallback = Future<bool> Function();

class WillPopWrapper extends StatelessWidget {
  const WillPopWrapper({
    required this.child,
    super.key,
    this.blocked = false,
    this.onBackPressed,
  });

  final bool blocked;
  final Widget child;
  final BackPressedCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return blocked
        ? WillPopScope(
            onWillPop: () => onBackPressed?.call() ?? Future.value(false),
            child: child,
          )
        : child;
  }
}
