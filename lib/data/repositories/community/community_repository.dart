import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/error_handling/error_handler.dart';
import 'package:metal/data/datasources/remote/community_remote_data_source.dart';
import 'package:metal/data/models/community_model.dart';
import 'package:metal/data/repositories/community/community_repository_abstract.dart';
import 'package:metal/domain/entities/community_dto.dart';

class CommunityRepository implements CommunityRepositoryAbstract {
  final CommunityRemoteDataSource _remoteDataSource;

  CommunityRepository({required CommunityRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<BaseState<List<CommunityDto>>> getCommunities({
    String? type,
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _remoteDataSource.getCommunities(
        type: type,
        category: category,
        search: search,
        page: page,
        limit: limit,
      );
      final communities = response.toDomain();
      return BaseState.success(communities);
    } catch (e) {
      return ErrorHandler.handleError<List<CommunityDto>>(e);
    }
  }

  @override
  Future<BaseState<CommunityDto>> getCommunityById(String id) async {
    try {
      final response = await _remoteDataSource.getCommunityById(id);
      final community = response.community.toDomain();
      return BaseState.success(community);
    } catch (e) {
      return ErrorHandler.handleError<CommunityDto>(e);
    }
  }

  @override
  Future<BaseState<CommunityDetailsDto>> getCommunityDetails(String id) async {
    try {
      final response = await _remoteDataSource.getCommunityById(id);
      final details = response.toDomain();
      return BaseState.success(details);
    } catch (e) {
      return ErrorHandler.handleError<CommunityDetailsDto>(e);
    }
  }

  @override
  Future<BaseState<List<CommunityMemberDto>>> getCommunityMembers(
    String communityId, {
    int page = 1,
    int limit = 50,
    String? role,
  }) async {
    try {
      final response = await _remoteDataSource.getCommunityMembers(
        communityId,
        page: page,
        limit: limit,
        role: role,
      );
      final members = response.toDomain(communityId);
      return BaseState.success(members);
    } catch (e) {
      return ErrorHandler.handleError<List<CommunityMemberDto>>(e);
    }
  }

  @override
  Future<BaseState<CommunityDto>> createCommunity(CreateCommunityDto request) async {
    try {
      final requestModel = CreateCommunityRequestModel.fromDto(request);
      final response = await _remoteDataSource.createCommunity(requestModel);
      final community = response.toDomain();
      return BaseState.success(community);
    } catch (e) {
      return ErrorHandler.handleError<CommunityDto>(e);
    }
  }

  @override
  Future<BaseState<void>> joinCommunity(String communityId) async {
    try {
      await _remoteDataSource.joinCommunity(communityId);
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  @override
  Future<BaseState<Map<String, dynamic>?>> leaveCommunity(String communityId) async {
    try {
      final result = await _remoteDataSource.leaveCommunity(communityId);
      // Return the result map so viewmodel can check if community was deleted
      return BaseState.success(result);
    } catch (e) {
      return ErrorHandler.handleError<Map<String, dynamic>?>(e);
    }
  }
}
