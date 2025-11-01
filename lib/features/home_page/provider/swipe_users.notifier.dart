import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/home_page/data/domain/repositories/iswipe_repository.dart';
import 'package:metal/features/home_page/data/repositories/swipe_repository.dart';

class SwipeUsersNotifier extends StateNotifier<SwipeUsersState> {
  SwipeUsersNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  List<UserModel> _users = [];
  String? _lastUserId;
  bool _hasMoreUsers = true;

  List<UserModel> get users => _users;
  bool get hasMoreUsers => _hasMoreUsers;
  bool get isLoading => state.isLoading;
  bool get hasError => state.isError;

  /// Load initial users for swiping
  Future<void> loadSwipeUsers( ) async {
    try {
      state = SwipeUsersState.loading();
      final swipeRepository = ref.watch(swipeRepositoryProvider);

      final response = await swipeRepository.getSwipeUsers( );

      if (mounted) {
        if (response.success == true && response.data is List) {
          // The repository already returns UserModel objects
          final users = (response.data as List<UserModel>);

          _users = users;
          _lastUserId = users.isNotEmpty ? users.last.id : null;
     

          state = SwipeUsersState.success(_users);

         
        } else {
          print(response.message);
          state =
              SwipeUsersState.error(response.message ?? "Failed to load users");
        }
      }
    } catch (e, s) {
      print(e);
      print(s);
      if (mounted) {
        state = SwipeUsersState.error(e.toString(), stackTrace: s);
      }
    }
  }

  /// Load more users for swiping (pagination)
  Future<void> loadMoreUsers( ) async {
    if (!_hasMoreUsers || isLoading) return;

    try {
      final swipeRepository = ref.watch(swipeRepositoryProvider);

      if (_lastUserId == null) {
        state = SwipeUsersState.error("No more users to load");
        return;
      }

      final response = await swipeRepository.getMoreSwipeUsers(
        lastUserId: _lastUserId!,
   
      );

      if (mounted) {
        if (response.success == true && response.data is List) {
          // The repository already returns UserModel objects
          final newUsers = (response.data as List<UserModel>);

          _users.addAll(newUsers);
          _lastUserId = newUsers.isNotEmpty ? newUsers.last.id : null;
        
          state = SwipeUsersState.success(_users);
        } else {
          _hasMoreUsers = false;
          state = SwipeUsersState.error(
              response.message ?? "Failed to load more users");
        }
      }
    } catch (e, s) {
      print(e);
      print(s);
      if (mounted) {
        state = SwipeUsersState.error(e.toString(), stackTrace: s);
      }
    }
  }

  /// Record a swipe action and remove the user from the list
  Future<void> recordSwipeAction({
    required String targetUserId,
    required SwipeAction action,
  }) async {
    try {
      final swipeRepository = ref.watch(swipeRepositoryProvider);

      final response = await swipeRepository.recordSwipeAction(
        targetUserId: targetUserId,
        action: action,
      );

      if (mounted && response.success == true) {
        // Remove the swiped user from the list
        _users.removeWhere((user) => user.id == targetUserId);

        // Update the last user ID if needed
        if (_users.isNotEmpty) {
          _lastUserId = _users.last.id;
        }

        // Reload state with updated users
        state = SwipeUsersState.success(_users);

        // Check if we need to load more users
        if (_users.length < 5 && _hasMoreUsers) {
          await loadMoreUsers();
        }
      }
    } catch (e, s) {
      if (mounted) {
        state = SwipeUsersState.error(e.toString(), stackTrace: s);
      }
    }
  }

  /// Like a user
  Future<void> likeUser(String userId) async {
    await recordSwipeAction(
      targetUserId: userId,
      action: SwipeAction.like,
    );
  }

  /// Pass on a user
  Future<void> passUser(String userId) async {
    await recordSwipeAction(
      targetUserId: userId,
      action: SwipeAction.pass,
    );
  }

  /// Super like a user
  Future<void> superLikeUser(String userId) async {
    await recordSwipeAction(
      targetUserId: userId,
      action: SwipeAction.superLike,
    );
  }

  /// Refresh the users list
  Future<void> refreshUsers() async {
    _users.clear();
    _lastUserId = null;
    _hasMoreUsers = true;
    await loadSwipeUsers();
  }

  /// Get the next user to display
  UserModel? getNextUser() {
    return _users.isNotEmpty ? _users.first : null;
  }

  /// Remove the current user from the list (after swipe)
  void removeCurrentUser() {
    if (_users.isNotEmpty) {
      _users.removeAt(0);
      if (_users.isNotEmpty) {
        _lastUserId = _users.last.id;
      }
      state = SwipeUsersState.success(_users);

      // Auto-fetch more if running low
      if (_users.length < 5 && _hasMoreUsers) {
        // Fire and forget to avoid blocking UI thread
        // ignore: discarded_futures
        loadMoreUsers();
      }
    }
  }

  /// Check if there are users available
  bool get hasUsers => _users.isNotEmpty;

  /// Get current user count
  int get userCount => _users.length;
}

// Define the state type
typedef SwipeUsersState = BaseState<List<UserModel>>;

// Provider for the swipe users notifier
final swipeUsersProvider =
    StateNotifierProvider.autoDispose<SwipeUsersNotifier, SwipeUsersState>(
  (ref) => SwipeUsersNotifier(SwipeUsersState.initial(), ref),
);
