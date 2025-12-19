import 'dart:io';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/error_handling/error_handler.dart';
import 'package:metal/data/datasources/remote/story_remote_data_source.dart';
import 'package:metal/data/datasources/remote/media_remote_data_source.dart';
import 'package:metal/data/repositories/story/story_repository_abstract.dart';
import 'package:metal/domain/entities/story_dto.dart';

class StoryRepository implements StoryRepositoryAbstract {
  final StoryRemoteDataSource _storyRemoteDataSource;
  final MediaRemoteDataSource _mediaRemoteDataSource;

  StoryRepository({
    required StoryRemoteDataSource storyRemoteDataSource,
    required MediaRemoteDataSource mediaRemoteDataSource,
  })  : _storyRemoteDataSource = storyRemoteDataSource,
        _mediaRemoteDataSource = mediaRemoteDataSource;

  @override
  Future<BaseState<List<StoryGroupDto>>> getStories({String? userId}) async {
    try {
      final response = await _storyRemoteDataSource.getStories(userId: userId);
      final storyGroups = response.toGroupedDomain();
      return BaseState.success(storyGroups);
    } catch (e) {
      return ErrorHandler.handleError<List<StoryGroupDto>>(e);
    }
  }

  @override
  Future<BaseState<StoryDto>> createStory({
    required File file,
    required String mediaType,
    required String contentType,
    int? duration,
    String? caption,
  }) async {
    try {
      // Step 1: Upload media file and get public URL
      final publicUrl = await _mediaRemoteDataSource.uploadMedia(
        file: file,
        mediaType: _parseMediaType(mediaType),
        purpose: MediaPurpose.story,
        contentType: contentType,
      );

      // Step 2: Create story with the public URL
      final response = await _storyRemoteDataSource.createStory(
        mediaUrl: publicUrl,
        mediaType: mediaType,
        duration: duration,
        caption: caption,
      );

      final story = response.story.toDomain();
      return BaseState.success(story);
    } catch (e) {
      return ErrorHandler.handleError<StoryDto>(e);
    }
  }

  @override
  Future<BaseState<void>> markStoryAsViewed(String storyId) async {
    try {
      await _storyRemoteDataSource.markStoryAsViewed(storyId);
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  @override
  Future<BaseState<void>> deleteStory(String storyId) async {
    try {
      await _storyRemoteDataSource.deleteStory(storyId);
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  MediaType _parseMediaType(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return MediaType.image;
      case 'video':
        return MediaType.video;
      default:
        return MediaType.image;
    }
  }
}
