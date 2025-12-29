import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:gap/gap.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

/// Audio player widget for voice messages
class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final bool isMe;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    required this.isMe,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initPlayer();
  }

  void _initPlayer() {
    // Listen to duration
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    // Listen to position
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    // Listen to completion
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });

    // Listen to state changes
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    // Load the audio source
    _audioPlayer.setSourceUrl(widget.audioUrl);
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause button
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.isMe
                    ? Colors.white.withValues(alpha: 0.3)
                    : AppColors.metalPinkColour.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: widget.isMe ? Colors.white : AppColors.metalPinkColour,
                size: 20,
              ),
            ),
          ),
          const Gap(8),
          // Waveform representation (simplified with progress bar)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress bar
                Stack(
                  children: [
                    // Background
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: widget.isMe
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Progress
                    FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: widget.isMe
                              ? Colors.white
                              : AppColors.metalPinkColour,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                // Time
                TextView(
                  text: _isPlaying || _position.inMilliseconds > 0
                      ? _formatDuration(_position)
                      : _formatDuration(_duration),
                  fontSize: 11,
                  color: widget.isMe
                      ? Colors.white.withValues(alpha: 0.8)
                      : Colors.black54,
                ),
              ],
            ),
          ),
          const Gap(8),
          // Duration
          TextView(
            text: _formatDuration(_duration),
            fontSize: 11,
            color: widget.isMe
                ? Colors.white.withValues(alpha: 0.8)
                : Colors.black54,
          ),
        ],
      ),
    );
  }
}
