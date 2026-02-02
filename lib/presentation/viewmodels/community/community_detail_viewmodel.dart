import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/community/community_repository.dart';
import 'package:metal/domain/entities/community_dto.dart';
import 'package:metal/domain/entities/thought_dto.dart';

class CommunityDetailState {
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final CommunityDto? community;
  final List<ThoughtDto> posts;
  final List<CommunityMemberDto> members;
  final bool isLoadingMembers;
  final bool isJoining;
  final bool isLeaving;

  const CommunityDetailState({
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
    this.community,
    this.posts = const [],
    this.members = const [],
    this.isLoadingMembers = false,
    this.isJoining = false,
    this.isLeaving = false,
  });

  factory CommunityDetailState.initial() => const CommunityDetailState();

  CommunityDetailState copyWith({
    bool? isLoading,
    bool? isError,
    String? errorMessage,
    CommunityDto? community,
    List<ThoughtDto>? posts,
    List<CommunityMemberDto>? members,
    bool? isLoadingMembers,
    bool? isJoining,
    bool? isLeaving,
  }) {
    return CommunityDetailState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      community: community ?? this.community,
      posts: posts ?? this.posts,
      members: members ?? this.members,
      isLoadingMembers: isLoadingMembers ?? this.isLoadingMembers,
      isJoining: isJoining ?? this.isJoining,
      isLeaving: isLeaving ?? this.isLeaving,
    );
  }
}

class CommunityDetailViewModel extends StateNotifier<CommunityDetailState> {
  final CommunityRepository _repository;

  CommunityDetailViewModel({required CommunityRepository repository})
      : _repository = repository,
        super(CommunityDetailState.initial());

  Future<void> loadCommunityDetails(String communityId) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, isError: false);

    final result = await _repository.getCommunityDetails(communityId);

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        final updatedCommunity = result.data!.community;
        state = state.copyWith(
          isLoading: false,
          community: updatedCommunity,
          posts: result.data!.recentPosts,
        );
        // Load members for everyone (members and non-members can see the list)
        await loadCommunityMembers(communityId);
      } else {
        state = state.copyWith(
          isLoading: false,
          isError: true,
          errorMessage:
              result.errorMessage ?? 'Failed to load community details',
        );
      }
    }
  }

  Future<void> joinCommunity(String communityId) async {
    if (state.isJoining) return;

    state = state.copyWith(isJoining: true);

    final result = await _repository.joinCommunity(communityId);

    if (mounted) {
      if (result.isSuccess) {
        // Optimistically update local state
        final updatedCommunity = state.community?.copyWith(
          isJoined: true,
          memberCount: (state.community?.memberCount ?? 0) + 1,
        );
        state = state.copyWith(
          isJoining: false,
          community: updatedCommunity,
        );

        // Reload from backend to get fresh state (including correct isJoined status)
        await loadCommunityDetails(communityId);
      } else {
        state = state.copyWith(
          isJoining: false,
          isError: true,
          errorMessage: result.errorMessage ?? 'Failed to join community',
        );
      }
    }
  }

  Future<Map<String, dynamic>?> leaveCommunity(String communityId) async {
    if (state.isLeaving) return null;

    state = state.copyWith(isLeaving: true);

    final result = await _repository.leaveCommunity(communityId);

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        final responseData = result.data!;
        final wasDeleted = responseData['deleted'] == true;

        if (wasDeleted) {
          // Community was deleted - return the response data
          state = state.copyWith(isLeaving: false);
          return responseData;
        } else {
          // Regular leave - update local state
          final updatedCommunity = state.community?.copyWith(
            isJoined: false,
            memberCount: (state.community?.memberCount ?? 0) - 1,
          );
          state = state.copyWith(
            isLeaving: false,
            community: updatedCommunity,
          );

          // Reload from backend to get fresh state
          await loadCommunityDetails(communityId);
          return responseData;
        }
      } else {
        state = state.copyWith(
          isLeaving: false,
          isError: true,
          errorMessage: result.errorMessage ?? 'Failed to leave community',
        );
        return null;
      }
    }
    return null;
  }

  /// Load all community members (no pagination).
  Future<void> loadCommunityMembers(String communityId, {String? role}) async {
    if (state.isLoadingMembers) return;

    state = state.copyWith(isLoadingMembers: true);

    final result = await _repository.getCommunityMembers(
      communityId,
      role: role,
    );

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        state = state.copyWith(
          isLoadingMembers: false,
          members: result.data!,
        );
      } else {
        final isForbiddenError =
            result.errorMessage?.contains('must be a member') == true ||
                result.errorMessage?.contains('403') == true;

        if (!isForbiddenError) {
          state = state.copyWith(
            isLoadingMembers: false,
            isError: true,
            errorMessage:
                result.errorMessage ?? 'Failed to load community members',
          );
        } else {
          state = state.copyWith(
            isLoadingMembers: false,
            members: [],
          );
        }
      }
    }
  }

  /// Refresh all data for the community details page
  Future<void> refreshAll(String communityId) async {
    await loadCommunityDetails(communityId);
    await loadCommunityMembers(communityId);
  }

  /// Add a new post to the list (optimistic update)
  void addPost(ThoughtDto post) {
    if (mounted) {
      final updatedPosts = [post, ...state.posts];
      state = state.copyWith(posts: updatedPosts);
    }
  }
}
