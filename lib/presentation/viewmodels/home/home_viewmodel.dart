import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metal/core/error_handling/error_handler.dart';
import 'package:metal/core/services/location_service.dart';
import 'package:metal/core/utils/permission_helper.dart';
import 'package:metal/data/repositories/discovery/discovery_repository.dart';
import 'package:metal/domain/entities/discovery_user_dto.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';

/// Whether the user needs to provide location before discovery can work.
enum LocationStatus {
  /// No location issue — either we have it or haven't checked yet.
  ready,

  /// API said location is missing. Permission denied (can still request).
  denied,

  /// API said location is missing. Permission permanently denied (must open Settings).
  permanentlyDenied,
}

/// Home ViewModel State
class HomeState {
  final bool isLoading;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;
  final List<DiscoveryUserDto>? data;
  final bool hasMore;
  final String? nextCursor;
  final SwipeResultDto? lastSwipeResult;
  final LocationStatus locationStatus;

  const HomeState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
    this.data,
    this.hasMore = true,
    this.nextCursor,
    this.lastSwipeResult,
    this.locationStatus = LocationStatus.ready,
  });

  factory HomeState.initial() => const HomeState(isLoading: true, data: []);

  factory HomeState.loading({List<DiscoveryUserDto>? existingUsers}) =>
      HomeState(isLoading: true, data: existingUsers ?? []);

  factory HomeState.success(
    List<DiscoveryUserDto> users, {
    bool hasMore = true,
    String? nextCursor,
    SwipeResultDto? lastSwipeResult,
  }) =>
      HomeState(
        isSuccess: true,
        data: users,
        hasMore: hasMore,
        nextCursor: nextCursor,
        lastSwipeResult: lastSwipeResult,
      );

  factory HomeState.error(String message,
      {List<DiscoveryUserDto>? existingUsers}) {
    Fluttertoast.showToast(msg: message);
    return HomeState(
      isError: true,
      errorMessage: message,
      data: existingUsers ?? [],
    );
  }

  factory HomeState.locationNeeded(bool permanentlyDenied) => HomeState(
        locationStatus: permanentlyDenied
            ? LocationStatus.permanentlyDenied
            : LocationStatus.denied,
      );

  HomeState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
    List<DiscoveryUserDto>? data,
    bool? hasMore,
    String? nextCursor,
    SwipeResultDto? lastSwipeResult,
    LocationStatus? locationStatus,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      lastSwipeResult: lastSwipeResult ?? this.lastSwipeResult,
      locationStatus: locationStatus ?? this.locationStatus,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Helper: check if an error string means "user has no location"
// ─────────────────────────────────────────────────────────────────
bool _isLocationRequiredError(String msg) =>
    msg.contains('Location data required') || msg.contains('Location required');

/// Home ViewModel Notifier
///
/// Flow:
///   1. Call the API immediately.
///   2. If API returns users → done.
///   3. If API returns "location required" → check/request permission
///      → get location → update profile → retry API.
///   4. If permission denied → show permission screen via state.
class HomeViewModelNotifier extends StateNotifier<HomeState> {
  final IDiscoveryRepository _repository;
  final Ref _ref;

  HomeViewModelNotifier(this._repository, this._ref)
      : super(HomeState.initial()) {
    loadUsers();
  }

  // ────────────────────────── Core load ──────────────────────────

  /// Load discovery users. Calls API directly. Handles "location required".
  Future<void> loadUsers() async {
    if (state.isLoading && state.data != null && state.data!.isNotEmpty) return;

    state = HomeState.loading(existingUsers: state.data);

    try {
      final response = await _repository.getDiscoveryUsers(limit: 20);

      if (mounted) {
        state = HomeState.success(
          response.users,
          hasMore: response.pagination?.hasMore ?? false,
          nextCursor: response.pagination?.nextCursor,
        );
        // Background refresh location (fire-and-forget)
        _refreshLocationInBackground();
      }
    } catch (e) {
      if (!mounted) return;
      final errorMessage = ErrorHandler.handleErrorToString(e);

      if (_isLocationRequiredError(errorMessage)) {
        // API says no location → handle location flow
        await _handleLocationRequired();
      } else {
        state = HomeState.error(errorMessage, existingUsers: state.data);
      }
    }
  }

  // ──────────────── Location flow (only when API rejects) ───────

  /// Called when API returns "location required".
  /// Check/request permission, get location, update profile, retry.
  Future<void> _handleLocationRequired() async {
    if (!mounted) return;

    // 1. Already granted?
    if (await PermissionHelper.hasLocationPermission()) {
      await _getLocationAndRetry();
      return;
    }

    // 2. Request once (handles Android "Ask every time")
    final result = await PermissionHelper.requestLocationPermission();
    if (!mounted) return;

    if (result.granted) {
      await _getLocationAndRetry();
      return;
    }

    // 3. Denied → let UI show permission screen
    state = HomeState.locationNeeded(result.permanentlyDenied);
  }

  /// Get device location, push to backend, then retry loadUsers.
  Future<void> _getLocationAndRetry() async {
    if (!mounted) return;
    state = HomeState.loading();

    try {
      final locResult = await LocationService().getCurrentLocation();
      if (locResult.isSuccess && locResult.location != null && mounted) {
        await _ref.read(userStateProvider.notifier).updateUserField(
              field: 'location',
              value: locResult.location!.toJson(),
            );
      }
    } catch (_) {
      // best-effort; the retry below will tell us if it worked
    }

    if (mounted) await _retryLoadUsers();
  }

