import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced SwipeCard with Tinder-like feedback interactions
/// Implements gesture detection, real-time visual feedback, and smooth animations
///
/// Uses ValueNotifiers instead of setState during drag to avoid rebuilding
/// the child widget tree on every pointer-move frame.
class EnhancedSwipeCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;
  final String? swipeUpLabelText;
  final IconData? swipeUpIcon;
  final Color? swipeUpColor;
  final double swipeThreshold;
  final double velocityThreshold;
  final Duration animationDuration;

  const EnhancedSwipeCard({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.swipeUpLabelText,
    this.swipeUpIcon,
    this.swipeUpColor,
    this.swipeThreshold = 120.0,
    this.velocityThreshold = 500.0,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<EnhancedSwipeCard> createState() => _EnhancedSwipeCardState();
}

class _EnhancedSwipeCardState extends State<EnhancedSwipeCard>
    with TickerProviderStateMixin {
  late AnimationController _positionController;
  late AnimationController _rotationController;
  late AnimationController _opacityController;

  late Animation<Offset> _positionAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  final ValueNotifier<Offset> _dragOffset = ValueNotifier(Offset.zero);
  final ValueNotifier<bool> _isDragging = ValueNotifier(false);
  final ValueNotifier<SwipeDirection?> _currentDirection = ValueNotifier(null);

  double _velocityX = 0.0;
  double _velocityY = 0.0;
  bool _hasTriggeredHaptic = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _positionController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _opacityController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.easeOutCubic,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOutCubic,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _opacityController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _positionController.dispose();
    _rotationController.dispose();
    _opacityController.dispose();
    _dragOffset.dispose();
    _isDragging.dispose();
    _currentDirection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([
                  _positionAnimation,
                  _rotationAnimation,
                  _dragOffset,
                ]),
                child: widget.child,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _dragOffset.value.dx + _positionAnimation.value.dx,
                      _dragOffset.value.dy + _positionAnimation.value.dy,
                    ),
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight,
                          maxWidth: constraints.maxWidth,
                        ),
                        child: Stack(
                          children: [
                            child!,
                            ValueListenableBuilder<bool>(
                              valueListenable: _isDragging,
                              builder: (context, dragging, _) {
                                if (!dragging) return const SizedBox.shrink();
                                return _buildFeedbackOverlay();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeedbackOverlay() {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: ValueListenableBuilder<SwipeDirection?>(
            valueListenable: _currentDirection,
            builder: (context, direction, _) {
              return Stack(
                children: [
                  if (direction == SwipeDirection.right)
                    Positioned(
                      left: 20,
                      top: 0,
                      child: Center(
                        child: _buildFeedbackLabel(
                          text: 'LIKE',
                          color: Colors.green,
                          icon: Icons.favorite,
                        ),
                      ),
                    ),
                  if (direction == SwipeDirection.left)
                    Positioned(
                      right: 20,
                      top: 0,
                      child: Center(
                        child: _buildFeedbackLabel(
                          text: 'NOPE',
                          color: Colors.red,
                          icon: Icons.close,
                        ),
                      ),
                    ),
                  if (direction == SwipeDirection.up)
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _buildFeedbackLabel(
                          text: widget.swipeUpLabelText ?? 'SUPER LIKE',
                          color: widget.swipeUpColor ?? Colors.blue,
                          icon: widget.swipeUpIcon ?? Icons.star,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFeedbackLabel({
    required String text,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    _isDragging.value = true;
    _hasTriggeredHaptic = false;
    _currentDirection.value = null;

    _positionController.reset();
    _rotationController.reset();
    _opacityController.reset();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _dragOffset.value = Offset(
      _dragOffset.value.dx + details.delta.dx,
      _dragOffset.value.dy + details.delta.dy,
    );

    _velocityX = details.delta.dx;
    _velocityY = details.delta.dy;

    _updateSwipeDirection();
    _updateRotation();
    _updateOpacity();
    _checkHapticFeedback();
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging.value = false;

    final velocity = details.velocity.pixelsPerSecond;
    _velocityX = velocity.dx;
    _velocityY = velocity.dy;

    final swipeAction = _determineSwipeAction();

    if (swipeAction != null) {
      _executeSwipeAction(swipeAction);
    } else {
      _snapBackToCenter();
    }
  }

  void _updateSwipeDirection() {
    final dx = _dragOffset.value.dx;
    final dy = _dragOffset.value.dy;
    final absX = dx.abs();
    final absY = dy.abs();

    if (absX > absY) {
      _currentDirection.value =
          dx > 0 ? SwipeDirection.right : SwipeDirection.left;
    } else if (dy < 0 && absY > 50) {
      _currentDirection.value = SwipeDirection.up;
    } else {
      _currentDirection.value = null;
    }
  }

  void _updateRotation() {
    final rotationAngle = _dragOffset.value.dx / 20;
    _rotationController.value = rotationAngle.clamp(-0.3, 0.3);
  }

  void _updateOpacity() {
    final maxDistance = widget.swipeThreshold;
    final dx = _dragOffset.value.dx;
    final dy = _dragOffset.value.dy;
    final currentDistance = sqrt(dx * dx + dy * dy);
    final opacity = (currentDistance / maxDistance).clamp(0.0, 1.0);
    _opacityController.value = opacity;
  }

  void _checkHapticFeedback() {
    if (_hasTriggeredHaptic) return;

    final dx = _dragOffset.value.dx;
    final dy = _dragOffset.value.dy;
    final distance = sqrt(dx * dx + dy * dy);
    if (distance > widget.swipeThreshold * 0.7) {
      HapticFeedback.mediumImpact();
      _hasTriggeredHaptic = true;
    }
  }

  SwipeDirection? _determineSwipeAction() {
    final dx = _dragOffset.value.dx;
    final dy = _dragOffset.value.dy;
    final absX = dx.abs();
    final absVelocityX = _velocityX.abs();
    final absVelocityY = _velocityY.abs();

    if (absX > widget.swipeThreshold ||
        absVelocityX > widget.velocityThreshold) {
      return dx > 0 ? SwipeDirection.right : SwipeDirection.left;
    }

    if (dy < -widget.swipeThreshold ||
        absVelocityY > widget.velocityThreshold) {
      return SwipeDirection.up;
    }

    return null;
  }

  void _executeSwipeAction(SwipeDirection direction) {
    final screenSize = MediaQuery.sizeOf(context);
    final dx = _dragOffset.value.dx;
    final dy = _dragOffset.value.dy;
    Offset targetPosition;

    switch (direction) {
      case SwipeDirection.left:
        targetPosition = Offset(-screenSize.width * 1.5, dy);
        break;
      case SwipeDirection.right:
        targetPosition = Offset(screenSize.width * 1.5, dy);
        break;
      case SwipeDirection.up:
        targetPosition = Offset(dx, -screenSize.height * 1.5);
        break;
    }

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: targetPosition,
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.easeInCubic,
    ));

    _positionController.forward().then((_) {
      switch (direction) {
        case SwipeDirection.left:
          widget.onSwipeLeft?.call();
          break;
        case SwipeDirection.right:
          widget.onSwipeRight?.call();
          break;
        case SwipeDirection.up:
          widget.onSwipeUp?.call();
          break;
      }
    });
  }

  void _snapBackToCenter() {
    final oldOffset = _dragOffset.value;

    _positionAnimation = Tween<Offset>(
      begin: oldOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: _rotationController.value,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: _opacityController.value,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _opacityController,
      curve: Curves.easeOut,
    ));

    _positionController.forward();
    _rotationController.forward();
    _opacityController.forward();

    _dragOffset.value = Offset.zero;
    _currentDirection.value = null;
  }

  void swipeLeft() => _executeSwipeAction(SwipeDirection.left);
  void swipeRight() => _executeSwipeAction(SwipeDirection.right);
  void swipeUp() => _executeSwipeAction(SwipeDirection.up);
}

enum SwipeDirection {
  left,
  right,
  up,
}
