import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/features/community/data/repositories/community_repository.dart';
import 'package:metal/features/community/data/domain/repositories/icommunity_repository.dart';

// Repository provider
final communityRepositoryProvider = Provider<ICommunityRepository>((ref) {
  return CommunityRepository();
});

// Community members state
class CommunityMembersState {
  final List<Map<String, dynamic>> members;
  final bool isLoading;
  final String? error;

  CommunityMembersState({
    this.members = const [],
    this.isLoading = false,
    this.error,
  });

  CommunityMembersState copyWith({
    List<Map<String, dynamic>>? members,
    bool? isLoading,
    String? error,
  }) {
    return CommunityMembersState(
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Community members notifier
class CommunityMembersNotifier extends StateNotifier<CommunityMembersState> {
  final ICommunityRepository _repository;

  CommunityMembersNotifier(this._repository) : super(CommunityMembersState());

  /// Get community members
  Future<void> getCommunityMembers(String communityId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.getCommunityMembers(communityId);

      if (response.success == true) {
        final members = List<Map<String, dynamic>>.from(response.data ?? []);
        state = state.copyWith(
          isLoading: false,
          members: members,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'An error occurred',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to fetch community members: ${e.toString()}",
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider for the community members notifier
final communityMembersNotifierProvider =
    StateNotifierProvider<CommunityMembersNotifier, CommunityMembersState>(
        (ref) {
  final repository = ref.watch(communityRepositoryProvider);
  return CommunityMembersNotifier(repository);
});

// Provider for specific community members
final communityMembersProvider =
    Provider.family<CommunityMembersState, String>((ref, communityId) {
  final notifier = ref.watch(communityMembersNotifierProvider.notifier);
  final state = ref.watch(communityMembersNotifierProvider);

  // Load members when the provider is first accessed
  ref.listenSelf((previous, next) {
    if (previous?.members.isEmpty == true &&
        next.members.isEmpty &&
        !next.isLoading &&
        next.error == null) {
      notifier.getCommunityMembers(communityId);
    }
  });

  return state;
});
