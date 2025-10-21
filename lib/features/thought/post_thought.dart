import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'dart:io';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:audio_waveforms/audio_waveforms.dart' hide PlayerState;
import 'package:permission_handler/permission_handler.dart';

import 'package:metal/features/dashboard.dart/widget/complete.profile.dialog.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/features/thought/provider/send.thoughts.dart';
import 'package:metal/features/thought/provider/edit.thoughts.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/features/thought/data/domain/entries/thought.model.dart';
import 'package:metal/features/community/data/domain/entries/community_metadata.model.dart';

class PostThought extends ConsumerStatefulWidget {
  const PostThought({
    super.key,
    this.thoughtModel,
    this.communityMetadata,
  });

  final ThoughtModel? thoughtModel;
  final CommunityMetadata? communityMetadata;

  @override
  ConsumerState<PostThought> createState() => _PostThoughtState();
}

class _PostThoughtState extends ConsumerState<PostThought> {
  late TextEditingController controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final RecorderController _recorderController;
  String? _recordedFilePath;
  int? _recordedDurationSec;
  bool _isRecording = false;
  Timer? _recordTimer;
  int _currentRecordSeconds = 0;
  bool _isPreviewPlaying = false;
  final Stopwatch _recordStopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    controller =
        TextEditingController(text: widget.thoughtModel?.content ?? '');
    _recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 16000;
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPreviewPlaying = state == PlayerState.playing;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _audioPlayer.dispose();
    _recorderController.dispose();
    _recordTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sendThoughtState = ref.watch(sendThoughtProvider);
    final editThoughtState = ref.watch(editThoughtProvider);
    final userModel = ref.watch(userStateProvider).data!;

    ref.listen<SendThoughtState>(sendThoughtProvider, (prev, current) {
      if (current.isSuccess) {
        Navigator.pop(context);
      }
    });