  /// Retry the API call after updating location.
  Future<void> _retryLoadUsers() async {
    if (!mounted) return;
    state = HomeState.loading();

    try {
      final response = await _repository.getDiscoveryUsers(limit: 20);
      if (mounted) {
        state = HomeState.success(
          response.users,
          hasMore: response.pagination?.hasMore ?? false,
          nextCursor: response.pagination?.nextCursor,
        );
      }
    } catch (e) {
      if (mounted) {
        state = HomeState.error(ErrorHandler.handleErrorToString(e));
      }
    }
  }

  // ──────────────── Public methods for UI ────────────────────────

  /// Called after user grants permission from the permission screen.
  Future<void> onLocationGranted() async {
    if (!mounted) return;
    await _getLocationAndRetry();
  }

  /// Called on app resume — just re-try if we have no data.
  Future<void> retryIfNeeded() async {
    if (!mounted) return;
    if (state.locationStatus != LocationStatus.ready) {
      // Permission may have been granted in Settings — check again
      if (await PermissionHelper.hasLocationPermission()) {
        await _getLocationAndRetry();
      }
      return;
    }
    if (state.data == null || state.data!.isEmpty) {
      await loadUsers();
    } else {
      _refreshLocationInBackground();
    }
  }

  /// Refresh — reset and reload.
  Future<void> refresh() async {
    state = HomeState.initial();
    await loadUsers();
  }

  // ──────────────── Background location refresh ──────────────────

  void _refreshLocationInBackground() {
    PermissionHelper.hasLocationPermission().then((granted) {
      if (granted && mounted) {
        LocationService().getCurrentLocation().then((locResult) {
          if (locResult.isSuccess && locResult.location != null && mounted) {
            _ref.read(userStateProvider.notifier).updateUserField(
                  field: 'location',
                  value: locResult.location!.toJson(),
                );
          }
        });
      }
    });
  }

  // ──────────────── Discovery API (swipe etc.) ───────────────────

  Future<void> loadMoreUsers() async {
    if (state.isLoading || !state.hasMore || state.nextCursor == null) return;

    try {
      final response = await _repository.getDiscoveryUsers(
        limit: 20,
        cursor: state.nextCursor,
      );
      if (mounted) {
        final updatedUsers = [...?state.data, ...response.users];
        state = HomeState.success(
          updatedUsers,
          hasMore: response.pagination?.hasMore ?? false,
          nextCursor: response.pagination?.nextCursor,
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = ErrorHandler.handleErrorToString(e);
        Fluttertoast.showToast(msg: msg);
        state = state.copyWith(isError: true, errorMessage: msg);
      }
    }
  }

  Future<SwipeResultDto?> likeUser(String userId) =>
      _recordSwipe(userId, SwipeAction.like);

  Future<SwipeResultDto?> passUser(String userId) =>
      _recordSwipe(userId, SwipeAction.pass);

  Future<SwipeResultDto?> superLikeUser(String userId) =>
      _recordSwipe(userId, SwipeAction.superlike);

  Future<SwipeResultDto?> _recordSwipe(
      String userId, SwipeAction action) async {
    try {
      final result = await _repository.recordSwipe(
        targetUserId: userId,
        action: action,
      );
      if (mounted) {
        final updatedUsers = (state.data ?? <DiscoveryUserDto>[])
            .where((user) => user.id != userId)
            .toList();
        state = HomeState.success(
          updatedUsers,
          hasMore: state.hasMore,
          nextCursor: state.nextCursor,
          lastSwipeResult: result,
        );
        if (updatedUsers.length < 5 && state.hasMore) loadMoreUsers();
      }
      return result;
    } catch (e) {
      if (mounted) {
        final msg = ErrorHandler.handleErrorToString(e);
        Fluttertoast.showToast(msg: msg);
        state = state.copyWith(isError: true, errorMessage: msg);
      }
      return null;
    }
  }

  Future<void> undoLastSwipe() async {
    try {
      await _repository.undoLastSwipe();
      await loadUsers();
    } catch (e) {
      if (mounted) {
        final msg = ErrorHandler.handleErrorToString(e);
        Fluttertoast.showToast(msg: msg);
        state = state.copyWith(isError: true, errorMessage: msg);
      }
    }
  }

  void clearLastSwipeResult() {
    state = state.copyWith(lastSwipeResult: null);
  }

  void removeUser(String userId) {
    final updatedUsers = (state.data ?? <DiscoveryUserDto>[])
        .where((user) => user.id != userId)
        .toList();
    state = state.copyWith(data: updatedUsers);
    if (updatedUsers.length < 5 && state.hasMore) loadMoreUsers();
  }

  List<DiscoveryUserDto> get users => state.data ?? [];
  bool get hasUsers => users.isNotEmpty;
  DiscoveryUserDto? get currentUser => users.isNotEmpty ? users.first : null;
}

// ─────────────────────────── Providers ───────────────────────────
//
// Not using autoDispose so the notifier is created once per app session.
// With autoDispose, the notifier was disposed whenever HomeView unmounted
// (e.g. dashboard showed loading spinner, or user switched tabs). When
// HomeView mounted again, a new notifier was created → constructor and
// loadUsers() ran again.

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModelNotifier, HomeState>((ref) {
  final repository = ref.watch(discoveryRepositoryProvider);
  return HomeViewModelNotifier(repository, ref);
});

final discoveryUsersProvider =
    Provider.autoDispose<List<DiscoveryUserDto>>((ref) {
  return ref.watch(homeViewModelProvider).data ?? [];
});

final lastSwipeResultProvider = Provider.autoDispose<SwipeResultDto?>((ref) {
  return ref.watch(homeViewModelProvider).lastSwipeResult;
});
