import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';

import 'package:metal/features/thought/data/domain/entries/thought.model.dart';

import 'package:metal/features/thought/presentation/comment_bottom_sheet.dart';

import 'package:metal/features/thought/provider/get.thought.by.id.dart';
import 'package:metal/features/thought/provider/comment.provider.dart';

import 'package:metal/features/thought/widget/reaction_section.dart';

import 'package:metal/gen/assets.gen.dart';

import 'package:metal/route/routes.dart';
import 'package:metal/widgets/build_user_info.dart';

import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/state.handler/loading.state.dart';

import 'package:metal/widgets/text_views.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:metal/res/colors/cr_colors.dart';

class ThoughtDetailsPage extends ConsumerStatefulWidget {
  const ThoughtDetailsPage({super.key});
  static const name = 'thoughtDetails';
  static const route = name;

  @override
  ConsumerState<ThoughtDetailsPage> createState() => _ThoughtDetailsPageState();
}

class _ThoughtDetailsPageState extends ConsumerState<ThoughtDetailsPage> {
  late String thoughtId;
  String? commentId;
  bool shouldOpenComments = false;
  bool _hasOpenedComments = false;
  final PlayerController _waveformController = PlayerController();
  bool _isPlayerPrepared = false;
  String? _localAudioPath;
  bool _isDownloading = false;

