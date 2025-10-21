import 'package:metal/core/model/responces.dart';
import 'package:metal/features/community/data/domain/entries/community.model.dart';
import 'package:metal/features/thought/data/domain/entries/thought.model.dart';

abstract class ICommunityRepository {
  /// Create a new community
  Future<Responses> createCommunity(CommunityModel community);

  /// Get all communities
  Future<Responses> getAllCommunities();

  /// Get communities by category/tag
  Future<Responses> getCommunitiesByCategory(String category);

  /// Search communities by name or description
  Future<Responses> searchCommunities(String query);

  /// Get community by ID
  Future<Responses> getCommunityById(String communityId);

  /// Join a community
  Future<Responses> joinCommunity(String communityId, String userId);

  /// Leave a community
  Future<Responses> leaveCommunity(String communityId, String userId);

  /// Get user's joined communities
  Future<Responses> getUserCommunities(String userId);

  /// Get community members
  Future<Responses> getCommunityMembers(String communityId);
  Future<Responses> isUserMemberOfCommunity(String communityId, String userId);

  /// Update community details
  Future<Responses> updateCommunity(CommunityModel community);

  /// Delete community (creator only)
  Future<Responses> deleteCommunity(String communityId, String userId);

  /// Upload community banner image
  Future<Responses> uploadCommunityImage(String filePath, String communityId);

  /// Get thoughts/posts for a specific community
  Future<Responses> getCommunityThoughts(String communityId);
}
