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
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'verification_step.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart' as mlkit;

// Helper function to compute rotation based on sensor orientation
InputImageRotation _computeRotation(CameraDescription cameraDescription) {
  final sensorOrientation = cameraDescription.sensorOrientation;
  // Convert the sensor orientation (0, 90, 180, 270) to ML Kit's InputImageRotation
  switch (sensorOrientation) {
    case 90:
      return InputImageRotation.rotation90deg;
    case 180:
      return InputImageRotation.rotation180deg;
    case 270:
      // Most common for front cameras on Android/iOS
      return InputImageRotation.rotation270deg;
    case 0:
    default:
      return InputImageRotation.rotation0deg;
  }
}

// Enum to represent the status of face positioning
enum FacePositionStatus {
  none, // No face detected
  notCentered, // Face detected but off-center
  notSized, // Face centered but too close or too far
  centered // Face centered and correctly sized
}

class FaceVerificationScreen extends ConsumerStatefulWidget {
  const FaceVerificationScreen({super.key});
  static const name = 'FaceVerificationScreen';
  static const route = name;

  @override
  ConsumerState<FaceVerificationScreen> createState() =>
      _FaceVerificationScreenState();
}

class _FaceVerificationScreenState
    extends ConsumerState<FaceVerificationScreen> {
  CameraController? _cameraController;
  CameraDescription?
      _cameraDescription; // Store the selected camera's description
  bool _isDetecting = false; // Flag to prevent concurrent ML Kit processing
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true, // Keep enabled if needed for future features
      enableClassification: true, // Needed for eye open probability
      enableTracking: true, // Helps maintain face ID across frames
      minFaceSize:
          0.20, // Face should occupy at least 20% of the smaller dimension
      performanceMode: FaceDetectorMode.accurate, // Prioritize accuracy
      enableLandmarks: true, // Needed for head angle
    ),
  );

  // Add FlutterTTS instance
  final FlutterTts _flutterTts = FlutterTts();

  // State variables for verification flow
  VerificationStep _currentStep = VerificationStep.centerFace;
  FacePositionStatus _facePositionStatus = FacePositionStatus.none;
  Color _borderColor = Colors.grey[300]!; // Border color reflects status
  bool _wasEyeOpen = true; // Track previous eye state for blink detection
  int _blinkCount = 0; // Count blinks
  String _instruction =
      "Align your head within the circle. The border will turn green when centered.";
  Timer? _holdStillTimer; // Timer to delay transition after centering
  DateTime? _lastBlinkTime; // Track last blink time
  String _previousInstruction = ""; // Track previous instruction
  bool _isCameraInitialized = false; // Track camera initialization status

  @override
  void initState() {
    super.initState();
    _initializeCameraAndPermissions();
    _setupTts(); // Initialize TTS
  }

  // Set up text-to-speech settings
  Future<void> _setupTts() async {
    // Basic setup
    await _flutterTts.setLanguage("en-US");
    await _flutterTts
        .setSpeechRate(0.48); // Slightly slower for more natural pace
    await _flutterTts.setVolume(1.0);
    await _flutterTts
        .setPitch(0.9); // Slightly lower pitch for more natural sound

    // Set more natural sounding voices if available
    try {
      // Get available voices
      final voices = await _flutterTts.getVoices;

      // Check if voices list is available
      if (voices != null) {
        debugPrint("Available TTS voices: ${voices.length}");

        // Try to find premium/enhanced quality voices
        final enhancedVoices = voices.where((voice) {
          final voiceMap = voice as Map<String, dynamic>;
          final voiceName = voiceMap['name'] as String? ?? '';
          final voiceQuality = voiceMap['quality'] as String? ?? '';

          // Look for voices that might sound more natural (different devices have different naming)
          return voiceName.toLowerCase().contains('enhanced') ||
              voiceName.toLowerCase().contains('premium') ||
              voiceName.toLowerCase().contains('neural') ||
              voiceQuality.toLowerCase().contains('high') ||
              voiceName
                  .toLowerCase()
                  .contains('samantha') || // One of the better iOS voices
              voiceName
                  .toLowerCase()
                  .contains('wavenet'); // Better Android voices
        }).toList();

        // If we found enhanced voices, use the first one
        if (enhancedVoices.isNotEmpty) {
          final selectedVoice = enhancedVoices.first as Map<String, dynamic>;
          final voiceName = selectedVoice['name'] as String? ?? '';

          debugPrint("Selected enhanced voice: $voiceName");
          await _flutterTts.setVoice({"name": voiceName, "locale": "en-US"});
        }
        // If no enhanced voices found, try to find a good default voice
        else {
          // Look for standard voices that are generally better quality
          final preferredVoiceNames = [
            'Karen',
            'Samantha',
            'Alex',
            'Daniel',
            'Matthew'
          ];

          for (final name in preferredVoiceNames) {
            final matchingVoice = voices.where((voice) {
              final voiceMap = voice as Map<String, dynamic>;
              final voiceName = voiceMap['name'] as String? ?? '';
              return voiceName.contains(name);
            }).toList();

            if (matchingVoice.isNotEmpty) {
              final selectedVoice = matchingVoice.first as Map<String, dynamic>;
              final voiceName = selectedVoice['name'] as String? ?? '';

              debugPrint("Selected preferred voice: $voiceName");
              await _flutterTts
                  .setVoice({"name": voiceName, "locale": "en-US"});
              break;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error setting up enhanced TTS voice: $e");
    }

    // Speak initial instruction after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _speakInstruction(_instruction);
    });
  }

  // Speak the current instruction with more natural phrasing
  Future<void> _speakInstruction(String instruction) async {
    if (mounted) {
      // Stop any ongoing speech before starting a new one
      await _flutterTts.stop();

      // Add subtle pause markers for more natural speech rhythm
      // This uses SSML-like syntax that some TTS engines support
      String enhancedInstruction = instruction;

      // For longer instructions, add commas at logical break points if they don't exist
      if (instruction.length > 30 && !instruction.contains(',')) {
        // Replace common phrases with versions that have pauses
        enhancedInstruction = instruction
            .replaceAll('Please position', 'Please, position')
            .replaceAll('Please center', 'Please, center')
            .replaceAll('Slowly turn', 'Slowly, turn');
      }

      await _flutterTts.speak(enhancedInstruction);
    }
  }

  @override
  void dispose() {
    _holdStillTimer?.cancel(); // Cancel timer if active

    // Make sure to stop any ongoing speech immediately
    _flutterTts.stop();

    // Stop the image stream BEFORE disposing the controller
    _cameraController?.stopImageStream().catchError((e) {
      // Log errors during stream stop, but don't prevent disposal
      debugPrint("Error stopping image stream: $e");
    }).whenComplete(() {
      _cameraController?.dispose().then((_) {
        debugPrint("Camera Controller Disposed");
      }).catchError((e) {
        debugPrint("Error disposing camera controller: $e");
      });
    });
    _faceDetector.close(); // Release ML Kit resources
    super.dispose();
  }

  // Renamed and updated method to handle permissions first
  Future<void> _initializeCameraAndPermissions() async {
    // 1. Request Camera Permission
    final permissionStatus = await Permission.camera.request();

    if (mounted) {
      // Check if widget is still mounted
      if (permissionStatus.isGranted) {
        // 2. Permission Granted: Proceed with Camera Initialization
        try {
          final cameras = await availableCameras();
          // Find the front camera
          _cameraDescription = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
            orElse: () =>
                cameras.first, // Fallback to the first camera if no front
          );

          _cameraController = CameraController(
              _cameraDescription!,
              ResolutionPreset
                  .low, // Use low resolution for better compatibility
              enableAudio: false,
              imageFormatGroup: Platform.isAndroid // Platform-specific format
                  ? ImageFormatGroup.yuv420 // Preferred on Android
                  : ImageFormatGroup.bgra8888);

          // Set preferred camera settings
          await _cameraController!.initialize();
          await _cameraController!.setFocusMode(FocusMode.auto);
          await _cameraController!.setExposureMode(ExposureMode.auto);

          // Check if the widget is still mounted after async initialization
          if (!mounted) return;

          setState(() {
            _isCameraInitialized = true; // Mark camera as initialized
          });
          _startFaceDetection(); // Start processing frames
          // Update UI to show preview only after successful init
        } catch (e) {
          debugPrint("Error initializing camera: $e");
          if (mounted) {
            setState(() {
              _instruction =
                  "Error initializing camera. Please try again later.";
              _isCameraInitialized = false; // Mark as not initialized on error
            });
          }
        }
      } else {
        // 3. Permission Denied: Update instruction
        debugPrint("Camera permission denied. Status: $permissionStatus");
        setState(() {
          if (permissionStatus.isPermanentlyDenied) {
            _instruction =
                "Camera permission is permanently denied. Please enable it in app settings.";
            // Optionally: Add a button to open app settings
            openAppSettings();
          } else {
            _instruction =
                "Camera permission is required for face verification. Please grant permission.";
          }
          _isCameraInitialized =
              false; // Ensure camera is marked as not initialized
        });
      }
    }
  }

  // Start streaming camera frames for face detection
  bool _isDetectingFaces =
      false; // Add this at class level to avoid multiple detections at once

  void _startFaceDetection() {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _cameraDescription == null) {
      debugPrint("Camera not ready for face detection stream.");
      return;
    }

    _cameraController!.startImageStream((CameraImage image) async {
      if (!mounted || _isDetectingFaces) return;

      _isDetectingFaces = true;

      try {
        // Convert all image planes to a single byte buffer
        final WriteBuffer allBytes = WriteBuffer();
        for (Plane plane in image.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        final bytes = allBytes.done().buffer.asUint8List();

        // Get image metadata
        final Size imageSize =
            Size(image.width.toDouble(), image.height.toDouble());

        // Rotation for InputImage
        final rotation = _computeRotation(_cameraDescription!);

        // Convert image format based on platform
        final Uint8List imageBytes;
        final InputImageFormat format;

        if (Platform.isAndroid) {
          imageBytes = _yuv420ToNV21(image);
          format = InputImageFormat.nv21;
        } else {
          imageBytes = bytes;
          format = InputImageFormat.bgra8888;
        }

        // Create InputImage for ML Kit
        final inputImage = InputImage.fromBytes(
          bytes: imageBytes,
          metadata: InputImageMetadata(
            size: imageSize,
            rotation: rotation,
            format: format,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );

        // Process the image with ML Kit
        await _processImage(inputImage);
      } catch (e) {
        debugPrint("Error during image stream processing: $e");
      } finally {
        _isDetectingFaces = false;
      }
    });
  }

  Uint8List _yuv420ToNV21(CameraImage image) {
    var nv21 = Uint8List(image.planes[0].bytes.length +
        image.planes[1].bytes.length +
        image.planes[2].bytes.length);

    var yBuffer = image.planes[0].bytes;
    var uBuffer = image.planes[1].bytes;
    var vBuffer = image.planes[2].bytes;

    nv21.setRange(0, yBuffer.length, yBuffer);

    int i = 0;
    while (i < uBuffer.length) {
      nv21[yBuffer.length + i] = vBuffer[i];
      nv21[yBuffer.length + i + 1] = uBuffer[i];
      i += 2;
    }

    return nv21;
  }

  // Process the InputImage using ML Kit Face Detector
  Future<void> _processImage(InputImage inputImage) async {
    if (!mounted) return;

    try {
      final List<Face> faces = await _faceDetector.processImage(inputImage);
      if (mounted) {
        // Update UI immediately when faces are detected
        setState(() {
          _processVerificationStep(faces);
        });
      }
    } catch (e) {
      debugPrint("Error processing image with ML Kit: $e");
    }
  }

  // Main logic for updating verification steps based on detected faces
  void _processVerificationStep(List<Face> faces) {
    if (!mounted) return;

    FacePositionStatus currentCalculatedStatus = FacePositionStatus.none;
    String nextInstruction = _instruction;
    Color nextBorderColor = _borderColor;
    VerificationStep nextStep = _currentStep;

    // --- Handle No Face Detected ---
    if (faces.isEmpty) {
      currentCalculatedStatus = FacePositionStatus.none;
      nextInstruction =
          "No face detected. Please position your face in the circle.";
      nextBorderColor = Colors.red;
      _holdStillTimer?.cancel();

      // Always reset to centering step when face is lost
      nextStep = VerificationStep.centerFace;
      _blinkCount = 0;
      debugPrint("❌ No face detected - resetting to center step");
    }
    // --- Handle Face Detected ---
    else {
      final Face face = faces.first;
      currentCalculatedStatus = _getFacePositionStatus(face);
      final double? headEulerY = face.headEulerAngleY;
      final double? leftEyeOpen = face.leftEyeOpenProbability;
      final double? rightEyeOpen = face.rightEyeOpenProbability;

      // Debug logging
      debugPrint("👤 Face Detection => Position: $currentCalculatedStatus");
      debugPrint(
          "👁 Eye States => Left: ${leftEyeOpen?.toStringAsFixed(2)}, Right: ${rightEyeOpen?.toStringAsFixed(2)}");
      debugPrint("🔄 Head Angle => ${headEulerY?.toStringAsFixed(2)}°");

      // Update border color based on face position
      switch (currentCalculatedStatus) {
        case FacePositionStatus.centered:
          nextBorderColor = Colors.green;
          break;
        case FacePositionStatus.notCentered:
        case FacePositionStatus.notSized:
          nextBorderColor = Colors.yellow;
          break;
        case FacePositionStatus.none:
          nextBorderColor = Colors.red;
          break;
      }

      // Process verification steps
      if (currentCalculatedStatus != FacePositionStatus.centered &&
          _currentStep != VerificationStep.centerFace) {
        // Return to centering step if face position is lost during any action
        nextStep = VerificationStep.centerFace;
        nextInstruction = "Please center your face again";
        debugPrint("⚠️ Face position lost - returning to center step");
      } else {
        // Continue with normal step processing
        // --- Process Verification Steps ---
        switch (_currentStep) {
          case VerificationStep.centerFace:
            switch (currentCalculatedStatus) {
              case FacePositionStatus.centered:
                nextInstruction = "Perfect! Hold still...";
                if (_holdStillTimer == null || !_holdStillTimer!.isActive) {
                  _holdStillTimer =
                      Timer(const Duration(milliseconds: 800), () {
                    if (mounted &&
                        _currentStep == VerificationStep.centerFace) {
                      setState(() {
                        _currentStep = VerificationStep.blink;
                        _instruction = "Please blink naturally";
                        _wasEyeOpen = true;
                        _blinkCount = 0;
                        _lastBlinkTime = null;
                      });
                    }
                  });
                }
                break;
              case FacePositionStatus.notSized:
                nextInstruction = face.boundingBox.width /
                            _cameraController!.value.previewSize!.width >
                        0.7
                    ? "Move your face further away"
                    : "Move your face closer";
                _holdStillTimer?.cancel();
                break;
              case FacePositionStatus.notCentered:
                final Rect boundingBox = face.boundingBox;
                final Size previewSize = _cameraController!.value.previewSize!;
                final double faceCenterX = boundingBox.center.dx;
                final double faceCenterY = boundingBox.center.dy;
                final double imageCenterX = previewSize.width / 2.0;
                final double imageCenterY = previewSize.height / 2.0;

                String direction = "";
                if ((faceCenterY - imageCenterY) < -previewSize.height * 0.1) {
                  direction += "down";
                } else if ((faceCenterY - imageCenterY) >
                    previewSize.height * 0.1) {
                  direction += "up";
                }

                if ((faceCenterX - imageCenterX) < -previewSize.width * 0.1) {
                  direction += direction.isEmpty ? "right" : " and right";
                } else if ((faceCenterX - imageCenterX) >
                    previewSize.width * 0.1) {
                  direction += direction.isEmpty ? "left" : " and left";
                }

                nextInstruction =
                    "Move your face ${direction.isNotEmpty ? direction : 'to center'}";
                _holdStillTimer?.cancel();
                break;
              case FacePositionStatus.none:
                nextInstruction = "Position your face in the circle";
                _holdStillTimer?.cancel();
                break;
            }
            break;

          case VerificationStep.turnLeft:
            if (currentCalculatedStatus != FacePositionStatus.centered) {
              nextInstruction = "Please center your face first";
              nextStep = VerificationStep.centerFace;
            } else {
              // More sensitive head turn detection
              debugPrint(
                  "🔄 Turn Left Check => Angle: ${headEulerY?.toStringAsFixed(2) ?? 'null'}");
              if (headEulerY != null) {
                if (headEulerY < -15) {
                  // Reduced threshold from -20 to -15
                  debugPrint("✅ Left Turn Detected!");
                  Future.delayed(const Duration(milliseconds: 800), () {
                    if (mounted && _currentStep == VerificationStep.turnLeft) {
                      setState(() {
                        _currentStep = VerificationStep.turnRight;
                        _instruction = _getInstructionForStep(_currentStep);
                      });
                    }
                  });
                } else {
                  nextInstruction = "Slowly turn your head to the left";
                }
              }
            }
            break;

          case VerificationStep.turnRight:
            if (currentCalculatedStatus != FacePositionStatus.centered) {
              nextInstruction = "Please center your face first";
              nextStep = VerificationStep.centerFace;
            } else {
              // More sensitive head turn detection
              debugPrint(
                  "🔄 Turn Right Check => Angle: ${headEulerY?.toStringAsFixed(2) ?? 'null'}");
              if (headEulerY != null) {
                if (headEulerY > 15) {
                  // Reduced threshold from 20 to 15
                  debugPrint("✅ Right Turn Detected!");
                  Future.delayed(const Duration(milliseconds: 800), () {
                    if (mounted && _currentStep == VerificationStep.turnRight) {
                      setState(() {
                        _currentStep = VerificationStep.completed;
                        _instruction = _getInstructionForStep(_currentStep);
                        _borderColor = Colors.green;
                      });
                    }
                  });
                } else {
                  nextInstruction = "Slowly turn your head to the right";
                }
              }
            }
            break;

          case VerificationStep.blink:
            if (currentCalculatedStatus == FacePositionStatus.centered) {
              // More lenient blink detection with adjusted thresholds
              bool isLeftEyeClosed = (leftEyeOpen ?? 1.0) < 0.2;
              bool isRightEyeClosed = (rightEyeOpen ?? 1.0) < 0.2;
              bool isBlinking = isLeftEyeClosed || isRightEyeClosed;

              // Debug logging for eye states
              debugPrint(
                  "👁 Raw Eye Values => Left: ${leftEyeOpen?.toStringAsFixed(3)}, Right: ${rightEyeOpen?.toStringAsFixed(3)}");
              debugPrint(
                  "👁 Blink Status => Left Closed: $isLeftEyeClosed, Right Closed: $isRightEyeClosed, Was Open: $_wasEyeOpen");

              // Only proceed with blink detection if eyes were previously open
              if (_wasEyeOpen && isBlinking) {
                debugPrint("🎯 Potential Blink Detected!");
                if (_lastBlinkTime == null ||
                    DateTime.now().difference(_lastBlinkTime!).inMilliseconds >
                        1000) {
                  _blinkCount++;
                  _lastBlinkTime = DateTime.now();
                  nextInstruction =
                      "Blink detected! ${_blinkCount == 1 ? 'Great job!' : 'Please wait...'}";
                  debugPrint("✅ Valid Blink Registered! Count: $_blinkCount");

                  if (_blinkCount >= 1) {
                    debugPrint(
                        "🎉 Blink requirement met, preparing to transition...");
                    Future.delayed(const Duration(milliseconds: 1500), () {
                      if (mounted && _currentStep == VerificationStep.blink) {
                        setState(() {
                          _currentStep = VerificationStep.turnLeft;
                          _instruction = _getInstructionForStep(_currentStep);
                          _blinkCount = 0;
                        });
                      }
                    });
                  }
                } else {
                  debugPrint("⏳ Blink ignored - too soon after previous blink");
                  nextInstruction =
                      "Please wait a moment before blinking again...";
                }
              } else if (!isBlinking) {
                nextInstruction =
                    "Please blink naturally - just close and open your eyes";
              }
              _wasEyeOpen = !isBlinking;
            }
            break;

          default:
            break;
        }
      }
    }

    // Always update state to ensure responsive UI
    setState(() {
      _facePositionStatus = currentCalculatedStatus;
      _instruction = nextInstruction;
      _borderColor = nextBorderColor;
      _currentStep = nextStep;

      // Speak the instruction if it changed - immediately speak new instructions
      if (_previousInstruction != nextInstruction) {
        _speakInstruction(nextInstruction);
        _previousInstruction = nextInstruction;
      }
    });
  }

  // Helper function to determine face position status based on ML Kit Face object
  FacePositionStatus _getFacePositionStatus(Face face) {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _cameraController!.value.previewSize == null ||
        _cameraDescription == null) {
      return FacePositionStatus.none; // Not ready
    }

    final Rect boundingBox = face.boundingBox;
    final Size previewSize = _cameraController!.value.previewSize!;

    // Determine the logical image size based on sensor orientation relative to preview
    final bool isRotated = (_cameraDescription!.sensorOrientation == 90 ||
        _cameraDescription!.sensorOrientation == 270);
    final Size imageSize = isRotated
        ? Size(previewSize.height, previewSize.width) // Swapped dimensions
        : Size(previewSize.width, previewSize.height); // Natural dimensions

    // --- Centering Calculation ---
    final double faceCenterX = boundingBox.center.dx;
    final double faceCenterY = boundingBox.center.dy;
    final double imageCenterX = imageSize.width / 2.0;
    final double imageCenterY = imageSize.height / 2.0;

    // More lenient tolerance for centering
    final double toleranceX =
        imageSize.width * 0.25; // Increased from 0.12 to 0.25
    final double toleranceY =
        imageSize.height * 0.25; // Increased from 0.18 to 0.25

    final bool isCentered = (faceCenterX - imageCenterX).abs() <= toleranceX &&
        (faceCenterY - imageCenterY).abs() <= toleranceY;

    // --- Sizing Calculation ---
    final double faceWidthRatio = boundingBox.width / imageSize.width;
    final double faceHeightRatio = boundingBox.height / imageSize.height;

    // More lenient size range
    const double minSizeRatio = 0.20; // Decreased from 0.30 to 0.20
    const double maxSizeRatio = 0.80; // Increased from 0.70 to 0.80

    final bool isSizedCorrectly = faceWidthRatio >= minSizeRatio &&
        faceWidthRatio <= maxSizeRatio &&
        faceHeightRatio >= minSizeRatio &&
        faceHeightRatio <= maxSizeRatio;

    // Debug logging for face position
    debugPrint('📏 Face Position => '
        'Center Offset: (X: ${(faceCenterX - imageCenterX).abs().toStringAsFixed(1)}, '
        'Y: ${(faceCenterY - imageCenterY).abs().toStringAsFixed(1)}), '
        'Size Ratio: (W: ${faceWidthRatio.toStringAsFixed(2)}, H: ${faceHeightRatio.toStringAsFixed(2)})');
    debugPrint(
        '✅ Position Check => Centered: $isCentered, Sized: $isSizedCorrectly');

    // Determine final status
    if (!isCentered) {
      return FacePositionStatus.notCentered;
    } else if (!isSizedCorrectly) {
      return FacePositionStatus.notSized;
    } else {
      return FacePositionStatus.centered;
    }
  }

  // Helper to get instruction text based on the current step
  String _getInstructionForStep(VerificationStep step) {
    String instruction;

    switch (step) {
      case VerificationStep.centerFace:
        instruction =
            "Align your head within the circle. The border will turn green when centered.";
        break;
      case VerificationStep.blink:
        instruction = "Please blink your eyes once";
        break;
      case VerificationStep.turnLeft:
        instruction = "Slowly turn head left";
        break;
      case VerificationStep.turnRight:
        instruction = "Slowly turn head right";
        break;
      case VerificationStep.completed:
        instruction = "Verification Complete!";
        break;
    }

    // When step changes, immediately speak the new instruction and cancel any ongoing speech
    if (_previousInstruction != instruction) {
      // Use a post-frame callback to ensure UI is updated first
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _speakInstruction(instruction);
          _previousInstruction = instruction;
        }
      });
    }

    return instruction;
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the verification provider state for success/error feedback
    ref.listen<VerificationState>(verficationVideoProvider, (prev, current) {
      if (current.isSuccess) {
        if (mounted) {
          // Optional: Show success feedback briefly before navigating
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Verification Submitted Successfully!"),
                duration: Duration(seconds: 2)),
          );
          // Navigate to dashboard after successful submission
          Navigator.pop(context); // Pop current screen
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.dashboardPage, (route) => false);
        }
      } else if (current.isError) {
        // Show error message from the provider
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    current.errorMessage ?? 'Verification submission failed')),
          );
          // Optionally reset the UI or allow retry
          // setState(() { _currentStep = VerificationStep.centerFace; ... });
        }
      }
    });
    final verificationState = ref.watch(verficationVideoProvider);

    // --- Build UI ---

    // Loading state while camera initializes OR permission pending/denied
    if (!_isCameraInitialized) {
      // Use the new state variable
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Show progress indicator only if not a permission error message
              if (!_instruction.contains("permission"))
                const CircularProgressIndicator.adaptive(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  _instruction,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              // Optionally, add a button to retry permission request or open settings
              if (_instruction.contains("permission is required"))
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    onPressed: _initializeCameraAndPermissions, // Retry
                    child: const Text("Grant Permission"),
                  ),
                ),
              if (_instruction.contains("permanently denied"))
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    onPressed: openAppSettings, // Open settings
                    child: const Text("Open Settings"),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    // Make the circle container slightly larger
    final containerSize = size.width * 0.85;

    // Calculate scale for CameraPreview to fill the circle area correctly
    final cameraPreview = _cameraController!.value.previewSize!;
    final screenAspectRatio = size.width / size.height;
    final previewAspectRatio = cameraPreview.height /
        cameraPreview.width; // Use height/width for portrait camera feed
    final scale = 1 /
        (previewAspectRatio *
            (containerSize / containerSize)); // Scale to fit circle

    return BaseScreen(
      bgImage: Assets.images.bg2.path, // Use your background
      appBarEnabled: false, // No standard app bar
      Header:
          'Face Verification', // Custom header text if BaseScreen supports it
      authFlow: true, // Assuming BaseScreen uses this
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- Camera Preview Centered in Circle ---
          Center(
            child: Container(
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _borderColor, // Dynamic border color
                  width: 6, // Border width
                ),
                boxShadow: [
                  // Subtle shadow for depth
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ],
              ),
              // Clip the preview to the circle
              child: ClipOval(
                child: OverflowBox(
                  // Allow preview to be larger than the container
                  alignment: Alignment.center,
                  child: FittedBox(
                    // Fit the preview within the OverflowBox
                    fit:
                        BoxFit.cover, // Cover ensures filling, might crop edges
                    child: SizedBox(
                      width: containerSize, // Match container width
                      height: containerSize /
                          previewAspectRatio, // Calculate height based on aspect ratio
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- Top Instructions Panel ---
          Positioned(
            left: 16,
            right: 16,
            top: 30, // Positioned from the top
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color:
                    Colors.white.withOpacity(0.92), // High opacity background
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Instruction Text
                  TextView(
                    text: _instruction,
                    textAlign: TextAlign.center,
                    fontSize: 18, // Increased font size
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    maxLines: 2, // Allow two lines
                  ),
                  const SizedBox(height: 10),

                  // Add instruction replay button
                  IconButton(
                    icon: Icon(
                      Icons.volume_up,
                      color: AppColors.metalPinkColour,
                      size: 24,
                    ),
                    onPressed: () => _speakInstruction(_instruction),
                    tooltip: 'Repeat instructions',
                  ),

                  // Step Indicator (Dots) - Only shown after centering step
                  if (_currentStep != VerificationStep.centerFace)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: VerificationStep.values
                          .where((step) =>
                              step !=
                              VerificationStep.centerFace) // Exclude centering
                          .map((step) {
                        // Calculate index relative to action steps (blink=0, left=1, right=2)
                        int actionStepIndex = step.index - 1;
                        int currentActionStepIndex = _currentStep.index - 1;

                        // Determine dot color based on progress
                        Color dotColor = Colors.grey[300]!;
                        if (currentActionStepIndex >= actionStepIndex) {
                          dotColor = AppColors
                              .metalPinkColour; // Active/Completed color
                        }

                        return Container(
                          width: 10, // Dot size
                          height: 10,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dotColor,
                          ),
                        );
                      }).toList(),
                    )
                  else
                    // Maintain space even when dots are hidden
                    const SizedBox(height: 10 + 12), // Height of dot + margin
                ],
              ),
            ),
          ),

          // --- Bottom Completion Button ---
          Positioned(
            left: 20,
            right: 20,
            bottom: 40, // Position from bottom
            child: (_currentStep == VerificationStep.completed)
                ? BaseButton(
                    // Show loading state from provider
                    loading: verificationState.isLoading,
                    buttonText: "Complete Verification",
                    // Disable button while loading
                    onPressed: verificationState.isLoading
                        ? null
                        : () {
                            ref
                                .read(verficationVideoProvider.notifier)
                                .verificationMe();
                          },
                  )
                : Container(), // Empty container when not completed
          ),
        ],
      ),
    );
  }
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
