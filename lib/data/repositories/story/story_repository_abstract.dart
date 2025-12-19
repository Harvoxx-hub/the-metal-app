import 'dart:io';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/domain/entities/story_dto.dart';

abstract class StoryRepositoryAbstract {
  /// Get stories feed (optionally filtered by userId)
  Future<BaseState<List<StoryGroupDto>>> getStories({String? userId});

  /// Create a new story from a file
  Future<BaseState<StoryDto>> createStory({
    required File file,
    required String mediaType,
    required String contentType,
    int? duration,
    String? caption,
  });

  /// Mark a story as viewed
  Future<BaseState<void>> markStoryAsViewed(String storyId);

  /// Delete a story
  Future<BaseState<void>> deleteStory(String storyId);
}
