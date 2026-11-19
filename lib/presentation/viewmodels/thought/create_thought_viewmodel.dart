import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/datasources/remote/media_remote_data_source_provider.dart';
import 'package:metal/data/datasources/remote/media_remote_data_source.dart';
import 'package:metal/data/repositories/thought/thought_repository_abstract.dart';
import 'package:metal/domain/entities/thought_dto.dart';
import 'package:metal/presentation/viewmodels/thought/thought_providers.dart';

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
  final MediaRemoteDataSource _mediaDataSource;

  CreateThoughtViewModel({
    required ThoughtRepositoryAbstract repository,
    required MediaRemoteDataSource mediaDataSource,
  })  : _repository = repository,
        _mediaDataSource = mediaDataSource,
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

  /// Resets all state to initial. Call when screen is dismissed or after successful post
  /// so the next open is always a fresh start.
  void reset() {
    state = const CreateThoughtState();
  }

  /// Upload audio file using MediaRemoteDataSource (Clean Architecture)
  Future<String?> _uploadAudio(String filePath) async {
    try {
      final file = File(filePath);

      // Use MediaRemoteDataSource to handle upload (follows Clean Architecture)
      final publicUrl = await _mediaDataSource.uploadMedia(
        file: file,
        mediaType: MediaType.audio,
        purpose: MediaPurpose.thought,
        contentType: 'audio/aac',
      );

      return publicUrl;
    } catch (e) {
      print('Error uploading audio: $e');
      return null;
    }
  }

  /// Post the thought.
  /// [communityMetadata] - Optional metadata for posting to a community.
  /// Returns the created [ThoughtDto] on success, or null on failure (so the caller can add it to the community feed immediately).
  Future<ThoughtDto?> postThought(
      {Map<String, dynamic>? communityMetadata}) async {
    if (!state.canPost) return null;

    state = state.copyWith(isPosting: true, isError: false, errorMessage: null);

    try {
      String? uploadedAudioUrl;
      int? uploadedAudioDuration;

      // Upload audio if exists
      if (state.localAudioPath != null && state.localAudioPath!.isNotEmpty) {
        state = state.copyWith(isUploadingAudio: true);
        uploadedAudioUrl = await _uploadAudio(state.localAudioPath!);
        // Backend requires audioDuration 1-120 for voice thoughts; use 1 if missing or 0
        uploadedAudioDuration =
            state.audioDuration != null && state.audioDuration! >= 1
                ? state.audioDuration
                : 1;

        if (uploadedAudioUrl == null) {
          state = state.copyWith(
            isPosting: false,
            isUploadingAudio: false,
            isError: true,
            errorMessage: 'Failed to upload audio. Please try again.',
          );
          return null;
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
        communityMetadata: communityMetadata,
      );

      if (result.isSuccess && result.data != null) {
        state = state.copyWith(
          isPosting: false,
          isSuccess: true,
        );
        return result.data;
      } else {
        state = state.copyWith(
          isPosting: false,
          isError: true,
          errorMessage: result.errorMessage ?? 'Failed to post thought',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isPosting: false,
        isUploadingAudio: false,
        isError: true,
        errorMessage: 'Error: $e',
      );
      return null;
    }
  }

  /// Update an existing thought's content.
  ///
  /// Note: Current backend update endpoint supports content updates only.
  /// (Audio editing is not supported yet in this flow.)
  Future<ThoughtDto?> updateThought({
    required String thoughtId,
    required bool connectionOnly,
  }) async {
    if (!state.canPost) return null;

    state = state.copyWith(isPosting: true, isError: false, errorMessage: null);

    try {
      final result = await _repository.updateThought(
        thoughtId: thoughtId,
        content: state.text.trim(),
        connectionOnly: connectionOnly,
      );

      if (result.isSuccess && result.data != null) {
        state = state.copyWith(isPosting: false, isSuccess: true);
        return result.data;
      }

      state = state.copyWith(
        isPosting: false,
        isError: true,
        errorMessage: result.errorMessage ?? 'Failed to update thought',
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isPosting: false,
        isError: true,
        errorMessage: 'Error: $e',
      );
      return null;
    }
  }
}

/// Provider for Create Thought ViewModel.
/// Auto-disposes when no longer listened to (e.g. screen popped) so reopening is always fresh.
final createThoughtViewModelProvider = StateNotifierProvider.autoDispose<
    CreateThoughtViewModel, CreateThoughtState>((ref) {
  final repository = ref.watch(thoughtRepositoryProvider);
  final mediaDataSource = ref.watch(mediaRemoteDataSourceProvider);
  return CreateThoughtViewModel(
    repository: repository,
    mediaDataSource: mediaDataSource,
  );
});
