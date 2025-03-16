import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/verification/provider/verification.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text_views.dart';
import 'verification_step.dart';

class FaceVerificationScreen extends ConsumerStatefulWidget {
  const FaceVerificationScreen({super.key});
  static const name = 'FaceVerificationScreen';
  static const route = name;

  @override
  ConsumerState<FaceVerificationScreen> createState() =>
      _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends ConsumerState<FaceVerificationScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isDetecting = false;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      enableTracking: true,
      minFaceSize: 0.15,
    ),
  );

  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  VerificationStep _currentStep = VerificationStep.centerFace;
  bool _wasEyeOpen = true;
  int _blinkCount = 0;
  String _instruction = "Center your face in the frame";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _progressAnimation =
        Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.yuv420
          : ImageFormatGroup.bgra8888,
    );

    await _cameraController!.initialize();
    _startFaceDetection();
    if (mounted) setState(() {});
  }

  void _startFaceDetection() {
    _cameraController!.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      try {
        final WriteBuffer allBytes = WriteBuffer();
        for (var plane in image.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        final bytes = allBytes.done().buffer.asUint8List();

        final deviceOrientation = MediaQuery.of(context).orientation;
        final rotation = deviceOrientation == Orientation.portrait
            ? InputImageRotation.rotation270deg
            : InputImageRotation.rotation180deg;

        final inputImage = InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: Platform.isAndroid
                ? InputImageFormat.yuv420
                : InputImageFormat.bgra8888,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );

        await _processImage(inputImage);
      } catch (e) {
        debugPrint("Error detecting face: $e");
      }

      _isDetecting = false;
    });
  }

  Future<void> _processImage(InputImage inputImage) async {
    // if (_isDetecting) return;
    // _isDetecting = true;

    try {
      final List<Face> faces = await _faceDetector.processImage(inputImage);
      if (mounted) {
        _processVerificationStep(faces);
      }
    } catch (e) {
      debugPrint("Error processing image: $e");
    } finally {
      _isDetecting = false;
    }
  }

  void _processVerificationStep(List<Face> faces) {
    if (faces.isEmpty) {
      setState(() {
        _instruction =
            "No face detected. Please center your face in the frame.";
      });
      return;
    }

    final Face face = faces.first;
    final double? leftEyeOpen = face.leftEyeOpenProbability;
    final double? rightEyeOpen = face.rightEyeOpenProbability;
    final double? headEulerY = face.headEulerAngleY;

    switch (_currentStep) {
      case VerificationStep.centerFace:
        if (_isFaceCentered(face)) {
          setState(() {
            _currentStep = VerificationStep.blink;
            _updateInstruction();
          });
        }
        break;

      case VerificationStep.blink:
        bool isEyeOpen =
            (leftEyeOpen ?? 1.0) > 0.8 && (rightEyeOpen ?? 1.0) > 0.8;
        if (_wasEyeOpen && !isEyeOpen) {
          setState(() {
            _blinkCount++;
            _updateInstruction();
          });
          if (_blinkCount >= 3) {
            setState(() {
              _currentStep = VerificationStep.turnLeft;
              _updateInstruction();
            });
          }
        }
        _wasEyeOpen = isEyeOpen;
        break;

      case VerificationStep.turnLeft:
        if (headEulerY != null && headEulerY < -30) {
          setState(() {
            _currentStep = VerificationStep.turnRight;
            _updateInstruction();
          });
        }
        break;

      case VerificationStep.turnRight:
        if (headEulerY != null && headEulerY > 30) {
          setState(() {
            _currentStep = VerificationStep.completed;
            _updateInstruction();
          });
        }
        break;

      case VerificationStep.completed:
        // Handle completion
        break;
    }
  }

 
  Future<void> _restartCamera() async {
    await _cameraController?.dispose();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final verificationState = ref.watch(verficationVideoProvider);

    ref.listen<VerificationState>(verficationVideoProvider, (prev, current) {
      if (current.isSuccess) {
         Navigator.pop(context);
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.dashboardPage, (route) => true);
      }
    });

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final containerSize = size.width * 0.85;

    return BaseScreen(
      bgImage: Assets.images.bg2.path,
      appBarEnabled: false,
      Header: 'Face Verification',
      authFlow: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview Container
          Center(
            child: Container(
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _currentStep == VerificationStep.completed
                      ? AppColors.metalPinkColour
                      : Colors.grey[300]!,
                  width: 8,
                ),
              ),
              child: ClipOval(
                child: Transform.scale(
                  scale: 2.0,
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 9 / 16,
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Instructions Panel
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: (_currentStep == VerificationStep.completed)
                  ? BaseButton(
                      loading: verificationState.isLoading,
                      buttonText: "Verification Complete",
                      onPressed: () {
                        ref
                            .read(verficationVideoProvider.notifier)
                            .verificationMe();
                      })
                  : Container()),
          // Bottom Instructions Panel
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Instruction Text
                  TextView(
                    text: _instruction,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Step Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: VerificationStep.values.map((step) {
                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentStep.index >= step.index
                              ? AppColors.metalPinkColour
                              : Colors.grey[300],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getCameraPreviewScale() {
    if (_cameraController == null) return 1.0;

    final size = MediaQuery.of(context).size;
    final screenAspectRatio = size.width / size.width; // We want a square
    final cameraAspectRatio = _cameraController!.value.aspectRatio;

    // We want to fill the height of our square container
    return screenAspectRatio / cameraAspectRatio;
  }

  double _getProgressValue() {
    switch (_currentStep) {
      case VerificationStep.centerFace:
        return 0.2;
      case VerificationStep.blink:
        return 0.4 + (_blinkCount / 3) * 0.2;
      case VerificationStep.turnLeft:
        return 0.6;
      case VerificationStep.turnRight:
        return 0.8;
      case VerificationStep.completed:
        return 1.0;
    }
  }

  bool _isFaceCentered(Face face) {
    if (_cameraController == null ||
        _cameraController!.value.previewSize == null) {
      return false;
    }

    final Rect boundingBox = face.boundingBox;
    final Size imageSize = Size(_cameraController!.value.previewSize!.height,
        _cameraController!.value.previewSize!.width);

    // Calculate the center point of the face
    final double faceCenterX = boundingBox.center.dx;
    final double faceCenterY = boundingBox.center.dy;

    // Calculate the center point of the image
    final double imageCenterX = imageSize.width / 2;
    final double imageCenterY = imageSize.height / 2;

    // Calculate the distance from the face center to image center
    final double distanceX = (faceCenterX - imageCenterX).abs();
    final double distanceY = (faceCenterY - imageCenterY).abs();

    // Increase tolerance to 20% of image dimensions for easier centering
    final double toleranceX = imageSize.width * 0.2;
    final double toleranceY = imageSize.height * 0.2;

    // Add debug logging
    debugPrint('Face center: ($faceCenterX, $faceCenterY)');
    debugPrint('Image center: ($imageCenterX, $imageCenterY)');
    debugPrint('Distance: ($distanceX, $distanceY)');
    debugPrint('Tolerance: ($toleranceX, $toleranceY)');

    // Check if face is within tolerance AND has sufficient size
    final bool isCentered = distanceX <= toleranceX && distanceY <= toleranceY;
    final bool isLargeEnough = boundingBox.width >
        imageSize.width * 0.3; // Face should occupy at least 30% of width

    return isCentered && isLargeEnough;
  }

  void _updateInstruction() {
    setState(() {
      _instruction = _getInstructionForStep(_currentStep);
    });
  }

  String _getInstructionForStep(VerificationStep step) {
    switch (step) {
      case VerificationStep.centerFace:
        return "Center your face in the frame";
      case VerificationStep.blink:
        return "Blink your eyes";
      case VerificationStep.turnLeft:
        return "Turn left";
      case VerificationStep.turnRight:
        return "Turn right";
      case VerificationStep.completed:
        return "Verification complete!";
    }
  }

  // ... Keep all the existing camera and face detection logic ...
  // (Copy all the remaining methods from your existing code)
}

class CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw horizontal line
    canvas.drawLine(
      Offset(size.width * 0.4, size.height * 0.5),
      Offset(size.width * 0.6, size.height * 0.5),
      paint,
    );

    // Draw vertical line
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.4),
      Offset(size.width * 0.5, size.height * 0.6),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
