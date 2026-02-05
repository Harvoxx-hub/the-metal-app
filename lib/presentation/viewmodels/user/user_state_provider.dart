import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/di/provider_setup.dart';
import 'package:metal/core/state/base.state.dart';
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

/// Provider to get user by ID
/// Returns BaseState<UserDto> with user data, loading, or error state
///
/// Usage:
/// ```dart
/// final userState = ref.watch(getUserProvider(userId));
/// if (userState.isLoading) { ... }
/// if (userState.isError) { ... }
/// final user = userState.data; // UserDto?
/// ```
final getUserProvider =
    FutureProvider.family<BaseState<UserDto>, String>((ref, userId) async {
  final profileRepo = ref.read(profileRepositoryProvider);
  return await profileRepo.getUserById(userId);
});

/// State for user search/query results
class GetUsersByQueryState {
  final List<UserDto>? data;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  const GetUsersByQueryState({
    this.data,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
  });

  GetUsersByQueryState copyWith({
    List<UserDto>? data,
    bool? isLoading,
    bool? isError,
    String? errorMessage,
  }) {
    return GetUsersByQueryState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier for searching users by query
class GetUsersByQueryNotifier extends StateNotifier<GetUsersByQueryState> {
  final Ref _ref;

  GetUsersByQueryNotifier(this._ref) : super(const GetUsersByQueryState());

  /// Search users by query (username, name, etc.)
  /// Backend accepts any query length; empty query clears results without API call.
  Future<void> getUserByquery({required String query}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = const GetUsersByQueryState();
      return;
    }

    state = state.copyWith(isLoading: true, isError: false);

    try {
      final profileRepo = _ref.read(profileRepositoryProvider);
      final result = await profileRepo.searchUsers(query: trimmed, limit: 10);

      if (result.isSuccess && result.data != null) {
        state = GetUsersByQueryState(
          data: result.data,
          isLoading: false,
          isError: false,
        );
      } else {
        state = GetUsersByQueryState(
          data: null,
          isLoading: false,
          isError: true,
          errorMessage: result.errorMessage ?? 'Failed to search users',
        );
      }
    } catch (e) {
      state = GetUsersByQueryState(
        data: null,
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Clear search results
  void clear() {
    state = const GetUsersByQueryState();
  }
}

/// Provider for searching users by name/query
///
/// Usage:
/// ```dart
/// // Trigger search
/// ref.read(getUserByNameProvider.notifier).getUserByquery(query: 'john');
///
/// // Watch results
/// final searchState = ref.watch(getUserByNameProvider);
/// if (searchState.isLoading) { ... }
/// if (searchState.isError) { ... }
/// final users = searchState.data; // List<UserDto>?
/// ```
final getUserByNameProvider =
    StateNotifierProvider<GetUsersByQueryNotifier, GetUsersByQueryState>((ref) {
  return GetUsersByQueryNotifier(ref);
});
