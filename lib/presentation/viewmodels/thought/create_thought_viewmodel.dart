import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:metal/core/di/provider_setup.dart';
import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/network/dio_client.dart';
import 'package:metal/data/repositories/thought/thought_repository_abstract.dart';
import 'package:metal/presentation/viewmodels/thought/thought_providers.dart';
import 'dart:io';

/// Create Thought State
class CreateThoughtState {
  final String text;
  final String? audioUrl;
  final int? audioDuration;
  final String? localAudioPath;
  final bool isUploadingAudio;
  final bool isPosting;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;

  const CreateThoughtState({
    this.text = '',
    this.audioUrl,
    this.audioDuration,
    this.localAudioPath,
    this.isUploadingAudio = false,
    this.isPosting = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
  });

  /// Check if thought can be posted
  bool get canPost {
    final hasText = text.trim().isNotEmpty;
    final hasAudio = audioUrl != null && audioUrl!.isNotEmpty;
    return (hasText || hasAudio) && !isPosting && !isUploadingAudio;
  }

  CreateThoughtState copyWith({
    String? text,
    String? audioUrl,
    int? audioDuration,
    String? localAudioPath,
    bool? isUploadingAudio,
    bool? isPosting,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
  }) {
    return CreateThoughtState(
      text: text ?? this.text,
      audioUrl: audioUrl ?? this.audioUrl,
      audioDuration: audioDuration ?? this.audioDuration,
      localAudioPath: localAudioPath ?? this.localAudioPath,
      isUploadingAudio: isUploadingAudio ?? this.isUploadingAudio,
      isPosting: isPosting ?? this.isPosting,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Create Thought ViewModel
class CreateThoughtViewModel extends StateNotifier<CreateThoughtState> {
  final ThoughtRepositoryAbstract _repository;
  final DioClient _dioClient;

  CreateThoughtViewModel({
    required ThoughtRepositoryAbstract repository,
    required DioClient dioClient,
  })  : _repository = repository,
        _dioClient = dioClient,
        super(const CreateThoughtState());

  void updateText(String text) {
    if (text.length > 1000) return; // Enforce max length
    state = state.copyWith(text: text, isError: false, errorMessage: null);
  }

  void updateAudio(String localPath, int duration) {
    state = state.copyWith(
      localAudioPath: localPath,
      audioDuration: duration,
      isError: false,
      errorMessage: null,
    );
  }

  void clearAudio() {
    state = state.copyWith(
      audioUrl: null,
      audioDuration: null,
      localAudioPath: null,
    );
  }

  /// Upload audio file to Firebase Storage
  Future<String?> _uploadAudio(String filePath) async {
    try {
      final file = File(filePath);
      final fileSize = await file.length();

      // Get upload URL from backend
      final uploadUrlResponse = await _dioClient.post(
        ApiRoutes.buildPath(ApiRoutes.mediaUpload),
        data: {
          'mediaType': 'audio',
          'purpose': 'thought',
          'contentType': 'audio/aac',
          'fileSize': fileSize,
        },
      );

      if (uploadUrlResponse.statusCode == 200) {
        final responseData = uploadUrlResponse.data['data'] ?? uploadUrlResponse.data;
        final uploadUrl = responseData['uploadUrl'] as String;
        final downloadUrl = responseData['downloadUrl'] as String;
        final makePublic = responseData['makePublic'] as bool? ?? false;
        final backendFilePath = responseData['filePath'] as String?;

        // Upload file
        final fileBytes = await file.readAsBytes();
        final uploadResponse = await Dio().put(
          uploadUrl,
          data: fileBytes,
          options: Options(headers: {'Content-Type': 'audio/aac'}),
        );

        if (uploadResponse.statusCode == 200) {
          // Make file public if needed
          if (makePublic && backendFilePath != null && backendFilePath.isNotEmpty) {
            try {
              await _dioClient.post(
                ApiRoutes.buildPath(ApiRoutes.mediaMakePublic),
                data: {'filePath': backendFilePath},
              );
            } catch (e) {
              print('Warning: Failed to make file public: $e');
              // Continue anyway - signed URL will work
            }
          }
          return downloadUrl;
        }
      }
      return null;
    } catch (e) {
      print('Error uploading audio: $e');
      return null;
    }
  }

  /// Post the thought
  Future<bool> postThought() async {
    if (!state.canPost) return false;

    state = state.copyWith(isPosting: true, isError: false, errorMessage: null);

    try {
      String? uploadedAudioUrl;
      int? uploadedAudioDuration;

      // Upload audio if exists
      if (state.localAudioPath != null && state.localAudioPath!.isNotEmpty) {
        state = state.copyWith(isUploadingAudio: true);
        uploadedAudioUrl = await _uploadAudio(state.localAudioPath!);
        uploadedAudioDuration = state.audioDuration;

        if (uploadedAudioUrl == null) {
          state = state.copyWith(
            isPosting: false,
            isUploadingAudio: false,
            isError: true,
            errorMessage: 'Failed to upload audio. Please try again.',
          );
          return false;
        }

        state = state.copyWith(
          isUploadingAudio: false,
          audioUrl: uploadedAudioUrl,
        );
      }

      // Determine type
      final hasText = state.text.trim().isNotEmpty;
      final type = hasText ? 'text' : 'voice';

      // Create thought
      final result = await _repository.createThought(
        content: state.text.trim().isEmpty ? null : state.text.trim(),
        type: type,
        audioUrl: uploadedAudioUrl,
        audioDuration: uploadedAudioDuration,
        connectionOnly: false,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          isPosting: false,
          isSuccess: true,
        );
        return true;
      } else {
        state = state.copyWith(
          isPosting: false,
          isError: true,
          errorMessage: result.errorMessage ?? 'Failed to post thought',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isPosting: false,
        isUploadingAudio: false,
        isError: true,
        errorMessage: 'Error: $e',
      );
      return false;
    }
  }
}

/// Provider for Create Thought ViewModel
final createThoughtViewModelProvider =
    StateNotifierProvider<CreateThoughtViewModel, CreateThoughtState>((ref) {
  final repository = ref.watch(thoughtRepositoryProvider);
  final dioClient = ref.watch(dioClientProvider);
  return CreateThoughtViewModel(repository: repository, dioClient: dioClient);
});

