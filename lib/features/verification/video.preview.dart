import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
 
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/core/utils/screen.size.dart';
 
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  const VideoPreview({super.key});
  static const name = 'VideoPreview';
  static const route = name;

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
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
    _videoPlayerController.pause(); // Pause the video

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
                _videoFile != null
                    ? FutureBuilder(
                        future: _initVideoPlayer(),
                        builder: (context, state) {
                          if (state.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else {
                            return VideoPlayer(_videoPlayerController);
                          }
                        },
                      )
                    : CameraPreview(_cameraController),
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
                      const TextView(
                          text: 'Viedo Preview',
                          fontSize: 20,
                          color: Colors.white),
                      const Spacer(),
                      _videoFile == null
                          ? const SizedBox()
                          : IconButton(
                              icon: Assets.icons.refresh
                                  .svg(width: 24, height: 24),
                              onPressed: () {
                                setState(() {
                                  _videoFile = null;
                                  _videoPlayerController.dispose();
                                });
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Spacer(),
                            _isRecording
                                ? PlainButton(
                                    color: AppColors.metalBlack30,
                                    buttonText: "Stop Recording",
                                    width: 200,
                                    onPressed: () {
                                      _recordVideo();
                                    })
                                : BaseButton(
                                    buttonText: _videoFile != null
                                        ? "Send Video"
                                        : "Start Recording",
                                    width: 200,
                                    leftIcon: _videoFile == null
                                        ? Assets.icons.videoCamera.svg(
                                            width: 24,
                                            height: 24,
                                            color: Colors.white)
                                        : null,
                                    rightIcon: _videoFile != null
                                        ? Assets.icons.chatsWindowactiveSend
                                            .svg(
                                                width: 24,
                                                height: 24,
                                                color: Colors.white)
                                        : null,
                                    onPressed: () {
                                      _videoFile != null
                                          ? {
                                              _videoPlayerController
                                                  .pause(),
                                                  Navigator.pop(context, _videoFile!.path ) // Pause the video
                                           // Navigate back when the FAB is pressed
                                            }
                                          : _recordVideo();
                                    }),
                            const Spacer(),
                          ],
                        ),
                        Gap(20.h),
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
}
