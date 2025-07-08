import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/utils/metal.helper.dart';
import 'package:metal/core/services/firebase.remote.config.service.dart';
import 'package:metal/helpers/feed_filter_helper.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/domain/entries/thought.model.dart';

class GetThoughtExploreNotifier extends StateNotifier<GetThoughtExploreState> {
  GetThoughtExploreNotifier(
    super.state,
    this.ref,
  ) {
    getThought();
  }
  final Ref ref;

  // Get thoughts with filtering applied
  void getThought() async {
    try {
      state = GetThoughtExploreState.loading();

      // Get thoughts from repository
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.getThoughtExplore();

      // Convert to ThoughtModel list
      final List<ThoughtModel> thoughts = [];
      for (var thought in response.data) {
        thoughts.add(ThoughtModel.fromJson(thought));
      }

      // Sort thoughts by date first
      final sortedThoughts = MetalHelper.sortThoughtsByDate(thoughts);

      // Apply filtering if user is authenticated
      List<ThoughtModel> finalThoughts = sortedThoughts;

      try {
        final authState = ref.read(authProvider);
        if (authState.isSuccess && authState.data != null) {
          final currentUser = authState.data!;

          // Get filter rules from Firebase Remote Config
          final remoteConfigService = FirebaseRemoteConfigService();
          final rulesJson = remoteConfigService.getRules();
          final filterRules = FeedFilterHelper.parseRules(rulesJson);

          // Apply filters if enabled - using optimized synchronous filtering
          // with embedded AuthorMetadata for better performance
          if (filterRules.isNotEmpty) {
            finalThoughts = FeedFilterHelper.applyFilters<ThoughtModel>(
              data: sortedThoughts,
              currentUser: currentUser,
              rulesJson: filterRules,
              getUserById: _getUserById, // Fallback for legacy data
            );
          }
        }
      } catch (filterError) {
        // If filtering fails, continue with unfiltered thoughts
        print('Feed filtering failed: $filterError');
        finalThoughts = sortedThoughts;
      }

      if (mounted) {
        state = GetThoughtExploreState.success(finalThoughts);
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
      final List<ThoughtModel> thoughts = [];
      for (var thought in response.data) {
        thoughts.add(ThoughtModel.fromJson(thought));
      }

      // Sort thoughts by date first
      final sortedThoughts = MetalHelper.sortThoughtsByDate(thoughts);

      // Apply filtering if user is authenticated
      List<ThoughtModel> finalThoughts = sortedThoughts;

      try {
        final authState = ref.read(authProvider);
        if (authState.isSuccess && authState.data != null) {
          final currentUser = authState.data!;

          // Get filter rules from Firebase Remote Config
          final remoteConfigService = FirebaseRemoteConfigService();
          final rulesJson = remoteConfigService.getRules();
          final filterRules = FeedFilterHelper.parseRules(rulesJson);

          // Apply filters if enabled - using optimized synchronous filtering
          // with embedded AuthorMetadata for better performance
          if (filterRules.isNotEmpty) {
            finalThoughts = FeedFilterHelper.applyFilters<ThoughtModel>(
              data: sortedThoughts,
              currentUser: currentUser,
              rulesJson: filterRules,
              getUserById: _getUserById, // Fallback for legacy data
            );
          }
        }
      } catch (filterError) {
        // If filtering fails, continue with unfiltered thoughts
        print('Feed filtering failed: $filterError');
        finalThoughts = sortedThoughts;
      }

      if (mounted) {
        state = GetThoughtExploreState.success(finalThoughts);
      }
    } catch (e, s) {
      state = GetThoughtExploreState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef GetThoughtExploreState = BaseState<List<ThoughtModel>>;

final getThoughtExploreProvider = StateNotifierProvider.autoDispose<
    GetThoughtExploreNotifier, GetThoughtExploreState>(
  (ref) => GetThoughtExploreNotifier(GetThoughtExploreState.initial(), ref),
);
