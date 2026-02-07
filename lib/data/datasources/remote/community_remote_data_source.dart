import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/network/dio_client.dart';
import 'package:metal/data/models/community_model.dart';

/// Remote data source for community operations
class CommunityRemoteDataSource {
  final DioClient _client;

  CommunityRemoteDataSource(this._client);

  /// Get communities list with filters.
  /// Backend returns all communities (no limit).
  Future<CommunitiesListModel> getCommunities({
    String? type,
    String? category,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final response = await _client.get(
      ApiRoutes.buildPath(ApiRoutes.communities),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data != null) {
      final data =
          response.data['data'] as Map<String, dynamic>? ?? response.data;
      return CommunitiesListModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to get communities');
  }

  /// Get single community by ID with details (includes recent posts)
  Future<CommunityDetailsModel> getCommunityById(String id) async {
    final response = await _client.get(
      '${ApiRoutes.buildPath(ApiRoutes.communityById)}/$id',
    );

    if (response.statusCode == 200 && response.data != null) {
      final data =
          response.data['data'] as Map<String, dynamic>? ?? response.data;
      return CommunityDetailsModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to get community');
  }

  /// Create a new community
  Future<CommunityModel> createCommunity(
      CreateCommunityRequestModel request) async {
    final response = await _client.post(
      ApiRoutes.buildPath(ApiRoutes.communities),
      data: request.toJson(),
    );

    // Accept both 200 and 201 status codes (201 Created is standard for POST)
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.data != null) {
      final data =
          response.data['data'] as Map<String, dynamic>? ?? response.data;
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
  /// Returns a map with 'deleted' or 'left' flag to indicate if community was deleted
  Future<Map<String, dynamic>> leaveCommunity(String communityId) async {
    final response = await _client.delete(
      '${ApiRoutes.buildPath(ApiRoutes.communityLeave)}/$communityId/leave',
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to leave community');
    }

    // Return the response data which includes 'deleted' or 'left' flag
    final data =
        response.data['data'] as Map<String, dynamic>? ?? response.data;
    return data as Map<String, dynamic>;
  }

  /// Get community members (all members, no pagination)
  Future<CommunityMembersListModel> getCommunityMembers(
    String communityId, {
    String? role,
  }) async {
    final queryParams = <String, dynamic>{
      if (role != null && role.isNotEmpty) 'role': role,
    };

    final response = await _client.get(
      '${ApiRoutes.buildPath(ApiRoutes.communityMembers)}/$communityId/members',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.statusCode == 200 && response.data != null) {
      final data =
          response.data['data'] as Map<String, dynamic>? ?? response.data;
      return CommunityMembersListModel.fromJson(data);
    }

    throw Exception(
        response.data?['error'] ?? 'Failed to get community members');
  }
}
