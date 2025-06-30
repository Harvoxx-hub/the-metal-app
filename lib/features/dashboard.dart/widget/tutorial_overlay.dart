import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialOverlay extends StatefulWidget {
  final List<TutorialStep> tutorialSteps;
  final VoidCallback onComplete;
  final String tutorialKey;

  const TutorialOverlay({
    Key? key,
    required this.tutorialSteps,
    required this.onComplete,
    required this.tutorialKey,
  }) : super(key: key);

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent overlay
        Positioned.fill(
          child: GestureDetector(
            onTap:
                () {}, // Intercept taps to prevent interaction with elements below
            child: Container(
              color: Color.fromRGBO(
                  0, 0, 0, 0.2), // Use RGBA color with alpha value
            ),
          ),
        ),

        // Current tutorial step
        if (currentStep < widget.tutorialSteps.length)
          TutorialStepWrapper(
            step: widget.tutorialSteps[currentStep],
            onNext: _nextStep,
            onDismiss: _completeTutorial,
          ),
      ],
    );
  }

  void _nextStep() {
    if (currentStep < widget.tutorialSteps.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      _completeTutorial();
    }
  }

  void _completeTutorial() async {
    // Mark this tutorial as seen
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(widget.tutorialKey, true);

    widget.onComplete();
  }
}

// Add a wrapper widget to handle the onNext and onDismiss callbacks
class TutorialStepWrapper extends StatelessWidget {
  final TutorialStep step;
  final VoidCallback onNext;
  final VoidCallback onDismiss;

  const TutorialStepWrapper({
    Key? key,
    required this.step,
    required this.onNext,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TutorialStep(
      targetKey: step.targetKey,
      content: step.content,
      onNext: onNext,
      onDismiss: step.onDismiss ?? onDismiss,
    );
  }
}

class TutorialStep extends StatelessWidget {
  final Widget content;
  final GlobalKey targetKey;
  final VoidCallback onNext;
  final VoidCallback? onDismiss;

  const TutorialStep({
    Key? key,
    required this.content,
    required this.targetKey,
    required this.onNext,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Find the position of the targeted widget
    final RenderBox? targetBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (targetBox == null) {
      print("Target widget not found for key: $targetKey");
      return Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFD2128B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              content,
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFD2128B),
                  ),
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Get the position in global coordinates
    final targetPosition = targetBox.localToGlobal(Offset.zero);
    final targetSize = targetBox.size;

    print("Target position: $targetPosition, size: $targetSize");

    // Calculate the overlay position with respect to the media query
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;

    // Add a small padding to the cutout to make it visibly larger than the widget
    // This ensures the widget is properly highlighted

    final adjustedRect = Rect.fromLTWH(
      targetPosition.dx - 8,
      targetPosition.dy - 53,
      targetSize.width + 10,
      targetSize.height + 10,
    );

    // Determine the best position for the tutorial content
    final contentWidth = screenSize.width - 40; // 20px padding on each side
    final contentHeight = 200.0; // Estimated height of content card

    // Check available space in all directions
    final spaceBelow = screenSize.height - adjustedRect.bottom - 10;
    final spaceAbove = adjustedRect.top - 10;

    // Default to below if possible
    Offset contentPosition;
    if (spaceBelow >= contentHeight) {
      // Position below
      contentPosition = Offset((adjustedRect.left + adjustedRect.right) / 2,
          adjustedRect.bottom + 10);
    } else if (spaceAbove >= contentHeight) {
      // Position above
      contentPosition = Offset(
          (adjustedRect.left + adjustedRect.right - contentWidth) / 2,
          adjustedRect.top - contentHeight - 100);
    } else {
      // Center on screen as fallback
      contentPosition = Offset((screenSize.width - contentWidth) / 2,
          (screenSize.height - contentHeight) / 2);
    }

    // Keep content within screen bounds
    contentPosition = Offset(
        contentPosition.dx.clamp(20, screenSize.width - contentWidth - 20),
        contentPosition.dy.clamp(20, screenSize.height - contentHeight - 20));

    print("Content position: $contentPosition");

    return Stack(
      children: [
        // Cutout around the target widget - make it the first layer (bottom)
        Positioned.fill(
          child: CustomPaint(
            painter: HolePainter(
              holeRect: adjustedRect,
              radius: 8.0,
            ),
          ),
        ),

        // Tutorial content card - positioned according to available space
        Positioned(
          left: contentPosition.dx,
          top: contentPosition.dy,
          width: contentWidth,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFD2128B),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    if (onDismiss != null)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: onDismiss,
                      ),
                  ],
                ),
                content,
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFD2128B),
                    ),
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter to create a "hole" in the overlay
class HolePainter extends CustomPainter {
  final Rect holeRect;
  final double radius;

  HolePainter({required this.holeRect, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the semi-transparent background
    final paint = Paint()..color = Color.fromRGBO(0, 0, 0, 0.15);

    // Create a path for the entire screen
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create a path for the hole with rounded corners
    final holePath = Path()
      ..addRRect(RRect.fromRectAndRadius(holeRect, Radius.circular(radius)));

    // Cut the hole out of the full screen path
    final finalPath = Path.combine(PathOperation.difference, path, holePath);

    canvas.drawPath(finalPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Helper function to show a tutorial
void showTutorial(
  BuildContext context,
  List<TutorialStep> steps,
  String tutorialKey,
) async {
  // Make sure we have steps to show
  if (steps.isEmpty) return;

  // Check if context is valid - don't check preferences to force it to show every time
  if (context.mounted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      useSafeArea: true,
      builder: (dialogContext) => Material(
        type: MaterialType.transparency,
        child: TutorialOverlay(
          tutorialSteps: steps,
          onComplete: () {
            // Only pop if the context is still valid
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
          },
          tutorialKey: tutorialKey,
        ),
      ),
    );
  }
}
