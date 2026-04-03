import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/community/community_repository.dart';
import 'package:metal/domain/entities/community_dto.dart';
import 'package:metal/domain/entities/thought_dto.dart';

/// On success, [data] holds the API payload (`deleted` may be true). On failure, [error] is the message.
typedef LeaveCommunityOutcome = ({
  Map<String, dynamic>? data,
  String? error,
});

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

  /// Returns an error message if join failed; `null` on success.
  Future<String?> joinCommunity(String communityId) async {
    if (state.isJoining) return null;

    state = state.copyWith(isJoining: true);

    final result = await _repository.joinCommunity(communityId);

    if (!mounted) return null;

    if (result.isSuccess) {
      final updatedCommunity = state.community?.copyWith(
        isJoined: true,
        memberCount: (state.community?.memberCount ?? 0) + 1,
      );
      state = state.copyWith(
        isJoining: false,
        community: updatedCommunity,
      );

      await loadCommunityDetails(communityId);
      return null;
    }

    state = state.copyWith(isJoining: false);
    return result.errorMessage ?? 'Failed to join community';
  }

  Future<LeaveCommunityOutcome> leaveCommunity(String communityId) async {
    if (state.isLeaving) return (data: null, error: null);

    state = state.copyWith(isLeaving: true);

    final result = await _repository.leaveCommunity(communityId);

    if (!mounted) return (data: null, error: null);

    if (result.isSuccess && result.data != null) {
      final responseData = result.data!;
      final wasDeleted = responseData['deleted'] == true;

      if (wasDeleted) {
        state = state.copyWith(isLeaving: false);
        return (data: responseData, error: null);
      }

      final updatedCommunity = state.community?.copyWith(
        isJoined: false,
        memberCount: (state.community?.memberCount ?? 0) - 1,
      );
      state = state.copyWith(
        isLeaving: false,
        community: updatedCommunity,
      );

      await loadCommunityDetails(communityId);
      return (data: responseData, error: null);
    }

    state = state.copyWith(isLeaving: false);
    return (
      data: null,
      error: result.errorMessage ?? 'Failed to leave community',
    );
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

  /// Remove a post from the list (optimistic delete). Returns the removed post for rollback on API failure.
  ThoughtDto? removePost(String thoughtId) {
    if (!mounted) return null;
    final index = state.posts.indexWhere((p) => p.id == thoughtId);
    if (index == -1) return null;
    final removed = state.posts[index];
    final updatedPosts = state.posts.where((p) => p.id != thoughtId).toList();
    state = state.copyWith(posts: updatedPosts);
    return removed;
  }

  /// Replace an existing post (e.g. after edit).
  void updatePost(ThoughtDto updatedPost) {
    if (!mounted) return;
    final index = state.posts.indexWhere((p) => p.id == updatedPost.id);
    if (index < 0) return;
    final updatedPosts = List<ThoughtDto>.from(state.posts);
    updatedPosts[index] = updatedPost;
    state = state.copyWith(posts: updatedPosts);
  }

  /// Replace a post (e.g. optimistic placeholder with real thought from API).
  void replacePost(String oldThoughtId, ThoughtDto newThought) {
    if (!mounted) return;
    final updatedPosts = state.posts
        .map((p) => p.id == oldThoughtId ? newThought : p)
        .toList();
    state = state.copyWith(posts: updatedPosts);
  }
}
