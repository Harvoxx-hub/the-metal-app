import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/chat/presentation/widget/profile.image.dart';
import 'package:metal/features/eyes/domain/entries/status.model.dart';
import 'package:metal/features/eyes/presentation/widget/dash.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:video_player/video_player.dart';

class ViewEyes extends StatefulWidget {
  ViewEyes({super.key, required this.eyes});
  static const name = 'viewEyes';
  static const route = name;

  List<StatusModel> eyes;

  @override
  State<ViewEyes> createState() => _ViewEyesState();
}

class _ViewEyesState extends State<ViewEyes> {
  int currentPage = 0;
  PageController pageController = PageController(
    viewportFraction: 0.8,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              DashWidget(
                items: widget.eyes.length,
                currentIndex: currentPage,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const ProfileImage(
                      height: 50,
                      width: 50,
                    ),
                    const Gap(10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextView(
                          text: "My Eyes",
                          color: Colors.white,
                        ),
                        Gap(10),
                        TextView(
                          text: "Yesterday, 3:00PM",
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Assets.icons.srMenuVerticalLite.svg()
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  controller: pageController,
                  itemCount: widget.eyes.length,
                  itemBuilder: (context, index) {
                    final eye = widget.eyes[index];
                    return _buildMediaWidget(eye);
                  },
                ),
              ),
            ],
          ),
        ));
  }
}

Widget _buildMediaWidget(StatusModel eye) {
  if (eye.file != null) {
    if (eye.file!.endsWith('.mp4')) {
      return VideoPlayerWidget(videoUrl: eye.file!);
    } else {
      return Image.network(eye.file!);
    }
  } else {
    return const SizedBox(); // Handle case where file URL is null
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller),
          IconButton(
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
