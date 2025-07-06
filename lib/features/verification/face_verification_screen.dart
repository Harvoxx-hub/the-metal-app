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

// Enum to represent the status of face positioning
enum FacePositionStatus {
  none, // No face detected
  notCentered, // Face detected but off-center
  notSized, // Face centered but too close or too far
  centered // Face centered and correctly sized
}

// Add verification progress tracking
class VerificationProgress {
  bool centerCompleted = false;
  bool blinkCompleted = false;
  bool leftTurnCompleted = false;
  bool rightTurnCompleted = false;
  int blinkCount = 0;
  DateTime? lastBlinkTime;

  bool get isFullyCompleted =>
      centerCompleted &&
      blinkCompleted &&
      leftTurnCompleted &&
      rightTurnCompleted;

  void reset() {
    centerCompleted = false;
    blinkCompleted = false;
    leftTurnCompleted = false;
    rightTurnCompleted = false;
    blinkCount = 0;
    lastBlinkTime = null;
  }

  void markStepCompleted(VerificationStep step) {
    switch (step) {
      case VerificationStep.centerFace:
        centerCompleted = true;
        break;
      case VerificationStep.blink:
        blinkCompleted = true;
        break;
      case VerificationStep.turnLeft:
        leftTurnCompleted = true;
        break;
      case VerificationStep.turnRight:
        rightTurnCompleted = true;
        break;
      case VerificationStep.completed:
        // All steps completed
        break;
    }
  }
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

  bool _isDetecting = false; // Flag to prevent concurrent ML Kit processing
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableTracking: true,
      minFaceSize: 0.15,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  // Add FlutterTTS instance
  final FlutterTts _flutterTts = FlutterTts();

  // State variables for verification flow
  VerificationStep _currentStep = VerificationStep.centerFace;

  Color _borderColor = Colors.grey;
  bool _wasEyeOpen = true; // Track previous eye state for blink detection
  int _blinkCount = 0; // Count blinks
  String _instruction = "Center your face in the frame";
  Timer? _holdStillTimer; // Timer to delay transition after centering

  bool _isCameraInitialized = false; // Track camera initialization status

  Timer? _gracePeriodTimer; // Grace period before resetting
  Timer? _detectionDebounceTimer; // Debounce face detection

  int _consecutiveCenteredFrames = 0; // Count consecutive good frames

