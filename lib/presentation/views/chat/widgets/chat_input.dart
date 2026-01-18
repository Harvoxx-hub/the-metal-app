import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:dio/dio.dart';
import 'package:metal/core/di/provider_setup.dart';
import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/utils/permission_helper.dart';
import 'package:metal/domain/entities/message_dto.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/chat/chat_viewmodel_providers.dart';
import 'package:metal/presentation/views/chat/widgets/voice_recording_widget.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

/// Chat input widget for sending messages
class ChatInput extends ConsumerStatefulWidget {
  final String connectionId;
  final bool canSend;
  final ChatConnectionDto connection;
  final VoidCallback? onMessageSent;

  const ChatInput({
    super.key,
    required this.connectionId,
    required this.canSend,
    required this.connection,
    this.onMessageSent,
  });

  @override
  ConsumerState<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends ConsumerState<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;
  bool _isRecording = false;
  bool _isUploadingAudio = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTextChanged(String text) {
    setState(() {
      _isComposing = text.trim().isNotEmpty;
    });
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() {
      _isComposing = false;
    });

    final success = await ref
        .read(chatWindowViewModelProvider(widget.connectionId).notifier)
        .sendTextMessage(text);

    if (success && widget.onMessageSent != null) {
      widget.onMessageSent!();
    }
  }

  void _clearReply() {
    ref
        .read(chatWindowViewModelProvider(widget.connectionId).notifier)
        .clearReply();
  }

  Future<void> _startRecording() async {
    // Request permission with proper dialog flow
    // This will check status first and only show dialogs if needed
    final hasPermission =
        await PermissionHelper.requestMicrophonePermission(context);

    if (!hasPermission) {
      // Permission was denied or user cancelled - no need to show snackbar
      // as the dialog flow already handles the explanation
      return;
    }

    // Only set recording state if permission is granted
    if (mounted) {
      setState(() {
        _isRecording = true;
      });
    }
  }

  void _cancelRecording() {
    if (mounted) {
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> _handleRecordingComplete(String audioPath) async {
    setState(() {
      _isRecording = false;
      _isUploadingAudio = true;
    });

    try {
      // Upload audio file to backend
      final audioUrl = await _uploadAudio(audioPath);

      if (audioUrl != null) {
        // Send audio message
        final success = await ref
            .read(chatWindowViewModelProvider(widget.connectionId).notifier)
            .sendAudioMessage(audioUrl);

        if (success && widget.onMessageSent != null) {
          widget.onMessageSent!();
        }
      }

      // Delete local file after upload
      final file = File(audioPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error uploading audio: $e');
      if (mounted) {
        Fluttertoast.showToast(msg: 'Failed to send voice message');
      }
    } finally {
      setState(() {
        _isUploadingAudio = false;
      });
    }
  }

  Future<String?> _uploadAudio(String filePath) async {
    try {
      final dioClient = ref.read(dioClientProvider);

      // Get file size for the request
      final file = File(filePath);
      final fileSize = await file.length();

      // Request upload URL from backend
      final uploadUrlResponse = await dioClient.post(
        ApiRoutes.mediaUpload,
        data: {
          'mediaType': 'audio',
          'purpose': 'message',
          'contentType': 'audio/aac',
          'fileSize': fileSize,
        },
      );

      if (uploadUrlResponse.statusCode == 200) {
        final responseData =
            uploadUrlResponse.data['data'] ?? uploadUrlResponse.data;
        final uploadUrl = responseData['uploadUrl'] as String;
        final filePath = responseData['filePath'] as String;
        final makePublic = responseData['makePublic'] as bool? ?? false;
        final publicUrl = responseData['publicUrl'] as String;

        // Upload file to the signed URL
        final fileBytes = await file.readAsBytes();

        final uploadResponse = await Dio().put(
          uploadUrl,
          data: fileBytes,
          options: Options(
            headers: {
              'Content-Type': 'audio/aac',
            },
          ),
        );

        if (uploadResponse.statusCode == 200) {
          // For message files, make them publicly readable so they never expire
          if (makePublic && filePath.isNotEmpty) {
            try {
              await dioClient.post(
                ApiRoutes.mediaMakePublic,
                data: {
                  'filePath': filePath,
                },
              );
              print('File made public: $filePath');
            } catch (e) {
              print('Warning: Failed to make file public: $e');
              // Continue anyway - the signed URL will work for 6 days
            }
          }

          // Return the public URL (or signed URL if makePublic failed)
          return publicUrl;
        }
      }
      return null;
    } catch (e) {
      print('Error uploading audio: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState =
        ref.watch(chatWindowViewModelProvider(widget.connectionId));
    final replyingTo = chatState.replyingTo;

    if (!widget.canSend) {
      return _buildMeltToReplyButton();
    }

    // Show recording widget when recording
    if (_isRecording) {
      return VoiceRecordingWidget(
        onRecordingComplete: _handleRecordingComplete,
        onCancel: _cancelRecording,
      );
    }

    // Show uploading indicator
    if (_isUploadingAudio) {
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
                text: 'Uploading voice message...',
                fontSize: 14,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
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
      child: SafeArea(
        top: false, // Don't add top padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reply preview
            if (replyingTo != null) _buildReplyPreview(replyingTo),
            // Input row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Emoji button
                  GestureDetector(
                    onTap: () {
                      // TODO: Implement emoji picker
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Assets.icons.chatsWindowactiveEmojis.svg(
                        width: 28,
                        height: 28,
                        colorFilter: ColorFilter.mode(
                          Colors.grey[700]!,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const Gap(8),
                  // Text input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onChanged: _handleTextChanged,
                        onSubmitted: (_) => _handleSend(),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 4,
                        minLines: 1,
                        decoration: const InputDecoration(
                          hintText: 'Your message',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(8),
                  // Send button when composing, otherwise game and mic
                  if (_isComposing)
                    GestureDetector(
                      onTap: _handleSend,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.metalPinkColour,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Assets.icons.chatsWindowactiveSend.svg(
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Game button
                        GestureDetector(
                          onTap: () {
                            // TODO: Implement game picker
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Assets.icons.chatsEmptyStateGamingPad01.svg(
                              width: 28,
                              height: 28,
                              colorFilter: ColorFilter.mode(
                                Colors.grey[700]!,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        // Mic button
                        GestureDetector(
                          onTap: _startRecording,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Assets.icons.chatsEmptyStateMicrophone.svg(
                              width: 28,
                              height: 28,
                              colorFilter: ColorFilter.mode(
                                Colors.grey[700]!,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview(MessageDto message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          left: BorderSide(
            color: AppColors.metalPinkColour,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const TextView(
                  text: 'Replying to',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.metalPinkColour,
                ),
                const Gap(2),
                Text(
                  message.isAudio ? '🎵 Voice message' : message.message,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: _clearReply,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildMeltToReplyButton() {
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
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement melt action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.metalPinkColour,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite, size: 20),
                Gap(8),
                Text(
                  'Melt & Reply',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
