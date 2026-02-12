import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/profile/profile_repository_providers.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';

/// State for profile photo upload
class ProfilePhotoState {
  final bool isUploading;
  final String? errorMessage;
  final String? successMessage;

  ProfilePhotoState({
    this.isUploading = false,
    this.errorMessage,
    this.successMessage,
  });

  ProfilePhotoState copyWith({
    bool? isUploading,
    String? errorMessage,
    String? successMessage,
  }) {
    return ProfilePhotoState(
      isUploading: isUploading ?? this.isUploading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  factory ProfilePhotoState.initial() => ProfilePhotoState();
}

/// ViewModel for profile photo upload
class ProfilePhotoViewModel extends StateNotifier<ProfilePhotoState> {
  final Ref _ref;

  ProfilePhotoViewModel(this._ref) : super(ProfilePhotoState.initial());

  /// Upload profile photo
  /// Returns true if successful, false otherwise
  Future<bool> uploadProfilePhoto({
    required File photoFile,
    required String contentType,
  }) async {
    state = state.copyWith(
      isUploading: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final repository = _ref.read(profileRepositoryProvider);

      // Upload photo via repository
      final result = await repository.uploadProfilePhoto(
        photoFile: photoFile,
        contentType: contentType,
      );

      if (result.isSuccess && result.data != null) {
        // Update global user state with new profile data
        await _ref.read(userStateProvider.notifier).fetchAndSetUser();

        state = state.copyWith(
          isUploading: false,
          successMessage: 'Profile photo updated successfully',
        );

        return true;
      } else {
        state = state.copyWith(
          isUploading: false,
          errorMessage: result.errorMessage ?? 'Failed to upload photo',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: 'Failed to upload photo: $e',
      );
      return false;
    }
  }

  /// Clear messages
  void clearMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }
}

/// Provider for profile photo upload ViewModel
final profilePhotoViewModelProvider =
    StateNotifierProvider<ProfilePhotoViewModel, ProfilePhotoState>((ref) {
  return ProfilePhotoViewModel(ref);
});
