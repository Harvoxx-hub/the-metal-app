import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

enum VerificationStep { centerFace, blink, turnLeft, turnRight, completed }

class VideoPreview extends StatefulWidget {
  const VideoPreview({super.key});
  static const name = 'VideoPreview';
  static const route = name;

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
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

  VerificationStep _currentStep = VerificationStep.centerFace;
  bool _wasEyeOpen = true;
  int _blinkCount = 0;
  String _instruction = "Center your face in the frame";

  String _getInstructionForStep(VerificationStep step) {
    switch (step) {
      case VerificationStep.centerFace:
        return "Center your face in the frame";
      case VerificationStep.blink:
        return "Please blink slowly $_blinkCount/3";
      case VerificationStep.turnLeft:
        return "Slowly turn your head to the left";
      case VerificationStep.turnRight:
        return "Slowly turn your head to the right";
      case VerificationStep.completed:
        return "Verification completed!";
      default:
        return "Center your face in the frame";
    }
  }

  void _updateInstruction() {
    setState(() {
      _instruction = _getInstructionForStep(_currentStep);
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
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
    setState(() {});
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

        // Get the rotation based on the current device orientation
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
        print("Error detecting face: $e");
      }

      _isDetecting = false;
    });
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (_isDetecting) return;
    _isDetecting = true;

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

    // Define tolerance for centering (10% of image dimensions)
    final double toleranceX = imageSize.width * 0.1;
    final double toleranceY = imageSize.height * 0.1;

    return distanceX <= toleranceX && distanceY <= toleranceY;
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Face Verified"),
        content: Text("You have been successfully verified!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartCamera();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _restartCamera() async {
    await _cameraController!.dispose();
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
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Container();
    }

    return Stack(
      children: [
        CameraPreview(_cameraController!),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: _currentStep == VerificationStep.completed
                    ? Colors.green
                    : Colors.white,
                width: 2,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: Colors.black54,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _instruction,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_currentStep == VerificationStep.completed)
                  ElevatedButton(
                    onPressed: _showSuccessDialog,
                    child: const Text("Continue"),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
