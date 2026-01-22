import 'package:metal/core/state/base.state.dart';
import 'package:metal/domain/entities/community_dto.dart';

abstract class CommunityRepositoryAbstract {
  Future<BaseState<List<CommunityDto>>> getCommunities({
    String? type,
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  });

  Future<BaseState<CommunityDto>> getCommunityById(String id);

  Future<BaseState<CommunityDetailsDto>> getCommunityDetails(String id);

  Future<BaseState<List<CommunityMemberDto>>> getCommunityMembers(
    String communityId, {
    int page = 1,
    int limit = 50,
    String? role,
  });

  Future<BaseState<CommunityDto>> createCommunity(CreateCommunityDto request);

  Future<BaseState<void>> joinCommunity(String communityId);

  /// Leave a community
  /// Returns a Map with 'deleted' or 'left' flag if successful
  Future<BaseState<Map<String, dynamic>?>> leaveCommunity(String communityId);
}
