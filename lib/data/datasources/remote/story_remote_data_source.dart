import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/network/dio_client.dart';
import 'package:metal/data/models/story_model.dart';

/// Remote data source for story (Eyes) operations
/// Handles all API calls related to stories/eyes feature
class StoryRemoteDataSource {
  final DioClient _client;

  StoryRemoteDataSource(this._client);

  /// Get stories feed
  /// Optional userId parameter to get stories from specific user
  Future<StoriesFeedModel> getStories({String? userId}) async {
    final queryParams = <String, dynamic>{};
    if (userId != null) {
      queryParams['userId'] = userId;
    }

    final response = await _client.get(
      ApiRoutes.buildPath(ApiRoutes.stories),
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return StoriesFeedModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to get stories');
  }

  /// Create a new story
  /// Requires mediaUrl from media upload service
  Future<CreateStoryResponseModel> createStory({
    required String mediaUrl,
    required String mediaType,
    int? duration,
    String? caption,
  }) async {
    final requestData = CreateStoryRequestModel(
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      duration: duration,
      caption: caption,
    );

    final response = await _client.post(
      ApiRoutes.buildPath(ApiRoutes.stories),
      data: requestData.toJson(),
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return CreateStoryResponseModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to create story');
  }

  /// Mark a story as viewed
  Future<void> markStoryAsViewed(String storyId) async {
    final response = await _client.post(
      '${ApiRoutes.buildPath(ApiRoutes.storyView)}/$storyId/view',
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to mark story as viewed');
    }
  }

  /// Delete a story
  Future<void> deleteStory(String storyId) async {
    final response = await _client.delete(
      '${ApiRoutes.buildPath(ApiRoutes.storyById)}/$storyId',
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to delete story');
    }
  }
}
