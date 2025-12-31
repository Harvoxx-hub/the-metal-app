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
  bool _hasError = false;
  bool _isLoading = true;
  bool _isCompleted = false; // Track if playback completed
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

  Future<void> _initPlayer() async {
    // Listen to duration
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
          _isLoading = false;
        });
      }
    });

    // Listen to position
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    // Listen to completion
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
          _isCompleted = true; // Mark as completed for replay handling
        });
      }
    });

    // Listen to state changes
    _playerStateSubscription =
        _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    // Load the audio source with error handling
    try {
      await _audioPlayer.setSourceUrl(widget.audioUrl);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('AudioPlayer error loading URL: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
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
    if (_hasError) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        // If playback completed, we need to reload the source and play from start
        // Just seeking/resuming causes timeout issues
        if (_isCompleted) {
          setState(() {
            _isCompleted = false;
            _position = Duration.zero;
          });
          // Stop and reload the source for clean replay
          await _audioPlayer.stop();
          await _audioPlayer.setSourceUrl(widget.audioUrl);
          await _audioPlayer.resume();
        } else if (_audioPlayer.state == PlayerState.stopped ||
            _audioPlayer.state == PlayerState.completed) {
          // Player stopped but not marked as completed - reload source
          await _audioPlayer.setSourceUrl(widget.audioUrl);
          await _audioPlayer.resume();
        } else {
          // Normal resume (e.g., after pause)
          await _audioPlayer.resume();
        }
      }
    } catch (e) {
      print('AudioPlayer toggle error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
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
    // Show error state
    if (_hasError) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: widget.isMe ? Colors.black : Colors.grey,
              size: 20,
            ),
            const Gap(8),
            TextView(
              text: 'Audio unavailable',
              fontSize: 12,
              color: widget.isMe ? Colors.black : Colors.grey,
            ),
          ],
        ),
      );
    }

    // Show loading state
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  !widget.isMe ? Colors.white70 : AppColors.metalPinkColour,
                ),
              ),
            ),
            const Gap(8),
            TextView(
              text: 'Loading...',
              fontSize: 12,
              color: widget.isMe ? Colors.black : Colors.grey,
            ),
          ],
        ),
      );
    }

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
                color: widget.isMe ? Colors.black : AppColors.metalPinkColour,
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
                            ? Colors.black.withValues(alpha: 0.3)
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
                              ? Colors.black
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
                  color: !widget.isMe
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
            color: !widget.isMe
                ? Colors.white.withValues(alpha: 0.8)
                : Colors.black54,
          ),
        ],
      ),
    );
  }
}
