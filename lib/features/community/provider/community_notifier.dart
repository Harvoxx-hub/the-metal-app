import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/features/community/data/domain/entries/community.model.dart';
import 'package:metal/features/community/data/repositories/community_repository.dart';
import 'package:metal/features/community/data/domain/repositories/icommunity_repository.dart';
import 'package:metal/core/services/firebase.service.db.dart';

// Repository provider
final communityRepositoryProvider = Provider<ICommunityRepository>((ref) {
  return CommunityRepository();
});

// Community state
class CommunityState {
  final List<CommunityModel> allCommunities;
  final List<CommunityModel> communities;
  final List<CommunityModel> userCommunities;
  final CommunityModel? selectedCommunity;
  final bool isLoading;
  final bool isCreating;
  final String? error;
  final String? successMessage;

  CommunityState({
    this.allCommunities = const [],
    this.communities = const [],
    this.userCommunities = const [],
    this.selectedCommunity,
    this.isLoading = false,
    this.isCreating = false,
    this.error,
    this.successMessage,
  });

  CommunityState copyWith({
    List<CommunityModel>? allCommunities,
    List<CommunityModel>? communities,
    List<CommunityModel>? userCommunities,
    CommunityModel? selectedCommunity,
    bool? isLoading,
    bool? isCreating,
    String? error,
    String? successMessage,
  }) {
    return CommunityState(
      allCommunities: allCommunities ?? this.allCommunities,
      communities: communities ?? this.communities,
      userCommunities: userCommunities ?? this.userCommunities,
      selectedCommunity: selectedCommunity ?? this.selectedCommunity,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      error: error,
      successMessage: successMessage,
    );
  }
}

// Community notifier
class CommunityNotifier extends StateNotifier<CommunityState> {
  final ICommunityRepository _repository;

  CommunityNotifier(this._repository) : super(CommunityState());

