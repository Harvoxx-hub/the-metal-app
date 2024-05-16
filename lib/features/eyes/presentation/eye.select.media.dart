import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/core/utils/screen.size.dart';
 
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';

import 'package:metal/widgets/text_views.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';

class EyeSelectMedia extends StatefulWidget {
  const EyeSelectMedia({super.key});
  static const name = 'EyeSelectMedia';
  static const route = name;

  @override
  State<EyeSelectMedia> createState() => _EyeSelectMediaState();
}

class _EyeSelectMediaState extends State<EyeSelectMedia> {
  bool _isLoading = true;
  late CameraController _cameraController;
  late VideoPlayerController _videoPlayerController;
  bool _isRecording = false;
  int _secondsRemaining = 0;
  late Timer _timer;
  XFile? _videoFile;
  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _timer.cancel();
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future _initVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(_videoFile!.path));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.play();
  }

  _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);
    _cameraController = CameraController(front, ResolutionPreset.max);
    await _cameraController.initialize();
    setState(() => _isLoading = false);
  }

  _switchToBackCamera() async {
    setState(() => _isLoading = true); // Set loading state while switching

    final cameras = await availableCameras();
    final back = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      // orElse: () => null, // Handle case where back camera is not available
    );

    _cameraController = CameraController(back, ResolutionPreset.max);
    await _cameraController.initialize();
    setState(() => _isLoading = false);
    }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsRemaining++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: _isLoading
          ? const CircularProgressIndicator()
          : Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_cameraController),
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Assets.icons.x.svg(width: 24, height: 24),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Assets.icons.refresh.svg(width: 24, height: 24),
                        onPressed: () {
                          _switchToBackCamera();
                        },
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Assets.icons.videoSquare.svg(
                        color: AppColors.metalPinkColour,
                        width: getDeviceWidth(context) * 0.4,
                        height: getDeviceHeight(context) * 0.4),
                  ),
                ),
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment .spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                pickImageOrVideo();
                              },
                              child: Assets.images.imagePlus.image(
                                height: 40,
                                width: 40,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: _takePicture,
                              onLongPress: _startVideoRecording,
                              onLongPressEnd: (_) => _stopVideoRecording(),
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                  child: Center(
                                    child: _isRecording
                                        ? const Icon(
                                            Icons.videocam,
                                            size: 40,
                                            color: Colors.red,
                                          )
                                        : const Icon(
                                            Icons.camera_alt,
                                            size: 40,
                                            color: Colors.black,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                        const Gap(20 ),
                        Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 20.0, bottom: 20.0),
                              child: Center(
                                child: TextView(
                                  text:
                                      '${formatDuration(Duration(seconds: _secondsRemaining))} secounds',
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            )),
                      ],
                    )),
              ],
            ),
    ));
  }

  _recordVideo() async {
    if (_isRecording) {
      _videoFile = await _cameraController.stopVideoRecording();
      setState(() => _isRecording = false);
      _timer.cancel();
      print('Video recorded to ${_videoFile!.path}');
      // final route = MaterialPageRoute(
      //   fullscreenDialog: true,
      //   builder: (_) => VideoPage(filePath: file.path),
      // );
      // Navigator.push(context, route);
    } else {
      startTimer();
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();

      setState(() => _isRecording = true);
    }
  }

  void _takePicture() async {
    if (!_cameraController.value.isTakingPicture) {
      try {
        final image = await _cameraController.takePicture();
        // Do something with the captured image
            Navigator.pushNamed(context, AppRoutes.eyePreviewMedia,  
            arguments: image
                 );
      
      } catch (e) {
        print('Error taking picture: $e');
      }
    }
  }

  void _startVideoRecording() async {
    if (!_cameraController.value.isRecordingVideo) {
      try {
        await _cameraController.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
      } catch (e) {
        print('Error starting video recording: $e');
      }
    }
  }

  void _stopVideoRecording() async {
    if (_cameraController.value.isRecordingVideo) {
      try {
        final video = await _cameraController.stopVideoRecording();
        setState(() {
          _isRecording = false;
        });
            Navigator.pushNamed(context, AppRoutes.eyePreviewMedia,  
            arguments: video
                 );
 
      } catch (e) {
        print('Error stopping video recording: $e');
      }
    }
  }

  Future pickImageOrVideo() async {
    final ImagePicker picker = ImagePicker();

    // Show options for picking an image or a video
    final pickedFile = await picker.pickMedia();
    if (pickedFile != null) {
      // User picked an image
          Navigator.pushNamed(context, AppRoutes.eyePreviewMedia,  
          arguments: pickedFile
                 );
     
    }

     
  }
}
