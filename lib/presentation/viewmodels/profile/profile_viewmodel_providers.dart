import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/domain/usecases/profile_usecase_providers.dart';
import 'package:metal/presentation/viewmodels/profile/profile_viewmodel.dart';

/// Profile ViewModel Provider
/// Use this throughout the app to access current user profile
/// Example: ref.watch(profileViewModelProvider) to get user state
/// Example: ref.read(profileViewModelProvider.notifier).fetchUserProfile() to load user
final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, BaseState<UserDto>>((ref) {
  return ProfileViewModel(
    getUserProfileUseCase: ref.read(getUserProfileUseCaseProvider),
    updateProfileUseCase: ref.read(updateProfileUseCaseProvider),
  );
});