  @override
  void initState() {
    super.initState();
    _initializeCamera();
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
    _gracePeriodTimer?.cancel(); // Cancel grace period timer
    _detectionDebounceTimer?.cancel(); // Cancel debounce timer

    // Make sure to stop any ongoing speech immediately
    _flutterTts.stop();

    // Safely stop camera and dispose resources
    if (_cameraController != null) {
      if (_cameraController!.value.isStreamingImages) {
        _cameraController!.stopImageStream().then((_) {
          _cameraController!.dispose();
        }).catchError((e) {
          debugPrint("Error stopping image stream: $e");
          // Still try to dispose the controller even if stopping stream failed
          _cameraController!.dispose();
        });
      } else {
        _cameraController!.dispose();
      }
    }

    _faceDetector.close(); // Release ML Kit resources
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final permissionStatus = await Permission.camera.request();
    if (!permissionStatus.isGranted) {
      setState(() {
        _instruction = permissionStatus.isPermanentlyDenied
            ? "Camera permission is permanently denied. Please enable it in app settings."
            : "Camera permission is required for face verification.";
      });
      return;
    }

    try {
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

      // Lock the orientation to portrait
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
        _startFaceDetection();
      }
    } catch (e) {
      debugPrint("Camera initialization error: $e");
      setState(() {
        _instruction = "Error initializing camera. Please try again.";
      });
    }
  }

  void _startFaceDetection() {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    _cameraController!.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      try {
        final inputImage = await _processImageForDetection(image);
        if (inputImage != null) {
          final faces = await _faceDetector.processImage(inputImage);
          if (mounted) {
            _updateVerificationState(faces);
          }
        }
      } catch (e) {
        debugPrint("Face detection error: $e");
      } finally {
        _isDetecting = false;
      }
    });
  }

  Future<InputImage?> _processImageForDetection(CameraImage image) async {
    try {
      // Get the camera rotation based on the device orientation
      final deviceOrientation = MediaQuery.of(context).orientation;
      late final InputImageRotation imageRotation;

      if (Platform.isAndroid) {
        switch (deviceOrientation) {
          case Orientation.portrait:
            imageRotation = InputImageRotation.rotation90deg;
            break;
          case Orientation.landscape:
            imageRotation = InputImageRotation.rotation0deg;
            break;
          default:
            imageRotation = InputImageRotation.rotation90deg;
            break;
        }
      } else {
        imageRotation = InputImageRotation.rotation0deg;
      }

      if (Platform.isAndroid) {
        // Handle YUV420 format for Android
        final WriteBuffer allBytes = WriteBuffer();
        for (var plane in image.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        final bytes = allBytes.done().buffer.asUint8List();

        final imageSize = Size(image.width.toDouble(), image.height.toDouble());

        final inputImageData = InputImageMetadata(
          size: imageSize,
          rotation: imageRotation,
          format: InputImageFormat.yuv420,
          bytesPerRow: image.planes[0].bytesPerRow,
        );

        return InputImage.fromBytes(
          bytes: bytes,
          metadata: inputImageData,
        );
      } else {
        // Handle BGRA8888 format for iOS
        final WriteBuffer allBytes = WriteBuffer();
        for (var plane in image.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        final bytes = allBytes.done().buffer.asUint8List();

        return InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: imageRotation,
            format: InputImageFormat.bgra8888,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error processing image: $e");
      return null;
    }
  }

  void _updateVerificationState(List<Face> faces) {
    if (faces.isEmpty) {
      setState(() {
        _borderColor = Colors.red;
        _instruction = "No face detected";
        _consecutiveCenteredFrames = 0;
      });
      return;
    }

    final face = faces.first;
    final isCentered = _checkFaceCentered(face);

    setState(() {
      switch (_currentStep) {
        case VerificationStep.centerFace:
          _handleCenterStep(face, isCentered);
          break;
        case VerificationStep.blink:
          _handleBlinkStep(face, isCentered);
          break;
        case VerificationStep.turnLeft:
          _handleTurnLeftStep(face, isCentered);
          break;
        case VerificationStep.turnRight:
          _handleTurnRightStep(face, isCentered);
          break;
        case VerificationStep.completed:
          _handleCompletion();
          break;
      }
    });
  }

  bool _checkFaceCentered(Face face) {
    if (_cameraController?.value.previewSize == null) return false;

    final previewSize = _cameraController!.value.previewSize!;
    final boundingBox = face.boundingBox;

    final centerX = boundingBox.center.dx;
    final centerY = boundingBox.center.dy;
    final imageCenterX = previewSize.width / 2;
    final imageCenterY = previewSize.height / 2;

    final toleranceX = previewSize.width * 0.2;
    final toleranceY = previewSize.height * 0.2;

    return (centerX - imageCenterX).abs() <= toleranceX &&
        (centerY - imageCenterY).abs() <= toleranceY;
  }

  void _handleCenterStep(Face face, bool isCentered) {
    if (isCentered) {
      _consecutiveCenteredFrames++;
      _borderColor = Colors.green;
      _instruction = "Hold still...";

      if (_consecutiveCenteredFrames >= 10) {
        _currentStep = VerificationStep.blink;
        _instruction = "Please blink naturally";
        _consecutiveCenteredFrames = 0;
        HapticFeedback.lightImpact();
      }
    } else {
      _consecutiveCenteredFrames = 0;
      _borderColor = Colors.yellow;
      _instruction = "Center your face in the frame";
    }
  }

  void _handleBlinkStep(Face face, bool isCentered) {
    if (!isCentered) {
      _borderColor = Colors.yellow;
      _instruction = "Keep your face centered";
      return;
    }

    final leftEyeOpen = face.leftEyeOpenProbability ?? 1.0;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 1.0;
    final isEyeOpen = leftEyeOpen > 0.8 && rightEyeOpen > 0.8;

    if (_wasEyeOpen && !isEyeOpen) {
      _blinkCount++;
      HapticFeedback.lightImpact();

      if (_blinkCount >= 2) {
        _currentStep = VerificationStep.turnLeft;
        _instruction = "Slowly turn your head to the left";
      } else {
        _instruction = "Blink again ($_blinkCount/2)";
      }
    }

    _wasEyeOpen = isEyeOpen;
    _borderColor = Colors.green;
  }

  void _handleTurnLeftStep(Face face, bool isCentered) {
    final headAngle = face.headEulerAngleY ?? 0;

    if (headAngle < -20) {
      _currentStep = VerificationStep.turnRight;
      _instruction = "Now turn your head to the right";
      HapticFeedback.lightImpact();
    } else {
      _instruction = "Keep turning left slowly";
    }

    _borderColor = isCentered ? Colors.green : Colors.yellow;
  }

  void _handleTurnRightStep(Face face, bool isCentered) {
    final headAngle = face.headEulerAngleY ?? 0;

    if (headAngle > 20) {
      _currentStep = VerificationStep.completed;
      _instruction = "Verification successful!";
      HapticFeedback.lightImpact();
      _handleCompletion();
    } else {
      _instruction = "Keep turning right slowly";
    }

    _borderColor = isCentered ? Colors.green : Colors.yellow;
  }

  void _handleCompletion() {
    // Only try to stop the stream if it's actually running
    if (_cameraController != null &&
        _cameraController!.value.isStreamingImages) {
      _cameraController!.stopImageStream().then((_) {
        // Call verification after stopping the stream
        if (mounted) {
          ref.read(verficationVideoProvider.notifier).verificationMe();
        }
      }).catchError((e) {
        debugPrint("Error stopping image stream: $e");
        // Still try to verify even if stopping stream failed
        if (mounted) {
          ref.read(verficationVideoProvider.notifier).verificationMe();
        }
      });
    } else {
      // If stream is not running, just verify
      if (mounted) {
        ref.read(verficationVideoProvider.notifier).verificationMe();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the verification provider state for success/error feedback
    ref.listen<VerificationState>(verficationVideoProvider, (prev, current) {
      if (current.isSuccess) {
        if (mounted) {
          // Show success feedback
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Verification Submitted Successfully!"),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to dashboard after successful submission
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.dashboardPage, (route) => false);
        }
      } else if (current.isError) {
        if (mounted) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  current.errorMessage ?? 'Verification submission failed'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  // Reset verification state
                  setState(() {
                    _currentStep = VerificationStep.centerFace;
                    _blinkCount = 0;
                    _wasEyeOpen = true;
                    _consecutiveCenteredFrames = 0;
                    _instruction = "Center your face in the frame";
                    _borderColor = Colors.grey;
                  });
                  // Restart camera if needed
                  _initializeCamera();
                },
              ),
            ),
          );
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
                    onPressed: _initializeCamera, // Retry
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress indicator for current step
                if (_currentStep != VerificationStep.completed)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getStepIcon(_currentStep),
                          color: AppColors.metalPinkColour,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getStepProgress(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // Main action button
                if (_currentStep == VerificationStep.completed)
                  BaseButton(
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
                else
                  // Reset button for non-completed states
                  OutlinedButton.icon(
                    onPressed: _initializeCamera,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Start Over"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.metalPinkColour,
                      side: BorderSide(color: AppColors.metalPinkColour),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStepIcon(VerificationStep step) {
    switch (step) {
      case VerificationStep.centerFace:
        return Icons.center_focus_strong;
      case VerificationStep.blink:
        return Icons.visibility;
      case VerificationStep.turnLeft:
        return Icons.arrow_back;
      case VerificationStep.turnRight:
        return Icons.arrow_forward;
      case VerificationStep.completed:
        return Icons.check_circle;
    }
  }

  String _getStepProgress() {
    switch (_currentStep) {
      case VerificationStep.centerFace:
        return "Step 1: Center your face";
      case VerificationStep.blink:
        return "Step 2: Blink naturally";
      case VerificationStep.turnLeft:
        return "Step 3: Turn left";
      case VerificationStep.turnRight:
        return "Step 4: Turn right";
      case VerificationStep.completed:
        return "Verification complete!";
    }
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
