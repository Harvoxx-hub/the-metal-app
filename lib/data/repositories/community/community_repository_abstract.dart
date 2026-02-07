import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/models/community_model.dart';
import 'package:metal/domain/entities/community_dto.dart';

abstract class CommunityRepositoryAbstract {
  Future<BaseState<CommunitiesListResult>> getCommunities({
    String? type,
    String? category,
    String? search,
  });

  Future<BaseState<CommunityDto>> getCommunityById(String id);

  Future<BaseState<CommunityDetailsDto>> getCommunityDetails(String id);

  Future<BaseState<List<CommunityMemberDto>>> getCommunityMembers(
    String communityId, {
    String? role,
  });

  Future<BaseState<CommunityDto>> createCommunity(CreateCommunityDto request);

  Future<BaseState<void>> joinCommunity(String communityId);

  /// Leave a community
  /// Returns a Map with 'deleted' or 'left' flag if successful
  Future<BaseState<Map<String, dynamic>?>> leaveCommunity(String communityId);
}
