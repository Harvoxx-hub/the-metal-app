import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/profile/profile_repository_providers.dart';
import 'package:metal/presentation/viewmodels/thought/thought_providers.dart';
import 'package:metal/presentation/viewmodels/user/user_profile_viewmodel.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';

/// Provider for UserProfileViewModel - keyed by userId.
/// When userId is the current user, uses GET /users/me for full profile; otherwise GET /users/:id (limited public profile).
final userProfileViewModelProvider = StateNotifierProvider.autoDispose
    .family<UserProfileViewModel, UserProfileState, String>((ref, userId) {
  final profileRepository = ref.watch(profileRepositoryProvider);
  final thoughtRepository = ref.watch(thoughtRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider);
  return UserProfileViewModel(
    profileRepository: profileRepository,
    thoughtRepository: thoughtRepository,
    userId: userId,
    currentUserId: currentUser?.id,
  );
});
