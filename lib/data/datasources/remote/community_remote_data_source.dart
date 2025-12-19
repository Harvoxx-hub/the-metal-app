import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/network/dio_client.dart';
import 'package:metal/data/models/community_model.dart';

/// Remote data source for community operations
class CommunityRemoteDataSource {
  final DioClient _client;

  CommunityRemoteDataSource(this._client);

  /// Get communities list with filters
  Future<CommunitiesListModel> getCommunities({
    String? type,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
    };

    final response = await _client.get(
      ApiRoutes.buildPath(ApiRoutes.communities),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return CommunitiesListModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to get communities');
  }

  /// Get single community by ID
  Future<CommunityModel> getCommunityById(String id) async {
    final response = await _client.get(
      '${ApiRoutes.buildPath(ApiRoutes.communityById)}/$id',
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return CommunityModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to get community');
  }

  /// Create a new community
  Future<CommunityModel> createCommunity(CreateCommunityRequestModel request) async {
    final response = await _client.post(
      ApiRoutes.buildPath(ApiRoutes.communities),
      data: request.toJson(),
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return CommunityModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to create community');
  }

  /// Join a community
  Future<void> joinCommunity(String communityId) async {
    final response = await _client.post(
      '${ApiRoutes.buildPath(ApiRoutes.communityJoin)}/$communityId/join',
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to join community');
    }
  }

  /// Leave a community
  Future<void> leaveCommunity(String communityId) async {
    final response = await _client.delete(
      '${ApiRoutes.buildPath(ApiRoutes.communityLeave)}/$communityId/leave',
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to leave community');
    }
  }
}
