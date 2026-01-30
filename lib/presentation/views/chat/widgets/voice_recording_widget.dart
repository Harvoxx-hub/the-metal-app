import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:permission_handler/permission_handler.dart';

/// Voice recording widget with waveform visualization
class VoiceRecordingWidget extends StatefulWidget {
  final Function(String audioPath) onRecordingComplete;
  final VoidCallback onCancel;

  const VoiceRecordingWidget({
    super.key,
    required this.onRecordingComplete,
    required this.onCancel,
  });

  @override
  State<VoiceRecordingWidget> createState() => _VoiceRecordingWidgetState();
}

class _VoiceRecordingWidgetState extends State<VoiceRecordingWidget> {
  late RecorderController _recorderController;
  bool _isPaused = false;
  bool _isInitializing = true;
  String _recordingTime = '00:00';
  Timer? _timer;
  int _recordingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100
      ..bitRate = 128000; // Higher bitrate for better quality, reduces echo artifacts

    // Start recording asynchronously
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRecording();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorderController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      // Permission is already checked in parent, just start recording
      await _recorderController.record();

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });

        // Start timer
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {
              _recordingSeconds++;
              _recordingTime = _formatDuration(_recordingSeconds);
            });
          }
        });
      }
    } catch (e) {
      print('Error starting recording: $e');
      if (mounted) {
        widget.onCancel();
      }
    }
  }

  Future<void> _pauseRecording() async {
    await _recorderController.pause();
    _timer?.cancel();
    setState(() {
      _isPaused = true;
    });
  }

  Future<void> _resumeRecording() async {
    await _recorderController.record();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingSeconds++;
        _recordingTime = _formatDuration(_recordingSeconds);
      });
    });
    setState(() {
      _isPaused = false;
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await _recorderController.stop();
    if (path != null && path.isNotEmpty) {
      widget.onRecordingComplete(path);
    } else {
      widget.onCancel();
    }
  }

  Future<void> _cancelRecording() async {
    _timer?.cancel();
    final path = await _recorderController.stop();
    // Delete the file if it exists
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    widget.onCancel();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while initializing
    if (_isInitializing) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: const SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(strokeWidth: 2),
              Gap(12),
              TextView(
                text: 'Preparing to record...',
                fontSize: 14,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Slide to cancel hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chevron_left,
                  color: Colors.grey[400],
                  size: 20,
                ),
                TextView(
                  text: 'Slide to cancel',
                  fontSize: 12,
                  color: Colors.grey[600]!,
                ),
              ],
            ),
            const Gap(12),
            // Waveform and controls
            Row(
              children: [
                // Delete/Cancel button
                GestureDetector(
                  onTap: _cancelRecording,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red[400],
                      size: 24,
                    ),
                  ),
                ),
                const Gap(12),
                // Waveform and time
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.metalPinkColour.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        // Recording indicator
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Gap(12),
                        // Time
                        TextView(
                          text: _recordingTime,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.metalBlack,
                        ),
                        const Gap(12),
                        // Waveform
                        Expanded(
                          child: AudioWaveforms(
                            size: Size(MediaQuery.of(context).size.width, 40),
                            recorderController: _recorderController,
                            waveStyle: WaveStyle(
                              waveColor: AppColors.metalPinkColour,
                              showDurationLabel: false,
                              spacing: 4,
                              showBottom: false,
                              extendWaveform: true,
                              showMiddleLine: false,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(12),
                // Pause/Resume button
                GestureDetector(
                  onTap: _isPaused ? _resumeRecording : _pauseRecording,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPaused ? Icons.play_arrow : Icons.pause,
                      color: AppColors.metalBlack,
                      size: 24,
                    ),
                  ),
                ),
                const Gap(12),
                // Send button
                GestureDetector(
                  onTap: _stopRecording,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: AppColors.metalPinkColour,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Assets.icons.chatsWindowactiveSend.svg(
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
