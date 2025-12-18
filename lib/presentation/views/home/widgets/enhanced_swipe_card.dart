import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced SwipeCard with Tinder-like feedback interactions
/// Implements gesture detection, real-time visual feedback, and smooth animations
class EnhancedSwipeCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;
  final double swipeThreshold;
  final double velocityThreshold;
  final Duration animationDuration;

  const EnhancedSwipeCard({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.swipeThreshold = 120.0,
    this.velocityThreshold = 500.0,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<EnhancedSwipeCard> createState() => _EnhancedSwipeCardState();
}

class _EnhancedSwipeCardState extends State<EnhancedSwipeCard>
    with TickerProviderStateMixin {
  // Position and animation controllers
  late AnimationController _positionController;
  late AnimationController _rotationController;
  late AnimationController _opacityController;

  // Animations
  late Animation<Offset> _positionAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  // Gesture tracking
  double _dragX = 0.0;
  double _dragY = 0.0;
  double _velocityX = 0.0;
  double _velocityY = 0.0;

  // State tracking
  bool _isDragging = false;
  bool _hasTriggeredHaptic = false;

  // Feedback labels
  SwipeDirection? _currentDirection;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Position animation controller
    _positionController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Rotation animation controller
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Opacity animation controller
    _opacityController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Position animation
    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.easeOutCubic,
    ));

    // Rotation animation
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOutCubic,
    ));

    // Opacity animation
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
              // Main card with animations
              AnimatedBuilder(
                animation: Listenable.merge([
                  _positionAnimation,
                  _rotationAnimation,
                ]),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _dragX + _positionAnimation.value.dx,
                      _dragY + _positionAnimation.value.dy,
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
                            // Main card content
                            widget.child,

                            // Feedback labels overlay
                            if (_isDragging) _buildFeedbackOverlay(),
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

  /// Build feedback overlay with LIKE/NOPE/SUPER LIKE labels
  Widget _buildFeedbackOverlay() {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Stack(
            children: [
              // LIKE label (right side)
              if (_currentDirection == SwipeDirection.right)
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

              // NOPE label (left side)
              if (_currentDirection == SwipeDirection.left)
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

              // SUPER LIKE label (top)
              if (_currentDirection == SwipeDirection.up)
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildFeedbackLabel(
                      text: 'SUPER LIKE',
                      color: Colors.blue,
                      icon: Icons.star,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Build individual feedback label
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

  /// Handle pan start
  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
    _hasTriggeredHaptic = false;
    _currentDirection = null;

    // Reset animations
    _positionController.reset();
    _rotationController.reset();
    _opacityController.reset();
  }

  /// Handle pan update with real-time feedback
  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragX += details.delta.dx;
      _dragY += details.delta.dy;

      // Calculate velocity
      _velocityX = details.delta.dx;
      _velocityY = details.delta.dy;

      // Determine swipe direction and update feedback
      _updateSwipeDirection();

      // Update rotation based on horizontal drag
      _updateRotation();

      // Update opacity based on drag distance
      _updateOpacity();

      // Trigger haptic feedback when crossing threshold
      _checkHapticFeedback();
    });
  }

  /// Handle pan end with swipe decision
  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;

    // Calculate final velocity
    final velocity = details.velocity.pixelsPerSecond;
    _velocityX = velocity.dx;
    _velocityY = velocity.dy;

    // Determine final swipe action
    final swipeAction = _determineSwipeAction();

    if (swipeAction != null) {
      _executeSwipeAction(swipeAction);
    } else {
      _snapBackToCenter();
    }
  }

  /// Update swipe direction based on current drag position
  void _updateSwipeDirection() {
    final absX = _dragX.abs();
    final absY = _dragY.abs();

    if (absX > absY) {
      // Horizontal swipe
      if (_dragX > 0) {
        _currentDirection = SwipeDirection.right;
      } else {
        _currentDirection = SwipeDirection.left;
      }
    } else if (_dragY < 0 && absY > 50) {
      // Vertical swipe up
      _currentDirection = SwipeDirection.up;
    } else {
      _currentDirection = null;
    }
  }

  /// Update rotation based on horizontal drag
  void _updateRotation() {
    final rotationAngle =
        _dragX / 20; // Adjust divisor for rotation sensitivity
    _rotationController.value = rotationAngle.clamp(-0.3, 0.3);
  }

  /// Update opacity based on drag distance
  void _updateOpacity() {
    final maxDistance = widget.swipeThreshold;
    final currentDistance = sqrt(_dragX * _dragX + _dragY * _dragY);
    final opacity = (currentDistance / maxDistance).clamp(0.0, 1.0);
    _opacityController.value = opacity;
  }

  /// Check and trigger haptic feedback
  void _checkHapticFeedback() {
    if (_hasTriggeredHaptic) return;

    final distance = sqrt(_dragX * _dragX + _dragY * _dragY);
    if (distance > widget.swipeThreshold * 0.7) {
      HapticFeedback.mediumImpact();
      _hasTriggeredHaptic = true;
    }
  }

  /// Determine final swipe action based on position and velocity
  SwipeDirection? _determineSwipeAction() {
    final absX = _dragX.abs();
    final absVelocityX = _velocityX.abs();
    final absVelocityY = _velocityY.abs();

    // Check horizontal swipes
    if (absX > widget.swipeThreshold ||
        absVelocityX > widget.velocityThreshold) {
      return _dragX > 0 ? SwipeDirection.right : SwipeDirection.left;
    }

    // Check vertical swipe up
    if (_dragY < -widget.swipeThreshold ||
        absVelocityY > widget.velocityThreshold) {
      return SwipeDirection.up;
    }

    return null;
  }

  /// Execute the determined swipe action
  void _executeSwipeAction(SwipeDirection direction) {
    final screenSize = MediaQuery.of(context).size;
    Offset targetPosition;

    switch (direction) {
      case SwipeDirection.left:
        targetPosition = Offset(-screenSize.width * 1.5, _dragY);
        break;
      case SwipeDirection.right:
        targetPosition = Offset(screenSize.width * 1.5, _dragY);
        break;
      case SwipeDirection.up:
        targetPosition = Offset(_dragX, -screenSize.height * 1.5);
        break;
    }

    // Animate to target position
    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: targetPosition,
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.easeInCubic,
    ));

    _positionController.forward().then((_) {
      // Trigger callback
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

  /// Snap card back to center
  void _snapBackToCenter() {
    // Reset position animation
    _positionAnimation = Tween<Offset>(
      begin: Offset(_dragX, _dragY),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.elasticOut,
    ));

    // Reset rotation animation
    _rotationAnimation = Tween<double>(
      begin: _rotationController.value,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.elasticOut,
    ));

    // Reset opacity animation
    _opacityAnimation = Tween<double>(
      begin: _opacityController.value,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _opacityController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _positionController.forward();
    _rotationController.forward();
    _opacityController.forward();

    // Reset drag values
    setState(() {
      _dragX = 0.0;
      _dragY = 0.0;
      _currentDirection = null;
    });
  }

  /// Programmatic swipe methods
  void swipeLeft() {
    _executeSwipeAction(SwipeDirection.left);
  }

  void swipeRight() {
    _executeSwipeAction(SwipeDirection.right);
  }

  void swipeUp() {
    _executeSwipeAction(SwipeDirection.up);
  }
}

/// Swipe direction enum
enum SwipeDirection {
  left,
  right,
  up,
}

