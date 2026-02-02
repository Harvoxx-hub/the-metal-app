import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/notification/notification_repository.dart';
import 'package:metal/data/repositories/notification/notification_repository_providers.dart';
import 'package:metal/domain/entities/notification_dto.dart';

/// Notification State
class NotificationState {
  final bool isLoading;
  final bool isMarking;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;
  final List<NotificationDto> notifications;
  final int unreadCount;
  final bool hasMore;
  final int currentPage;
  final String? filterType; // For filtering by notification type
  final bool? showUnreadOnly;

  const NotificationState({
    this.isLoading = false,
    this.isMarking = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
    this.notifications = const [],
    this.unreadCount = 0,
    this.hasMore = true,
    this.currentPage = 1,
    this.filterType,
    this.showUnreadOnly,
  });

  /// Initial state
  factory NotificationState.initial() => const NotificationState();

  /// Loading state
  factory NotificationState.loading({
    List<NotificationDto>? existingNotifications,
    int? existingUnreadCount,
  }) =>
      NotificationState(
        isLoading: true,
        notifications: existingNotifications ?? [],
        unreadCount: existingUnreadCount ?? 0,
      );

  /// Success state
  factory NotificationState.success({
    required List<NotificationDto> notifications,
    required int unreadCount,
    bool hasMore = true,
    int currentPage = 1,
  }) {
    return NotificationState(
      isSuccess: true,
      notifications: notifications,
      unreadCount: unreadCount,
      hasMore: hasMore,
      currentPage: currentPage,
    );
  }

  /// Error state
  factory NotificationState.error(
    String message, {
    List<NotificationDto>? existingNotifications,
    int? existingUnreadCount,
  }) =>
      NotificationState(
        isError: true,
        errorMessage: message,
        notifications: existingNotifications ?? [],
        unreadCount: existingUnreadCount ?? 0,
      );

  /// Copy with
  NotificationState copyWith({
    bool? isLoading,
    bool? isMarking,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
    List<NotificationDto>? notifications,
    int? unreadCount,
    bool? hasMore,
    int? currentPage,
    String? filterType,
    bool? showUnreadOnly,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      isMarking: isMarking ?? this.isMarking,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      filterType: filterType ?? this.filterType,
      showUnreadOnly: showUnreadOnly ?? this.showUnreadOnly,
    );
  }
}

/// Notification ViewModel
/// Event-driven only: fetch on screen open, pull-to-refresh, or when FCM push received
/// No polling / interval-based refresh
class NotificationViewModel extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;

  NotificationViewModel({
    required NotificationRepository repository,
  })  : _repository = repository,
        super(NotificationState.initial());

  /// Refresh when FCM push is received (foreground or background)
  Future<void> refreshOnPushReceived() async {
    await loadNotifications(refresh: true, silentRefresh: true);
  }

  /// Load notifications with optional filters
  Future<void> loadNotifications({
    bool refresh = false,
    bool silentRefresh = false,
    int limit = 50,
  }) async {
    if (state.isLoading && !silentRefresh) return;

    final page = refresh ? 1 : state.currentPage;

    if (!silentRefresh) {
      if (refresh) {
        state = NotificationState.loading();
      } else {
        state = state.copyWith(isLoading: true);
      }
    }

    final result = await _repository.getNotifications(
      page: page,
      limit: limit,
    );

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        final notifications = refresh
            ? result.data!.notifications
            : [...state.notifications, ...result.data!.notifications];

        state = NotificationState.success(
          notifications: notifications,
          unreadCount: result.data!.unreadCount,
          hasMore: result.data!.hasMore,
          currentPage: result.data!.currentPage ?? page,
        );
      } else if (!silentRefresh) {
        state = NotificationState.error(
          result.errorMessage ?? 'Failed to load notifications',
          existingNotifications: state.notifications,
          existingUnreadCount: state.unreadCount,
        );
      }
    }
  }

  /// Mark a notification as read
  Future<bool> markAsRead({required String notificationId}) async {
    if (state.isMarking) return false;

    state = state.copyWith(isMarking: true);

    final result = await _repository.markAsRead(
      notificationId: notificationId,
    );

    if (mounted) {
      if (result.isSuccess) {
        // Update the notification in the list
        final updatedNotifications = state.notifications.map((n) {
          if (n.id == notificationId) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();

        final idx = state.notifications.indexWhere((n) => n.id == notificationId);
        final wasUnread = idx >= 0 && !state.notifications[idx].isRead;
        final newUnreadCount = wasUnread ? state.unreadCount - 1 : state.unreadCount;

        state = state.copyWith(
          isMarking: false,
          notifications: updatedNotifications,
          unreadCount: newUnreadCount,
        );

        return true;
      } else {
        state = state.copyWith(
          isMarking: false,
          isError: true,
          errorMessage: result.errorMessage ?? 'Failed to mark as read',
        );

        return false;
      }
    }

    return false;
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    if (state.isMarking) return false;

    state = state.copyWith(isMarking: true);

    final result = await _repository.markAllAsRead();

    if (mounted) {
      if (result.isSuccess) {
        // Mark all notifications as read in the list
        final updatedNotifications =
            state.notifications.map((n) => n.copyWith(isRead: true)).toList();

        state = state.copyWith(
          isMarking: false,
          notifications: updatedNotifications,
          unreadCount: 0,
        );

        return true;
      } else {
        state = state.copyWith(
          isMarking: false,
          isError: true,
          errorMessage: result.errorMessage ?? 'Failed to mark all as read',
        );

        return false;
      }
    }

    return false;
  }

  /// Set filter type
  void setFilterType(String? type) {
    if (state.filterType != type) {
      state = state.copyWith(filterType: type);
      loadNotifications(refresh: true);
    }
  }

  /// Toggle unread only filter
  void toggleUnreadOnly() {
    state = state.copyWith(
      showUnreadOnly: state.showUnreadOnly == true ? null : true,
    );
    loadNotifications(refresh: true);
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await loadNotifications(refresh: true);
  }

  /// Load more notifications (pagination)
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    await loadNotifications(
      refresh: false,
    );
  }

  /// Execute notification action (Accept, Decline, Chat, etc.)
  Future<Map<String, dynamic>?> executeAction({
    required String notificationId,
    required String action,
    Map<String, dynamic>? params,
  }) async {
    final result = await _repository.executeAction(
      notificationId: notificationId,
      action: action,
      params: params,
    );
    if (result.isSuccess && result.data != null) {
      return result.data;
    }
    return null;
  }
}

/// Notification ViewModel Provider
final notificationViewModelProvider = StateNotifierProvider.autoDispose<
    NotificationViewModel, NotificationState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  final viewModel = NotificationViewModel(repository: repository);
  viewModel.loadNotifications(); // Initial load when screen opens
  return viewModel;
});
