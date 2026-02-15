import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metal/core/error_handling/error_handler.dart';
import 'package:metal/data/repositories/discovery/discovery_repository.dart';
import 'package:metal/domain/entities/discovery_user_dto.dart';

/// Whether discovery needs location (from API). Location is stored in user model; discovery does not request or update it.
enum LocationStatus {
  ready,
  denied,
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

bool _isLocationRequiredError(String msg) =>
    msg.contains('Location data required') || msg.contains('Location required');

/// Home ViewModel: discovery only calls the API. Location is stored in user model (splash / central Enable Location screen).
/// When API returns "location required", we set locationNeeded and the UI navigates to the central location screen.
class HomeViewModelNotifier extends StateNotifier<HomeState> {
  final IDiscoveryRepository _repository;

  HomeViewModelNotifier(this._repository, Ref ref)
      : super(HomeState.initial()) {
    loadUsers();
  }

  /// Load discovery users. Uses location from stored user model (backend). No permission or location logic here.
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
      }
    } catch (e) {
      if (!mounted) return;
      final errorMessage = ErrorHandler.handleErrorToString(e);

      if (_isLocationRequiredError(errorMessage)) {
        state = HomeState.locationNeeded(false);
      } else {
        state = HomeState.error(errorMessage, existingUsers: state.data);
      }
    }
  }

  /// Called when returning from central location screen (or on resume). Retry API; user model may now have location.
  Future<void> retryIfNeeded() async {
    if (!mounted) return;
    if (state.locationStatus != LocationStatus.ready) {
      await loadUsers();
      return;
    }
    if (state.data == null || state.data!.isEmpty) {
      await loadUsers();
    }
  }

  /// Refresh — reset and reload.
  Future<void> refresh() async {
    state = HomeState.initial();
    await loadUsers();
  }

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
