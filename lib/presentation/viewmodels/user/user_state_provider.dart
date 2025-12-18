import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/di/provider_setup.dart';
import 'package:metal/core/storage/secure_storage_helper.dart';
import 'package:metal/data/repositories/auth/auth_repository_providers.dart';
import 'package:metal/data/repositories/profile/profile_repository_providers.dart';
import 'package:metal/domain/entities/user_dto.dart';

/// User state - represents authentication status
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

/// User state model
class UserState {
  final AuthStatus status;
  final UserDto? user;
  final String? errorMessage;
  final bool isUpdating;

  const UserState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isUpdating = false,
  });

  UserState copyWith({
    AuthStatus? status,
    UserDto? user,
    String? errorMessage,
    bool? isUpdating,
  }) {
    return UserState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
}

/// Global User State Notifier
/// SINGLE SOURCE OF TRUTH for current user throughout the app
///
/// All user-related operations (fetch, update, logout) go through here.
/// Views should ONLY call methods on this notifier - no direct API calls.
class UserStateNotifier extends StateNotifier<UserState> {
  final SecureStorageHelper _secureStorage;
  final Ref _ref;

  UserStateNotifier(this._secureStorage, this._ref) : super(const UserState());

  /// Set user after successful login/signup
  void setUser(UserDto user) {
    state = UserState(
      status: AuthStatus.authenticated,
      user: user,
    );
  }

  /// Update user data locally (when you already have the updated UserDto)
  void updateUser(UserDto user) {
    state = state.copyWith(user: user);
  }

  /// Update a single user field via API
  /// This is the ONLY method that should be used to update user data
  ///
  /// Usage:
  /// ```dart
  /// await ref.read(userStateProvider.notifier).updateUserField(
  ///   field: 'gender',
  ///   value: 'Male',
  /// );
  /// ```
  Future<bool> updateUserField({
    required String field,
    required dynamic value,
  }) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    try {
      final profileRepo = _ref.read(profileRepositoryProvider);
      final result = await profileRepo.updateUserProfile(
        profileData: {field: value},
      );

      if (result.isSuccess && result.data != null) {
        state = state.copyWith(
          user: result.data,
          isUpdating: false,
        );
        return true;
      }

      state = state.copyWith(
        isUpdating: false,
        errorMessage: result.errorMessage ?? 'Failed to update profile',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Update multiple user fields at once via API
  ///
  /// Usage:
  /// ```dart
  /// await ref.read(userStateProvider.notifier).updateUserFields({
  ///   'preferences': preferencesJson,
  ///   'distance': '50 km',
  /// });
  /// ```
  Future<bool> updateUserFields(Map<String, dynamic> fields) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    try {
      final profileRepo = _ref.read(profileRepositoryProvider);
      final result = await profileRepo.updateUserProfile(profileData: fields);

      if (result.isSuccess && result.data != null) {
        state = state.copyWith(
          user: result.data,
          isUpdating: false,
        );
        return true;
      }

      state = state.copyWith(
        isUpdating: false,
        errorMessage: result.errorMessage ?? 'Failed to update profile',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Fetch user profile from API and update state
  Future<void> fetchAndSetUser() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final profileRepo = _ref.read(profileRepositoryProvider);
      final result = await profileRepo.getUserProfile();

      if (result.isSuccess && result.data != null) {
        state = UserState(
          status: AuthStatus.authenticated,
          user: result.data,
        );
      } else {
        state = UserState(
          status: AuthStatus.unauthenticated,
          errorMessage: result.errorMessage,
        );
      }
    } catch (e) {
      state = UserState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  /// Logout - clear everything
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      // Call logout API (optional - might fail if token expired)
      try {
        final authRepo = _ref.read(authRepositoryProvider);
        await authRepo.logout();
      } catch (_) {
        // Ignore logout API errors - still clear local state
      }

      // Clear stored tokens
      await _secureStorage.delete('auth_token');
      await _secureStorage.delete('refresh_token');

      // Clear user state
      state = const UserState(status: AuthStatus.unauthenticated);
    } catch (e) {
      // Even on error, set to unauthenticated
      state = const UserState(status: AuthStatus.unauthenticated);
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Clear state (for resetting without API call)
  void clear() {
    state = const UserState(status: AuthStatus.unauthenticated);
  }

  /// Check if user has completed profile setup
  bool get hasCompletedProfile => state.user?.profileUpdated ?? false;

  /// Check if user email is verified
  bool get isEmailVerified => state.user?.emailVerified ?? false;

  /// Get current user ID
  String? get userId => state.user?.id;

  /// Get current user email
  String? get userEmail => state.user?.email;
}

/// Global User State Provider
/// Access this anywhere to get current user state
///
/// Usage:
/// - Watch state: `ref.watch(userStateProvider)` - get UserState
/// - Watch user: `ref.watch(currentUserProvider)` - get UserDto?
/// - Update field: `ref.read(userStateProvider.notifier).updateUserField(...)`
/// - Update fields: `ref.read(userStateProvider.notifier).updateUserFields(...)`
/// - Logout: `ref.read(userStateProvider.notifier).logout()`
final userStateProvider =
    StateNotifierProvider<UserStateNotifier, UserState>((ref) {
  return UserStateNotifier(
    ref.read(secureStorageHelperProvider),
    ref,
  );
});

/// Convenience provider - just the current user
final currentUserProvider = Provider<UserDto?>((ref) {
  return ref.watch(userStateProvider).user;
});

/// Convenience provider - is user authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(userStateProvider).isAuthenticated;
});

/// Convenience provider - is user data being updated
final isUpdatingUserProvider = Provider<bool>((ref) {
  return ref.watch(userStateProvider).isUpdating;
});