    ref.listen<EditThoughtState>(editThoughtProvider, (prev, current) {
      if (current.isSuccess) {
        Navigator.pop(context);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  ProfilePhoto(
                    verfly: false,
                    size: 24,
                    meltId: userModel.metal!,
                  ),
                  TextView(text: userModel.username ?? ''),
                  const Gap(5),
                  if (userModel.isVerified ?? false)
                    Assets.icons.checkVerified.svg(height: 16),
                  const Spacer(),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, child) {
                      final isTextNotEmpty = value.text.trim().isNotEmpty;
                      final canPost =
                          isTextNotEmpty || _recordedFilePath != null;
                      return PlainButton(
                        enabled: canPost,
                        buttonText:
                            widget.thoughtModel == null ? "Post" : "Update",
                        onPressed: canPost
                            ? () {
                                FocusScope.of(context).unfocus();

                                if (!(userModel.completedProfile ?? false)) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return const CustomDialog(
                                        content: ComplecteProfileDialog(),
                                      );
                                    },
                                  );
                                } else {
                                  if (widget.thoughtModel == null) {
                                    if (_recordedFilePath != null &&
                                        _recordedDurationSec != null) {
                                      ref
                                          .read(sendThoughtProvider.notifier)
                                          .sendVoiceThought(
                                            caption: controller.text.trim(),
                                            localFilePath: _recordedFilePath!,
                                            durationSeconds:
                                                _recordedDurationSec!,
                                            communityMetadata:
                                                widget.communityMetadata,
                                          );
                                    } else {
                                      ref
                                          .read(sendThoughtProvider.notifier)
                                          .sendThought(
                                            controller.text.trim(),
                                            communityMetadata:
                                                widget.communityMetadata,
                                          );
                                    }
                                  } else {
                                    ref
                                        .read(editThoughtProvider.notifier)
                                        .editThought(widget.thoughtModel!.id, {
                                      'content': controller.text.trim(),
                                      'updatedAt':
                                          DateTime.now().toIso8601String(),
                                    });
                                  }
                                }
                              }
                            : null,
                        width: 100,
                        loading: sendThoughtState.isLoading ||
                            editThoughtState.isLoading,
                      );
                    },
                  ),
                ]),
              ),
              // Community context display
              if (widget.communityMetadata != null) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.group,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          'Posting in: ${widget.communityMetadata!.communityName}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(8),
              ],
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: widget.thoughtModel == null
                          ? 'Express your Thought...'
                          : 'Edit your Thought...',
                      border: InputBorder.none,
                    ),
                    controller: controller,
                    style: const TextStyle(fontSize: 18),
                    autofocus: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                ),
              ),
              const Gap(8),
              _buildVoiceSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(_isRecording ? Icons.stop_circle : Icons.mic),
                color: _isRecording ? Colors.red : Colors.black87,
                onPressed: () async {
                  if (_isRecording) {
                    final path = await _recorderController.stop(false);
                    setState(() {
                      _isRecording = false;
                      _recordedFilePath = path;
                    });
                    _recordTimer?.cancel();
                    _recordStopwatch.stop();
                    final durMs = _recordStopwatch.elapsed.inMilliseconds;
                    setState(() {
                      _recordedDurationSec = (durMs / 1000).round();
                      _currentRecordSeconds = _recordedDurationSec ?? 0;
                    });
                  } else {
                    final mic = await Permission.microphone.request();
                    if (!mic.isGranted) return;
                    final dir =
                        await Directory.systemTemp.createTemp('voice_thought_');
                    final filePath =
                        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
                    await _recorderController.record(path: filePath);
                    setState(() {
                      _isRecording = true;
                      _recordedFilePath = null;
                      _recordedDurationSec = null;
                      _currentRecordSeconds = 0;
                    });
                    _recordTimer?.cancel();
                    _recordStopwatch
                      ..reset()
                      ..start();
                    _recordTimer =
                        Timer.periodic(const Duration(seconds: 1), (timer) {
                      if (!mounted) return;
                      setState(() {
                        _currentRecordSeconds =
                            _recordStopwatch.elapsed.inSeconds;
                      });
                    });
                  }
                },
              ),
              const Gap(8),
              if (_isRecording)
                Expanded(
                  child: AudioWaveforms(
                    enableGesture: false,
                    size: const Size(double.infinity, 40),
                    recorderController: _recorderController,
                    waveStyle: const WaveStyle(
                      showMiddleLine: false,
                      waveColor: Colors.pink,
                      extendWaveform: true,
                    ),
                  ),
                ),
              if (_isRecording) ...[
                const Gap(8),
                Text(
                  _formatDuration(_currentRecordSeconds),
                  style: const TextStyle(color: Colors.black54),
                ),
              ] else
                Text(_recordedDurationSec != null
                    ? _formatDuration(_recordedDurationSec!)
                    : 'Tap mic to record a voice thought'),
            ],
          ),
          if (_recordedFilePath != null) ...[
            const Gap(8),
            Row(
              children: [
                _isPreviewPlaying
                    ? IconButton(
                        icon: const Icon(Icons.pause),
                        onPressed: () async {
                          await _audioPlayer.pause();
                          setState(() {
                            _isPreviewPlaying = false;
                          });
                        },
                      )
                    : IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () async {
                          await _audioPlayer
                              .play(DeviceFileSource(_recordedFilePath!));
                          setState(() {
                            _isPreviewPlaying = true;
                          });
                        },
                      ),
                // IconButton(
                //   icon: const Icon(Icons.play_arrow),
                //   onPressed: () async {
                //     if (_recordedFilePath == null) return;
                //     await _audioPlayer
                //         .play(DeviceFileSource(_recordedFilePath!));
                //   },
                // ),
                // IconButton(
                //   icon: const Icon(Icons.pause),
                //   onPressed: () async {
                //     await _audioPlayer.pause();
                //   },
                // ),
                const Gap(8),
                Expanded(
                  child: StreamBuilder<Duration>(
                    stream: _audioPlayer.onDurationChanged,
                    builder: (context, durSnap) {
                      final totalSeconds = (durSnap.data?.inSeconds ?? 0) == 0
                          ? (_recordedDurationSec ?? 0)
                          : durSnap.data!.inSeconds;
                      return StreamBuilder<Duration>(
                        stream: _audioPlayer.onPositionChanged,
                        builder: (context, posSnap) {
                          final currentSeconds = (posSnap.data?.inSeconds ?? 0)
                              .clamp(0, totalSeconds);
                          final label = _isPreviewPlaying
                              ? 'Preview • ${_formatDuration(currentSeconds)} / ${_formatDuration(totalSeconds)}'
                              : 'Preview • ${_formatDuration(totalSeconds)}';
                          return Text(
                            label,
                            style: const TextStyle(color: Colors.black54),
                          );
                        },
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    setState(() {
                      _recordedFilePath = null;
                      _recordedDurationSec = null;
                    });
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString();
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
