import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

/// Theme for the global audio player. Matches existing app design.
enum AudioPlayerTheme {
  /// Thought card, thought detail, create thought preview
  thought,

  /// Chat bubble sent by current user
  chatSent,

  /// Chat bubble received from other user
  chatReceived,
}

/// Global audio player used across the app: thought card, thought detail, chat.
/// Supports remote URLs (downloads then plays) and local file paths.
/// Uses [audio_waveforms] for waveform and playback.
class AudioPlayer extends StatefulWidget {
  final String audioUrl;
  final AudioPlayerTheme theme;

  const AudioPlayer({
    super.key,
    required this.audioUrl,
    this.theme = AudioPlayerTheme.thought,
  });

  /// Convenience for chat: pass [isMe] to pick chatSent vs chatReceived.
  factory AudioPlayer.chat({
    Key? key,
    required String audioUrl,
    required bool isMe,
  }) {
    return AudioPlayer(
      key: key,
      audioUrl: audioUrl,
      theme: isMe ? AudioPlayerTheme.chatSent : AudioPlayerTheme.chatReceived,
    );
  }

  @override
  State<AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  final PlayerController _controller = PlayerController();
  bool _prepared = false;
  bool _error = false;
  bool _loading = true;
  String? _localPath;
  bool _downloading = false;
  int _totalDurationMs = 0;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_localPath != null && _isRemoteUrl(widget.audioUrl)) {
      try {
        final f = File(_localPath!);
        if (f.existsSync()) f.deleteSync();
      } catch (_) {}
    }
    super.dispose();
  }

  static bool _isRemoteUrl(String path) {
    final uri = Uri.tryParse(path);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Future<void> _prepare() async {
    final url = widget.audioUrl;
    if (url.isEmpty) {
      if (mounted)
        setState(() {
          _error = true;
          _loading = false;
        });
      return;
    }

    try {
      if (_isRemoteUrl(url)) {
        await _download(url);
        if (_localPath == null) {
          if (mounted)
            setState(() {
              _error = true;
              _loading = false;
            });
          return;
        }
      } else {
        _localPath = url;
      }

      await _controller.preparePlayer(
        path: _localPath!,
        shouldExtractWaveform: true,
      );

      final totalMs = await _controller.getDuration(DurationType.max);
      if (mounted)
        setState(() {
          _prepared = true;
          _loading = false;
          _totalDurationMs = totalMs > 0 ? totalMs : 0;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = true;
          _loading = false;
        });
    }
  }

  Future<void> _download(String url) async {
    if (!mounted) return;
    setState(() {
      _downloading = true;
    });

    try {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/audio_${DateTime.now().microsecondsSinceEpoch}.m4a';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        await File(path).writeAsBytes(res.bodyBytes);
        if (mounted)
          setState(() {
            _localPath = path;
            _downloading = false;
          });
      } else {
        throw Exception('${res.statusCode}');
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _downloading = false;
        });
      rethrow;
    }
  }

  static String _formatDuration(Duration d) {
    final totalSeconds = d.inSeconds;
    if (totalSeconds < 0) return '0:00';
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Button background: pink for thought/sent, white for received (so icon pops).
  Color get _buttonColor {
    switch (widget.theme) {
      case AudioPlayerTheme.thought:
      case AudioPlayerTheme.chatSent:
        return AppColors.metalPinkColour;
      case AudioPlayerTheme.chatReceived:
        return Colors.white;
    }
  }

  /// Icon on button: white on pink for thought/sent, pink on white for received.
  Color get _buttonIconColor {
    switch (widget.theme) {
      case AudioPlayerTheme.thought:
      case AudioPlayerTheme.chatSent:
        return Colors.white;
      case AudioPlayerTheme.chatReceived:
        return AppColors.metalPinkColour;
    }
  }

  Color get _fixedWaveColor {
    switch (widget.theme) {
      case AudioPlayerTheme.thought:
      case AudioPlayerTheme.chatSent:
        return const Color.fromARGB(255, 238, 186, 186);
      case AudioPlayerTheme.chatReceived:
        return Colors.white.withOpacity(0.3);
    }
  }

  Color get _liveWaveColor {
    switch (widget.theme) {
      case AudioPlayerTheme.thought:
      case AudioPlayerTheme.chatSent:
        return AppColors.metalPinkColour;
      case AudioPlayerTheme.chatReceived:
        return Colors.white;
    }
  }

  Color get _textColor {
    switch (widget.theme) {
      case AudioPlayerTheme.thought:
      case AudioPlayerTheme.chatSent:
        return Colors.grey.shade600;
      case AudioPlayerTheme.chatReceived:
        return Colors.white.withOpacity(0.9);
    }
  }

  Color get _textColorPlaying {
    switch (widget.theme) {
      case AudioPlayerTheme.thought:
      case AudioPlayerTheme.chatSent:
        return AppColors.metalPinkColour;
      case AudioPlayerTheme.chatReceived:
        return Colors.white;
    }
  }

  Color get _loadingColor {
    switch (widget.theme) {
      case AudioPlayerTheme.thought:
      case AudioPlayerTheme.chatSent:
        return AppColors.metalPinkColour;
      case AudioPlayerTheme.chatReceived:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: _textColor, size: 20),
            const Gap(8),
            TextView(
                text: 'Audio unavailable', fontSize: 12, color: _textColor),
          ],
        ),
      );
    }

    if (_loading || _downloading || !_prepared) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_loadingColor),
              ),
            ),
            const Gap(8),
            TextView(
              text: _downloading ? 'Loading audio...' : 'Preparing...',
              fontSize: 12,
              color: _textColor,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamBuilder<PlayerState>(
            stream: _controller.onPlayerStateChanged,
            builder: (context, snap) {
              final playing = snap.data == PlayerState.playing;
              return GestureDetector(
                onTap: () async {
                  if (playing) {
                    await _controller.pausePlayer();
                  } else {
                    try {
                      // After playback completes, state is stopped and startPlayer() no-ops.
                      // Re-prepare so we go back to initialized, then start.
                      if (_controller.playerState == PlayerState.stopped &&
                          _localPath != null) {
                        await _controller.preparePlayer(
                          path: _localPath!,
                          shouldExtractWaveform: true,
                        );
                      }
                      await _controller.startPlayer();
                    } catch (e) {
                      if (mounted) setState(() => _error = true);
                    }
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _buttonColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.metalPinkColour.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    playing ? Icons.pause : Icons.play_arrow,
                    color: _buttonIconColor,
                    size: 20,
                  ),
                ),
              );
            },
          ),
          const Gap(12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 30,
                  child: AudioFileWaveforms(
                    size: const Size(double.infinity, 30),
                    playerController: _controller,
                    waveformType: WaveformType.long,
                    playerWaveStyle: PlayerWaveStyle(
                      fixedWaveColor: _fixedWaveColor,
                      liveWaveColor: _liveWaveColor,
                      showSeekLine: false,
                      showTop: true,
                      showBottom: true,
                      scaleFactor: 100,
                      spacing: 5,
                    ),
                  ),
                ),
                const Gap(4),
                StreamBuilder<int>(
                  stream: _controller.onCurrentDurationChanged,
                  builder: (context, positionSnap) {
                    final currentMs = positionSnap.data ?? 0;
                    final totalMs = _totalDurationMs > 0
                        ? _totalDurationMs
                        : _controller.maxDuration;
                    final total =
                        Duration(milliseconds: totalMs > 0 ? totalMs : 0);
                    final current = Duration(
                        milliseconds: currentMs.clamp(
                            0, totalMs > 0 ? totalMs : currentMs));
                    final playing = _controller.playerState.isPlaying;
                    final label = totalMs > 0
                        ? '${_formatDuration(current)} / ${_formatDuration(total)}'
                        : _formatDuration(total);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextView(
                          text: label,
                          fontSize: 11,
                          color: playing ? _textColorPlaying : _textColor,
                          fontWeight: FontWeight.w500,
                        ),
                        if (playing)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _textColorPlaying,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
