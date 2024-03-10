import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/core/utils/screen.size.dart';
import 'package:metal/features/eyes/provider/upload.eyes.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:video_player/video_player.dart';

class EyePreviewMedia extends ConsumerStatefulWidget {
  const EyePreviewMedia({super.key, required this.media});
  static const name = 'EyePreviewMedia';
  static const route = '$name';
  final XFile media;

  @override
  ConsumerState<EyePreviewMedia> createState() => _EyePreviewMediaState();
}

class _EyePreviewMediaState extends ConsumerState<EyePreviewMedia> {
  late bool _isVideo;
  late VideoPlayerController _videoController;
  late bool _isVideoPlaying;
  @override
  void initState() {
    super.initState();
    _isVideo = widget.media.path.endsWith('.mp4');
    if (_isVideo) {
      _videoController = VideoPlayerController.file(File(widget.media.path))
        ..initialize().then((_) {
          setState(() {});
          _videoController.play();
        });
      _videoController.addListener(() {
        if (_videoController.value.position ==
            _videoController.value.duration) {
          setState(() {
            _isVideoPlaying = false;
          });
        }
      });
    }
  }

  void _toggleVideoPlayPause() {
    if (_isVideoPlaying) {
      _videoController.pause();
    } else {
      _videoController.play();
    }
    setState(() {
      _isVideoPlaying = !_isVideoPlaying;
    });
  }

  @override
  void dispose() {
    if (_isVideo) {
      _videoController.dispose();
    }
    super.dispose();
  }

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final eyeState = ref.watch(uploadEyesProvider);
    ref.listen<UploadEyeState>(uploadEyesProvider, (prev, current) {
      if (current.isSuccess) {
            Navigator.pushReplacementNamed(context,   AppRoutes.dashboardPage
                 );
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                TextView(
                  text: "Upload to eyes",
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
              ],
            ),
            const Gap(20),
            Expanded(
              child: _isVideo
                  ? GestureDetector(
                      onTap: _isVideo ? _toggleVideoPlayPause : null,
                      child: Center(
                          child: _videoController.value.isInitialized
                              ? AspectRatio(
                                  aspectRatio:
                                      _videoController.value.aspectRatio,
                                  child: VideoPlayer(_videoController),
                                )
                              : const CircularProgressIndicator()),
                    )
                  : Image.file(File(widget.media.path)),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: EditFormField(
                      label: ' Say something about this Photo',
                      controller: _controller,
                      keyboardType: TextInputType.text,
                      fillColor: AppColors.metalBrownColour1,
                      focusedColorBorder: AppColors.metalBrownColour1,
                      radius: 20,

                      cursorColor: Colors.white,

                      labelColor: Colors.white.withOpacity(0.75),

                      prefixWidget: Assets.images.imagePlus.image(),
                      // validator: Validators.validatePlainPassword(),
                    ),
                  ),
                  const Gap(10),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD9197B),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: eyeState.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Center(
                            child: GestureDetector(
                              onTap: () => ref
                                  .read(uploadEyesProvider.notifier)
                                  .uploadEyes(
                                    _controller.text,
                                    File(widget.media.path),
                                  ),
                              child: SvgPicture.asset(
                                Assets.icons.chatsWindowactiveSend.path,
                                height: 24,
                                width: 24,
                              ),
                            ),
                          ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
