import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/utils/metal.helper.dart';
import 'package:metal/core/services/firebase.remote.config.service.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/helpers/feed_filter_helper.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/thought/repositories/home.repository.dart';
import 'package:metal/features/thought/data/domain/entries/thought.model.dart';
import 'package:metal/features/thought/data/domain/entries/explore_feed_model.dart';

class GetThoughtExploreNotifier extends StateNotifier<GetThoughtExploreState> {
  GetThoughtExploreNotifier(
    super.state,
    this.ref,
  ) {
    getThought();
  }
  final Ref ref;

  // Get thoughts with featured/unfeatured filtering applied
  void getThought() async {
    try {
      state = GetThoughtExploreState.loading();

      // Get thoughts from repository
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.getThoughtExplore();

      // Convert to ThoughtModel list
      final List<ThoughtModel> allThoughts = [];
      for (var thought in response.data) {
        allThoughts.add(ThoughtModel.fromJson(thought));
      }

      // Sort thoughts by date first
      final sortedThoughts = MetalHelper.sortThoughtsByDate(allThoughts);

      // Initialize with default values
      List<ThoughtModel> featuredThoughts = [];
      List<ThoughtModel> unfeaturedThoughts = sortedThoughts;
      bool showDivider = false;

      try {
        final userState = ref.read(userStateProvider);
        if (userState.isSuccess && userState.data != null) {
          final currentUser = ref.read(userStateProvider).data!;

          // Get filter rules from Firebase Remote Config
          final remoteConfigService = FirebaseRemoteConfigService();
          final rulesJson = remoteConfigService.getRules();
          final filterRules = FeedFilterHelper.parseRules(rulesJson);

          // Apply filters if enabled to get featured thoughts
          if (filterRules.isNotEmpty) {
            featuredThoughts = FeedFilterHelper.applyFilters<ThoughtModel>(
              data: sortedThoughts,
              currentUser: currentUser,
              rulesJson: filterRules,
              getUserById: _getUserById, // Fallback for legacy data
            );

            // Get unfeatured thoughts (all thoughts minus featured ones)
            final featuredIds = featuredThoughts.map((t) => t.id).toSet();
            unfeaturedThoughts = sortedThoughts
                .where((thought) => !featuredIds.contains(thought.id))
                .toList();

            // Show divider only if we have both featured and unfeatured thoughts
            showDivider =
                featuredThoughts.isNotEmpty || unfeaturedThoughts.isNotEmpty;
          }
        }
      } catch (filterError) {
        // If filtering fails, treat all thoughts as unfeatured
        print('Feed filtering failed: $filterError');
        featuredThoughts = [];
        unfeaturedThoughts = sortedThoughts;
        showDivider = false;
      }

      // Create the explore feed model
      final exploreFeed = ExploreFeedModel(
        featuredThoughts: featuredThoughts,
        unfeaturedThoughts: unfeaturedThoughts,
        showDivider: showDivider,
      );

      if (mounted) {
        state = GetThoughtExploreState.success(exploreFeed);
      }
    } catch (e, s) {
      state = GetThoughtExploreState.error(e.toString(), stackTrace: s);
    }
  }

  /// Helper method to get user by ID for filtering
  Future<UserModel?> _getUserById(String userId) async {
    try {
      final authRepository = ref.read(authenticationRepositoryProvider);
      final response = await authRepository.getUserByID(id: userId);

      if (response.success == true && response.data != null) {
        return UserModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching user $userId: $e');
      return null;
    }
  }

  void getThoughtUpdate() async {
    try {
      state = GetThoughtExploreState.loading();

      // Get thoughts from repository
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.getThoughtExplore();

      // Convert to ThoughtModel list
      final List<ThoughtModel> allThoughts = [];
      for (var thought in response.data) {
        allThoughts.add(ThoughtModel.fromJson(thought));
      }

      // Sort thoughts by date first
      final sortedThoughts = MetalHelper.sortThoughtsByDate(allThoughts);

      // Initialize with default values
      List<ThoughtModel> featuredThoughts = [];
      List<ThoughtModel> unfeaturedThoughts = sortedThoughts;
      bool showDivider = false;

      try {
        final userState = ref.read(userStateProvider);
        if (userState.isSuccess && userState.data != null) {
          final currentUser = userState.data!;

          // Get filter rules from Firebase Remote Config
          final remoteConfigService = FirebaseRemoteConfigService();
          final rulesJson = remoteConfigService.getRules();
          final filterRules = FeedFilterHelper.parseRules(rulesJson);

          // Apply filters if enabled to get featured thoughts
          if (filterRules.isNotEmpty) {
            featuredThoughts = FeedFilterHelper.applyFilters<ThoughtModel>(
              data: sortedThoughts,
              currentUser: currentUser,
              rulesJson: filterRules,
              getUserById: _getUserById, // Fallback for legacy data
            );

            // Get unfeatured thoughts (all thoughts minus featured ones)
            final featuredIds = featuredThoughts.map((t) => t.id).toSet();
            unfeaturedThoughts = sortedThoughts
                .where((thought) => !featuredIds.contains(thought.id))
                .toList();

            // Show divider only if we have both featured and unfeatured thoughts
            showDivider =
                featuredThoughts.isNotEmpty && unfeaturedThoughts.isNotEmpty;
          }
        }
      } catch (filterError) {
        // If filtering fails, treat all thoughts as unfeatured
        print('Feed filtering failed: $filterError');
        featuredThoughts = [];
        unfeaturedThoughts = sortedThoughts;
        showDivider = false;
      }

      // Create the explore feed model
      final exploreFeed = ExploreFeedModel(
        featuredThoughts: featuredThoughts,
        unfeaturedThoughts: unfeaturedThoughts,
        showDivider: showDivider,
      );

      if (mounted) {
        state = GetThoughtExploreState.success(exploreFeed);
      }
    } catch (e, s) {
      state = GetThoughtExploreState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef GetThoughtExploreState = BaseState<ExploreFeedModel>;

final getThoughtExploreProvider = StateNotifierProvider.autoDispose<
    GetThoughtExploreNotifier, GetThoughtExploreState>(
  (ref) => GetThoughtExploreNotifier(GetThoughtExploreState.initial(), ref),
);
