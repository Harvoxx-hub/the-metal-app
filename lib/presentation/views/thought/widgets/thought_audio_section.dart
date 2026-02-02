import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/permission_helper.dart';
import 'package:metal/presentation/views/chat/widgets/voice_recording_widget.dart';
import 'package:metal/presentation/views/chat/widgets/audio_player_widget.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

/// Audio section for thought creation - allows recording and playback
class ThoughtAudioSection extends StatefulWidget {
  final Function(String audioPath, int duration) onAudioRecorded;
  final VoidCallback onAudioDeleted;
  final String? audioUrl;
  final int? audioDuration;

  const ThoughtAudioSection({
    super.key,
    required this.onAudioRecorded,
    required this.onAudioDeleted,
    this.audioUrl,
    this.audioDuration,
  });

  @override
  State<ThoughtAudioSection> createState() => _ThoughtAudioSectionState();
}

class _ThoughtAudioSectionState extends State<ThoughtAudioSection> {
  bool _isRecording = false;
  String? _recordedAudioPath;
  int? _recordedDuration;

  @override
  void initState() {
    super.initState();
    // If audioUrl is provided, it means we have existing audio
    if (widget.audioUrl != null) {
      _recordedAudioPath = widget.audioUrl;
      _recordedDuration = widget.audioDuration;
    }
  }

  Future<void> _startRecording() async {
    // Request permission
    final hasPermission =
        await PermissionHelper.requestMicrophonePermission(context);
    if (!hasPermission) {
      return;
    }

    if (mounted) {
      setState(() {
        _isRecording = true;
      });
    }
  }

  void _handleRecordingComplete(String audioPath) {
    // Calculate duration from file (backend requires 1-120 seconds for voice thoughts)
    _calculateDuration(audioPath).then((duration) {
      if (mounted) {
        final safeDuration = duration < 1 ? 1 : (duration > 120 ? 120 : duration);
        setState(() {
          _isRecording = false;
          _recordedAudioPath = audioPath;
          _recordedDuration = safeDuration;
        });
        widget.onAudioRecorded(audioPath, safeDuration);
      }
    });
  }

  void _handleRecordingCancel() {
    if (mounted) {
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<int> _calculateDuration(String audioPath) async {
    try {
      final playerController = PlayerController();
      await playerController.preparePlayer(path: audioPath);
      final durationMs = await playerController.getDuration(DurationType.max);
      playerController.dispose();
      final seconds = durationMs ~/ 1000;
      return seconds < 1 ? 1 : seconds;
    } catch (e) {
      print('Error calculating duration: $e');
      return 1;
    }
  }

  void _deleteAudio() {
    if (_recordedAudioPath != null) {
      // Delete local file if it exists
      final file = File(_recordedAudioPath!);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }

    setState(() {
      _recordedAudioPath = null;
      _recordedDuration = null;
    });
    widget.onAudioDeleted();
  }

  @override
  Widget build(BuildContext context) {
    // Show recording widget when recording
    if (_isRecording) {
      return VoiceRecordingWidget(
        onRecordingComplete: _handleRecordingComplete,
        onCancel: _handleRecordingCancel,
      );
    }

    // Show audio player if audio exists
    if (_recordedAudioPath != null && _recordedAudioPath!.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.mic,
                  color: AppColors.metalPinkColour,
                  size: 20,
                ),
                const Gap(8),
                Expanded(
                  child: AudioPlayerWidget(
                    audioUrl: _recordedAudioPath!,
                    isMe: true,
                  ),
                ),
                const Gap(8),
                GestureDetector(
                  onTap: _deleteAudio,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            if (_recordedDuration != null) ...[
              const Gap(4),
              TextView(
                text: 'Duration: ${_formatDuration(_recordedDuration!)}',
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ],
          ],
        ),
      );
    }

    // Show record button
    return GestureDetector(
      onTap: _startRecording,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.metalPinkColour.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic,
                color: AppColors.metalPinkColour,
                size: 24,
              ),
            ),
            const Gap(12),
            const Expanded(
              child: TextView(
                text: 'Add voice note (optional)',
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
