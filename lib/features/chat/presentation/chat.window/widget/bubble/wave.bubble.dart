import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:metal/features/chat/provider/audio.manger.notifier.dart';
import 'package:path_provider/path_provider.dart';

class WaveBubble extends ConsumerStatefulWidget {
  final bool isSender;
  final String? path; // Path can be a local file path or a URL
  final double? width;

  const WaveBubble({
    super.key,
    this.width,
    this.isSender = false,
    this.path,
  });

  @override
  ConsumerState<WaveBubble> createState() => _WaveBubbleState();
}

class _WaveBubbleState extends ConsumerState<WaveBubble> {
  late PlayerController controller;
  late StreamSubscription<PlayerState> playerStateSubscription;
  Map<String, PlayerController> playerControllers = {};
  String? localPath;

  String audioDuration = '';
  bool isDownloading = false;

  final playerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: Colors.white54,
    liveWaveColor: Colors.white,
    showSeekLine: false,
    showTop: false,
    showBottom: false,
    scaleFactor: 50,
    spacing: 6,
  );

  @override
  void initState() {
    super.initState();
    controller = PlayerController();
    _preparePlayer();
    playerStateSubscription = controller.onPlayerStateChanged.listen((_) {
      setState(() {});
    });
  }

  bool _isUrl(String path) {
    final uri = Uri.tryParse(path);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Future<void> _downloadFile(String url) async {
    if (!mounted) return;

    setState(() {
      isDownloading = true;
    });

    try {
      // Generate a unique filename for the URL using its hash
      final tempDir = await getTemporaryDirectory();
      final fileName = DateTime.timestamp()
          .microsecondsSinceEpoch; // Use MD5 hash for unique file name
      final filePath = '${tempDir.path}/$fileName.m4a';
      final file = File(filePath);

      // Check if the file already exists
      if (await file.exists()) {
        debugPrint("File already cached: $filePath");
        localPath = file.path;
      } else {
        debugPrint("Downloading file: $url");
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          localPath = file.path;
        } else {
          throw Exception("Failed to download file");
        }
      }
    } catch (e) {
      debugPrint("Error downloading file: $e");
      localPath = null;
    } finally {
      if (!mounted) return;
      setState(() {
        isDownloading = false;
      });
    }
  }

  Future<void> _preparePlayer() async {
    if (widget.path == null) return;

    if (_isUrl(widget.path!)) {
      await _downloadFile(widget.path!);
      if (localPath == null || !mounted) return;
    } else {
      localPath = widget.path;
    }

    await controller.preparePlayer(
      path: localPath!,
      shouldExtractWaveform: true,
    );
    //   ref.read(playerManagerProvider).preparePlayer(localPath!);

    // Extract waveform data and get audio duration
    final durationInMs = await controller.getDuration();
    if (!mounted) return;
    setState(() {
      audioDuration = _formatDuration(Duration(milliseconds: durationInMs));
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    playerStateSubscription.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerManager = ref.watch(playerManagerProvider);
    ref.listen(playerManagerProvider, (prev, current) {
      //    debugPrint('Login state changed: ${current.currentPath}');
      if (playerManager.currentPath == localPath) {
        controller.playerState.isPlaying
            ? controller.pausePlayer()
            : {
                controller.startPlayer(),
                controller.setFinishMode(finishMode: FinishMode.pause)
              };
      } else {
        controller.pausePlayer();
      }
    });

    return localPath != null || isDownloading
        ? Container(
            padding: EdgeInsets.only(
              bottom: 6,
              right: widget.isSender ? 10 : 10,
              top: 6,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: widget.isSender
                  ? isDownloading
                      ? Colors.pink.withOpacity(0.3)
                      : Colors.pink
                  : isDownloading
                      ? Colors.grey[300]!.withOpacity(0.3)
                      : Colors.grey[300],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () async {
                    ref.read(playerManagerProvider).togglePlayPause(localPath!);
                  },
                  icon: Icon(
                    controller.playerState.isPlaying
                        ? Icons.stop
                        : Icons.play_arrow,
                  ),
                  color: Colors.white,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                AudioFileWaveforms(
                  size: Size(MediaQuery.of(context).size.width / 2.5, 20),
                  playerController: controller,
                  waveformType: WaveformType.long,
                  playerWaveStyle: playerWaveStyle,
                ),
                if (!isDownloading) ...[
                  const SizedBox(width: 10),
                  Text(
                    audioDuration,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          )
        : const SizedBox.shrink();
  }
}