  /// Update community details (creator only)
  Future<void> updateCommunity(CommunityModel updatedCommunity) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      final response = await _repository.updateCommunity(updatedCommunity);
      if (response.success == true) {
        // Update locally in lists and selectedCommunity
        final List<CommunityModel> updatedList = state.communities
            .map((c) => c.id == updatedCommunity.id ? updatedCommunity : c)
            .toList();
        final List<CommunityModel> updatedAllList = state.allCommunities
            .map((c) => c.id == updatedCommunity.id ? updatedCommunity : c)
            .toList();

        state = state.copyWith(
          isLoading: false,
          communities: updatedList,
          allCommunities: updatedAllList,
          selectedCommunity: updatedCommunity,
          successMessage: response.message ?? 'Community updated successfully',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to update community',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update community: ${e.toString()}',
      );
    }
  }

  /// Create a new community with optional image upload
  Future<void> createCommunity(CommunityModel community,
      {String? imagePath}) async {
    state = state.copyWith(isCreating: true, error: null);

    try {
      // First create the community without image
      final response = await _repository.createCommunity(community);

      if (response.success == true) {
        // Get the created community ID from the response
        final createdCommunity = CommunityModel.fromJson(response.data);

        // Upload image to Firebase Storage if one is provided
        if (imagePath != null && imagePath.isNotEmpty) {
          // Upload the image using the actual community ID
          final uploadResponse = await _repository.uploadCommunityImage(
              imagePath, createdCommunity.id);

          if (uploadResponse.success == true && uploadResponse.data != null) {
            // Update the community with the image URL
            final updatedCommunity = createdCommunity.copyWith(
                bannerImage: uploadResponse.data as String);

            // Add the updated community to the list
            final updatedCommunities = [updatedCommunity, ...state.communities];
            final updatedAllCommunities = [
              updatedCommunity,
              ...state.allCommunities
            ];
            state = state.copyWith(
              isCreating: false,
              communities: updatedCommunities,
              allCommunities: updatedAllCommunities,
              successMessage:
                  response.message ?? 'Community created successfully',
            );
          } else {
            // Community created but image upload failed
            final updatedCommunities = [createdCommunity, ...state.communities];
            final updatedAllCommunities = [
              createdCommunity,
              ...state.allCommunities
            ];
            state = state.copyWith(
              isCreating: false,
              communities: updatedCommunities,
              allCommunities: updatedAllCommunities,
              successMessage:
                  'Community created successfully, but image upload failed',
            );
          }
        } else {
          // No image to upload, just add the community
          final updatedCommunities = [createdCommunity, ...state.communities];
          final updatedAllCommunities = [
            createdCommunity,
            ...state.allCommunities
          ];
          state = state.copyWith(
            isCreating: false,
            communities: updatedCommunities,
            allCommunities: updatedAllCommunities,
            successMessage:
                response.message ?? 'Community created successfully',
          );
        }
      } else {
        state = state.copyWith(
          isCreating: false,
          error: response.message ?? 'An error occurred',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: "Failed to create community: ${e.toString()}",
      );
    }
  }

  /// Get all communities
  Future<void> getAllCommunities() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.getAllCommunities();

      if (response.success == true) {
        final List<CommunityModel> all =
            List<CommunityModel>.from(response.data ?? const []);
        state = state.copyWith(
          isLoading: false,
          allCommunities: all,
          communities: all,
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
        error: "Failed to fetch communities: ${e.toString()}",
      );
    }
  }

  /// Get communities by category
  Future<void> getCommunitiesByCategory(String category) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.getCommunitiesByCategory(category);

      if (response.success == true) {
        state = state.copyWith(
          isLoading: false,
          communities: response.data,
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
        error: "Failed to fetch communities: ${e.toString()}",
      );
    }
  }

  /// Search communities
  Future<void> searchCommunities(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      // Reset to full list locally
      state = state.copyWith(communities: state.allCommunities);
      return;
    }

    // Local, case-insensitive filter on cached list
    final filtered = state.allCommunities.where((c) {
      final name = c.name.toLowerCase();
      final desc = c.description.toLowerCase();
      final creator = c.creatorName.toLowerCase();
      final tags = c.tags.map((t) => t.toLowerCase());
      return name.contains(q) ||
          desc.contains(q) ||
          creator.contains(q) ||
          tags.any((t) => t.contains(q));
    }).toList()
      ..sort((a, b) => b.memberCount.compareTo(a.memberCount));

    state = state.copyWith(communities: filtered);
  }

  /// Get community by ID
  Future<void> getCommunityById(String communityId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.getCommunityById(communityId);

      if (response.success == true) {
        state = state.copyWith(
          isLoading: false,
          selectedCommunity: response.data,
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
        error: "Failed to fetch community: ${e.toString()}",
      );
    }
  }

  /// Join a community
  Future<void> joinCommunity(String communityId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final currentUserId = FirebaseServiceDb.instance.userId;
      if (currentUserId == null) {
        state = state.copyWith(
          isLoading: false,
          error: "User not authenticated",
        );
        return;
      }

      final response =
          await _repository.joinCommunity(communityId, currentUserId);

      if (response.success == true) {
        // Update the community in the list to reflect the join
        final updatedCommunities = state.communities.map((community) {
          if (community.id == communityId) {
            return community.copyWith(
              isJoined: true,
              memberCount: community.memberCount + 1,
            );
          }
          return community;
        }).toList();

        final updatedAll = state.allCommunities.map((community) {
          if (community.id == communityId) {
            return community.copyWith(
              isJoined: true,
              memberCount: community.memberCount + 1,
            );
          }
          return community;
        }).toList();

        // Update selectedCommunity if it's the same community
        CommunityModel? updatedSelectedCommunity = state.selectedCommunity;
        if (updatedSelectedCommunity?.id == communityId) {
          updatedSelectedCommunity = updatedSelectedCommunity!.copyWith(
            isJoined: true,
            memberCount: updatedSelectedCommunity.memberCount + 1,
          );
        }

        state = state.copyWith(
          isLoading: false,
          communities: updatedCommunities,
          allCommunities: updatedAll,
          selectedCommunity: updatedSelectedCommunity,
          successMessage:
              response.message ?? 'Operation completed successfully',
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
        error: "Failed to join community: ${e.toString()}",
      );
    }
  }

  /// Leave a community
  Future<void> leaveCommunity(String communityId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final currentUserId = FirebaseServiceDb.instance.userId;
      if (currentUserId == null) {
        state = state.copyWith(
          isLoading: false,
          error: "User not authenticated",
        );
        return;
      }

      final response =
          await _repository.leaveCommunity(communityId, currentUserId);

      if (response.success == true) {
        // Update the community in the list to reflect the leave
        final updatedCommunities = state.communities.map((community) {
          if (community.id == communityId) {
            return community.copyWith(
              isJoined: false,
              memberCount: community.memberCount - 1,
            );
          }
          return community;
        }).toList();

        final updatedAll = state.allCommunities.map((community) {
          if (community.id == communityId) {
            return community.copyWith(
              isJoined: false,
              memberCount: community.memberCount - 1,
            );
          }
          return community;
        }).toList();

        // Update selectedCommunity if it's the same community
        CommunityModel? updatedSelectedCommunity = state.selectedCommunity;
        if (updatedSelectedCommunity?.id == communityId) {
          updatedSelectedCommunity = updatedSelectedCommunity!.copyWith(
            isJoined: false,
            memberCount: updatedSelectedCommunity.memberCount - 1,
          );
        }

        state = state.copyWith(
          isLoading: false,
          communities: updatedCommunities,
          allCommunities: updatedAll,
          selectedCommunity: updatedSelectedCommunity,
          successMessage:
              response.message ?? 'Operation completed successfully',
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
        error: "Failed to leave community: ${e.toString()}",
      );
    }
  }

  /// Get user's communities
  Future<void> getUserCommunities(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.getUserCommunities(userId);

      if (response.success == true) {
        state = state.copyWith(
          isLoading: false,
          userCommunities: response.data,
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
        error: "Failed to fetch user communities: ${e.toString()}",
      );
    }
  }

  /// Upload community image
  Future<void> uploadCommunityImage(String filePath, String communityId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response =
          await _repository.uploadCommunityImage(filePath, communityId);

      if (response.success == true) {
        // Update the community with the new image URL
        final updatedCommunities = state.communities.map((community) {
          if (community.id == communityId) {
            return community.copyWith(bannerImage: response.data);
          }
          return community;
        }).toList();

        final updatedAll = state.allCommunities.map((community) {
          if (community.id == communityId) {
            return community.copyWith(bannerImage: response.data);
          }
          return community;
        }).toList();

        state = state.copyWith(
          isLoading: false,
          communities: updatedCommunities,
          allCommunities: updatedAll,
          successMessage:
              response.message ?? 'Operation completed successfully',
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
        error: "Failed to upload image: ${e.toString()}",
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Get community members
  Future<void> getCommunityMembers(String communityId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.getCommunityMembers(communityId);

      if (response.success == true) {
        state = state.copyWith(
          isLoading: false,
          // Note: We'll need to add members to the state if needed
          successMessage: response.message ?? 'Members retrieved successfully',
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

  /// Clear success message
  void clearSuccessMessage() {
    state = state.copyWith(successMessage: null);
  }
}

// Provider for the community notifier
final communityNotifierProvider =
    StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
  final repository = ref.watch(communityRepositoryProvider);
  return CommunityNotifier(repository);
});

// Family provider for individual communities
final communityProvider =
    Provider.family<CommunityModel?, String>((ref, communityId) {
  final state = ref.watch(communityNotifierProvider);

  // Return the community if it matches the requested ID
  if (state.selectedCommunity?.id == communityId) {
    return state.selectedCommunity;
  }

  return null;
});
