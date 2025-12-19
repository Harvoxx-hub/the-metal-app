import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/community/community_repository.dart';
import 'package:metal/domain/entities/community_dto.dart';

class CommunityState {
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final List<CommunityDto> communities;
  final bool hasMore;
  final int currentPage;

  const CommunityState({
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
    this.communities = const [],
    this.hasMore = true,
    this.currentPage = 1,
  });

  factory CommunityState.initial() => const CommunityState();

  CommunityState copyWith({
    bool? isLoading,
    bool? isError,
    String? errorMessage,
    List<CommunityDto>? communities,
    bool? hasMore,
    int? currentPage,
  }) {
    return CommunityState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      communities: communities ?? this.communities,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class CommunityViewModel extends StateNotifier<CommunityState> {
  final CommunityRepository _repository;

  CommunityViewModel({required CommunityRepository repository})
      : _repository = repository,
        super(CommunityState.initial());

  Future<void> loadCommunities({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = CommunityState.initial().copyWith(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    final result = await _repository.getCommunities(
      page: refresh ? 1 : state.currentPage,
    );

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        state = state.copyWith(
          isLoading: false,
          communities: result.data!,
          hasMore: result.data!.length >= 20,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isError: true,
          errorMessage: result.errorMessage ?? 'Failed to load communities',
        );
      }
    }
  }

  Future<void> joinCommunity(String communityId) async {
    final result = await _repository.joinCommunity(communityId);

    if (mounted && result.isSuccess) {
      final updatedCommunities = state.communities.map((c) {
        if (c.id == communityId) {
          return c.copyWith(isJoined: true, memberCount: c.memberCount + 1);
        }
        return c;
      }).toList();

      state = state.copyWith(communities: updatedCommunities);
    }
  }

  Future<void> leaveCommunity(String communityId) async {
    final result = await _repository.leaveCommunity(communityId);

    if (mounted && result.isSuccess) {
      final updatedCommunities = state.communities.map((c) {
        if (c.id == communityId) {
          return c.copyWith(isJoined: false, memberCount: c.memberCount - 1);
        }
        return c;
      }).toList();

      state = state.copyWith(communities: updatedCommunities);
    }
  }
}