  // Global flag to prevent multiple comment sheets
  static bool _isCommentSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _hasOpenedComments = false; // Initialize flag
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Extract the thought ID from the route arguments
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is String) {
      // If args is a direct string, use it as the ID
      thoughtId = args;
      commentId = null;
      shouldOpenComments = false;
    } else if (args is Map<String, dynamic>) {
      // If args is a map, extract the thoughtId and comment info
      thoughtId = args['thoughtId'] as String;
      commentId = args['commentId'] as String?;
      shouldOpenComments = args['openComments'] as bool? ?? false;
    } else if (args is ThoughtModel) {
      // For backward compatibility, if a ThoughtModel is passed directly
      thoughtId = args.id;
      commentId = null;
      shouldOpenComments = false;
    } else {
      // Handle the error case
      throw ArgumentError('ThoughtDetailsPage requires a valid thoughtId');
    }

    // Fetch the thought data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(getThoughtByIdProvider.notifier).getThought(thoughtId);
    });
  }

  @override
  void dispose() {
    _waveformController.dispose();
    // Reset global flag when widget is disposed
    _isCommentSheetOpen = false;
    super.dispose();
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
      _isDownloading = true;
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = DateTime.timestamp().microsecondsSinceEpoch;
      final filePath = '${tempDir.path}/$fileName.m4a';
      final file = File(filePath);

      if (await file.exists()) {
        debugPrint("File already cached: $filePath");
        _localAudioPath = file.path;
      } else {
        debugPrint("Downloading file: $url");
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          _localAudioPath = file.path;
        } else {
          throw Exception("Failed to download file");
        }
      }
    } catch (e) {
      debugPrint("Error downloading file: $e");
      _localAudioPath = null;
    } finally {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
      });
    }
  }

  Future<void> _autoPrepareAudio(ThoughtModel thoughtModel) async {
    final audioUrl = thoughtModel.audioUrl!;

    try {
      // Download file first if it's a URL
      if (_isUrl(audioUrl)) {
        await _downloadFile(audioUrl);
        if (_localAudioPath == null) {
          print('Failed to download audio file');
          return;
        }
      } else {
        _localAudioPath = audioUrl;
      }

      // Prepare player with LOCAL file path
      await _waveformController.preparePlayer(
        path: _localAudioPath!,
        shouldExtractWaveform: true,
      );

      if (mounted) {
        setState(() {
          _isPlayerPrepared = true;
        });
      }
    } catch (e) {
      print('Error auto-preparing audio: $e');
    }
  }

  /// Open comment sheet with optional scroll to specific comment
  void _openCommentSheet(ThoughtModel thought, String? targetCommentId) {
    // Check if a comment sheet is already open
    if (_isCommentSheetOpen) {
      print('Comment sheet already open, skipping');
      return;
    }

    print('Opening comment sheet with target: $targetCommentId');
    _isCommentSheetOpen = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentBottomSheet(
        thought: thought,
        targetCommentId: targetCommentId,
      ),
    ).then((_) {
      // Reset flag when sheet is closed
      _isCommentSheetOpen = false;
      print('Comment sheet closed');
    });
  }

  @override
  Widget build(BuildContext context) {
    final thoughtState = ref.watch(getThoughtByIdProvider);
    final userdata = ref.watch(userStateProvider).data;

    return BaseScreen(
      bgImage: Assets.images.bg2.path,
      appBarEnabled: true,
      Header: "Thought Details",
      authFlow: false,
      body: Builder(
        builder: (context) {
          if (thoughtState.isLoading) {
            return const LoadingState();
          } else if (thoughtState.isError) {
            return ErrorState(
              retry: () {
                ref.read(getThoughtByIdProvider.notifier).getThought(thoughtId);
              },
              text:
                  thoughtState.errorMessage ?? "Failed to load thought details",
            );
          } else if (thoughtState.data == null) {
            return Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 64,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'This thought has been deleted',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The author removed this content',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          // We have the thought data, display it
          final thoughtModel = thoughtState.data!;
          final commentsState = ref.watch(commentProvider(thoughtModel.id));
          final commentCount = commentsState.data?.length ?? 0;

          // Auto-prepare audio for voice thoughts
          if (thoughtModel.type == 'voice' &&
              thoughtModel.audioUrl != null &&
              !_isPlayerPrepared) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _autoPrepareAudio(thoughtModel);
            });
          }

          // Auto-open comments if coming from a comment notification
          if (shouldOpenComments && !_hasOpenedComments) {
            print(
                'Opening comment sheet for thought: $thoughtId, comment: $commentId');
            _hasOpenedComments =
                true; // Mark as opened to prevent multiple opens

            // Use a delayed callback to ensure the UI is stable
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                _openCommentSheet(thoughtModel, commentId);
              }
            });
          }

          return Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BuildUserInfo(
                        userId: thoughtModel.userId,
                        thought: thoughtModel,
                      ),
                      const Gap(20),
                      if (thoughtModel.type == 'voice') ...[
                        _buildVoicePlayer(thoughtModel),
                        if (thoughtModel.content.isNotEmpty) ...[
                          const Gap(8),
                          TextView(
                            text: thoughtModel.content,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ] else ...[
                        TextView(
                          text: thoughtModel.content,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (thoughtModel.userId != userdata?.id) {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.myMeltedUser,
                                  arguments: {"metalId": thoughtModel.userId},
                                );
                              }
                            },
                            icon: SvgPicture.asset(
                              Assets.icons.thoughtProfile.path,
                              height: 24,
                              width: 24,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: SvgPicture.asset(
                                  Assets.icons.thoughComment.path,
                                  height: 24,
                                  width: 24,
                                ),
                                onPressed: () {
                                  _openCommentSheet(thoughtModel, null);
                                },
                              ),
                              TextView(
                                text: commentCount.toString(),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                          Expanded(
                            child: ReactionSection(
                              thoughtId: thoughtModel.id,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVoicePlayer(ThoughtModel thoughtModel) {
    final audioUrl = thoughtModel.audioUrl;
    if (audioUrl == null || audioUrl.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: TextView(
            text: 'Audio not available',
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Play/Pause button using audio_waveforms for real audio analysis
          StreamBuilder<PlayerState>(
            stream: _waveformController.onPlayerStateChanged,
            builder: (context, stateSnap) {
              final isPlaying = stateSnap.data == PlayerState.playing;
              return GestureDetector(
                onTap: () async {
                  if (isPlaying) {
                    await _waveformController.pausePlayer();
                  } else {
                    try {
                      await _waveformController.startPlayer();
                    } catch (e) {
                      print('Error playing audio: $e');
                    }
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.metalPinkColour,
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
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              );
            },
          ),
          const Gap(12),
          // Waveform and duration
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Waveform using both packages
                SizedBox(
                  height: 30,
                  child: _isDownloading
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.metalPinkColour,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Loading audio...',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.metalPinkColour,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Stack(
                          children: [
                            // Background waveform from audio_waveforms
                            Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                width: double.infinity,
                                height: 30,
                                child: AudioFileWaveforms(
                                  size: const Size(double.infinity, 30),
                                  playerController: _waveformController,
                                  waveformType: WaveformType.fitWidth,
                                  playerWaveStyle: const PlayerWaveStyle(
                                    fixedWaveColor:
                                        Color.fromARGB(255, 238, 186, 186),
                                    liveWaveColor: AppColors.metalPinkColour,
                                    showSeekLine: false,
                                    showTop: true,
                                    showBottom: true,
                                    scaleFactor: 100,
                                    spacing: 5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                const Gap(4),
                // Duration text
                _isPlayerPrepared
                    ? FutureBuilder<int>(
                        future: _waveformController.getDuration(),
                        builder: (context, durationSnap) {
                          final durationMs = durationSnap.data ?? 0;
                          final totalDuration =
                              Duration(milliseconds: durationMs);
                          final isPlaying =
                              _waveformController.playerState.isPlaying;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextView(
                                text:
                                    _formatDurationFromDuration(totalDuration),
                                fontSize: 11,
                                color: isPlaying
                                    ? AppColors.metalPinkColour
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                              // Play indicator
                              if (isPlaying)
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: AppColors.metalPinkColour,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDurationFromDuration(Duration duration) {
    if (duration.inSeconds == 0) return '0:00';

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '0:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
