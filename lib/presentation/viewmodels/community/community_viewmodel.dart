import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/community/community_repository.dart';
import 'package:metal/domain/entities/community_dto.dart';

class CommunityState {
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final List<CommunityDto> communities;
  final List<CommunityDto> filteredCommunities;
  final String searchQuery;
  final bool hasMore;
  final int currentPage;

  const CommunityState({
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
    this.communities = const [],
    this.filteredCommunities = const [],
    this.searchQuery = '',
    this.hasMore = true,
    this.currentPage = 1,
  });

  factory CommunityState.initial() => const CommunityState();

  CommunityState copyWith({
    bool? isLoading,
    bool? isError,
    String? errorMessage,
    List<CommunityDto>? communities,
    List<CommunityDto>? filteredCommunities,
    String? searchQuery,
    bool? hasMore,
    int? currentPage,
  }) {
    return CommunityState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      communities: communities ?? this.communities,
      filteredCommunities: filteredCommunities ?? this.filteredCommunities,
      searchQuery: searchQuery ?? this.searchQuery,
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

  Future<void> loadCommunities({bool refresh = false, String? search}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = CommunityState.initial().copyWith(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    final searchQuery = search ?? state.searchQuery;
    final result = await _repository.getCommunities(
      page: refresh ? 1 : state.currentPage,
      search: searchQuery.isNotEmpty ? searchQuery : null,
    );

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        state = state.copyWith(
          isLoading: false,
          communities: result.data!,
          filteredCommunities: result.data!,
          searchQuery: searchQuery,
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

  /// Search/filter communities
  void search(String query) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      // Clear search - show all communities
      state = state.copyWith(
        searchQuery: '',
        filteredCommunities: state.communities,
      );
    } else {
      // Filter communities locally (or trigger API search)
      final filtered = _filterCommunities(state.communities, normalizedQuery);

      state = state.copyWith(
        searchQuery: normalizedQuery,
        filteredCommunities: filtered,
      );
    }
  }

  /// Filter communities by query
  List<CommunityDto> _filterCommunities(
    List<CommunityDto> communities,
    String query,
  ) {
    return communities.where((community) {
      final name = (community.name).toLowerCase();
      final description = (community.description).toLowerCase();
      final category = (community.category ?? '').toLowerCase();
      return name.contains(query) ||
          description.contains(query) ||
          category.contains(query);
    }).toList();
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

      final updatedFiltered = state.filteredCommunities.map((c) {
        if (c.id == communityId) {
          return c.copyWith(isJoined: true, memberCount: c.memberCount + 1);
        }
        return c;
      }).toList();

      state = state.copyWith(
        communities: updatedCommunities,
        filteredCommunities: updatedFiltered,
      );
    }
  }

  Future<void> leaveCommunity(String communityId) async {
    final result = await _repository.leaveCommunity(communityId);

    if (mounted && result.isSuccess) {
      final responseData = result.data;
      final wasDeleted = responseData?['deleted'] == true;

      if (wasDeleted) {
        // Community was deleted - remove it from the list
        final updatedCommunities = state.communities
            .where((c) => c.id != communityId)
            .toList();

        final updatedFiltered = state.filteredCommunities
            .where((c) => c.id != communityId)
            .toList();

        state = state.copyWith(
          communities: updatedCommunities,
          filteredCommunities: updatedFiltered,
        );
      } else {
        // Regular leave - just update the community status
        final updatedCommunities = state.communities.map((c) {
          if (c.id == communityId) {
            return c.copyWith(isJoined: false, memberCount: c.memberCount - 1);
          }
          return c;
        }).toList();

        final updatedFiltered = state.filteredCommunities.map((c) {
          if (c.id == communityId) {
            return c.copyWith(isJoined: false, memberCount: c.memberCount - 1);
          }
          return c;
        }).toList();

        state = state.copyWith(
          communities: updatedCommunities,
          filteredCommunities: updatedFiltered,
        );
      }
    }
  }

  Future<bool> createCommunity(CreateCommunityDto request) async {
    if (state.isLoading) return false;
    
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
    
    final result = await _repository.createCommunity(request);

    if (mounted) {
      if (result.isSuccess) {
        // Reload communities to include the newly created one
        await loadCommunities(refresh: true);
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          isError: true,
          errorMessage: result.errorMessage ?? 'Failed to create community',
        );
        return false;
      }
    }
    return false;
  }
}
