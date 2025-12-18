import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/domain/usecases/profile_usecase.dart';
import 'package:metal/presentation/viewmodels/base_viewmodel.dart';

/// Profile ViewModel
/// Manages user profile state throughout the application
/// Can be accessed from any UI to get current user information
class ProfileViewModel extends BaseViewModel<UserDto> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileViewModel({
    required this.getUserProfileUseCase,
    required this.updateProfileUseCase,
  });

  /// Fetch user profile from API
  /// Call this after login or whenever you need to refresh user data
  Future<void> fetchUserProfile() async {
    setLoading();

    final result = await getUserProfileUseCase();

    if (result.isSuccess && result.data != null) {
      setSuccess(result.data!);
    } else {
      setError(result.errorMessage ?? 'Failed to fetch user profile');
    }
  }

  /// Update user profile
  /// Updates specific profile fields
  Future<void> updateProfile(UpdateProfileParams params) async {
    setLoading();

    final result = await updateProfileUseCase(params);

    if (result.isSuccess && result.data != null) {
      setSuccess(result.data!);
    } else {
      setError(result.errorMessage ?? 'Failed to update profile');
    }
  }

  /// Refresh user profile
  /// Alias for fetchUserProfile for clarity
  Future<void> refreshProfile() async {
    await fetchUserProfile();
  }

  /// Get current user data
  /// Returns null if not loaded or in error state
  UserDto? get currentUser {
    if (state.isSuccess && state.data != null) {
      return state.data;
    }
    return null;
  }

  /// Check if user profile is loaded
  bool get isProfileLoaded => state.isSuccess && state.data != null;

  /// Check if user has completed profile
  bool get hasCompletedProfile {
    return currentUser?.profileUpdated ?? false;
  }
}
